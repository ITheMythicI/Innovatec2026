import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateEmergencyDto } from './dto/create-emergency.dto';
import { UpdateEmergencyDto } from './dto/update-emergency.dto';
import { EmergencyNearbyQueryDto } from './dto/emergency-nearby-query.dto';
import { CreateEmergencyEventDto } from './dto/create-emergency-event.dto';
import { EmergencySeverity, EmergencyStatus, EmergencyType, Prisma } from '@prisma/client';

@Injectable()
export class EmergenciesService {
  constructor(private readonly prisma: PrismaService) {}

  async create(dto: CreateEmergencyDto) {
    return this.prisma.emergency.create({
      data: {
        title: dto.title,
        description: dto.description,
        type: dto.type || EmergencyType.OTHER,
        severity: dto.severity || EmergencySeverity.MEDIUM,
        status: dto.status || EmergencyStatus.ACTIVE,
        latitude: dto.latitude,
        longitude: dto.longitude,
        radiusMeters: dto.radiusMeters,
        startedAt: dto.startedAt ? new Date(dto.startedAt) : undefined,
      },
    });
  }

  async findAll(filters?: {
    status?: EmergencyStatus;
    severity?: EmergencySeverity;
    type?: EmergencyType;
    limit?: number;
  }) {
    const where: Prisma.EmergencyWhereInput = {};
    if (filters?.status) where.status = filters.status;
    if (filters?.severity) where.severity = filters.severity;
    if (filters?.type) where.type = filters.type;

    return this.prisma.emergency.findMany({
      where,
      take: filters?.limit ? Number(filters.limit) : 50,
      orderBy: { startedAt: 'desc' },
      include: {
        events: { take: 5, orderBy: { recordedAt: 'desc' } },
        _count: { select: { reports: true, events: true, riskZones: true } },
      },
    });
  }

  async findById(id: string) {
    const emergency = await this.prisma.emergency.findUnique({
      where: { id },
      include: {
        events: { orderBy: { recordedAt: 'desc' } },
        reports: { take: 20, orderBy: { createdAt: 'desc' } },
        riskZones: true,
      },
    });

    if (!emergency) {
      throw new NotFoundException(`Emergencia con ID ${id} no encontrada`);
    }

    return emergency;
  }

  async update(id: string, dto: UpdateEmergencyDto) {
    await this.findById(id);

    return this.prisma.emergency.update({
      where: { id },
      data: {
        title: dto.title,
        description: dto.description,
        type: dto.type,
        severity: dto.severity,
        status: dto.status,
        latitude: dto.latitude,
        longitude: dto.longitude,
        radiusMeters: dto.radiusMeters,
        endedAt: dto.endedAt ? new Date(dto.endedAt) : undefined,
      },
    });
  }

  async remove(id: string) {
    await this.findById(id);
    return this.prisma.emergency.delete({ where: { id } });
  }

  /**
   * Consulta espacial con PostGIS: Retorna emergencias dentro del radio especificado,
   * calculando la distancia geodésica exacta en metros sobre WGS84 e indicando
   * si el usuario está dentro del radio de afectación directa (`radius_meters`).
   */
  async findNearby(query: EmergencyNearbyQueryDto) {
    const radiusMeters = query.radiusMeters || 10000;
    const limit = query.limit || 20;

    // Condición opcional de estado y severidad
    let statusFilter = Prisma.sql``;
    if (query.status) {
      statusFilter = Prisma.sql`AND e.status = ${query.status}::"EmergencyStatus"`;
    }

    let severityFilter = Prisma.sql``;
    if (query.severity) {
      severityFilter = Prisma.sql`AND e.severity = ${query.severity}::"EmergencySeverity"`;
    }

    const results = await this.prisma.$queryRaw<any[]>`
      SELECT 
        e.id,
        e.title,
        e.description,
        e.type,
        e.severity,
        e.status,
        e.latitude,
        e.longitude,
        e.radius_meters AS "radiusMeters",
        e.started_at AS "startedAt",
        e.ended_at AS "endedAt",
        ROUND(ST_Distance(
          ST_SetSRID(ST_MakePoint(e.longitude, e.latitude), 4326)::geography,
          ST_SetSRID(ST_MakePoint(${query.longitude}, ${query.latitude}), 4326)::geography
        )::numeric, 1) AS "distanceMeters",
        CASE 
          WHEN e.radius_meters IS NOT NULL AND ST_Distance(
            ST_SetSRID(ST_MakePoint(e.longitude, e.latitude), 4326)::geography,
            ST_SetSRID(ST_MakePoint(${query.longitude}, ${query.latitude}), 4326)::geography
          ) <= e.radius_meters THEN true 
          ELSE false 
        END AS "isInsideImpactZone"
      FROM emergencies e
      WHERE ST_DWithin(
        ST_SetSRID(ST_MakePoint(e.longitude, e.latitude), 4326)::geography,
        ST_SetSRID(ST_MakePoint(${query.longitude}, ${query.latitude}), 4326)::geography,
        ${radiusMeters}
      )
      ${statusFilter}
      ${severityFilter}
      ORDER BY "distanceMeters" ASC
      LIMIT ${limit};
    `;

    return results;
  }

  async addEvent(emergencyId: string, dto: CreateEmergencyEventDto) {
    await this.findById(emergencyId);

    return this.prisma.emergencyEvent.create({
      data: {
        emergencyId,
        eventType: dto.eventType,
        description: dto.description,
        latitude: dto.latitude,
        longitude: dto.longitude,
        recordedAt: dto.recordedAt ? new Date(dto.recordedAt) : undefined,
      },
    });
  }

  async getEvents(emergencyId: string) {
    await this.findById(emergencyId);
    return this.prisma.emergencyEvent.findMany({
      where: { emergencyId },
      orderBy: { recordedAt: 'desc' },
    });
  }
}
