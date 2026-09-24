import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateReportDto } from './dto/create-report.dto';
import { UpdateReportStatusDto } from './dto/update-report-status.dto';
import { ReportNearbyQueryDto } from './dto/report-nearby-query.dto';
import { Prisma, ReportCategory, ReportPriority, ReportStatus } from '@prisma/client';

@Injectable()
export class ReportsService {
  constructor(private readonly prisma: PrismaService) {}

  async create(dto: CreateReportDto, currentUserId?: string) {
    return this.prisma.report.create({
      data: {
        title: dto.title,
        description: dto.description,
        category: dto.category || ReportCategory.OTHER,
        priority: dto.priority || ReportPriority.MEDIUM,
        status: ReportStatus.PENDING,
        latitude: dto.latitude,
        longitude: dto.longitude,
        address: dto.address,
        emergencyId: dto.emergencyId,
        reporterName: dto.reporterName,
        reporterContact: dto.reporterContact,
        reporterUserId: currentUserId || dto.reporterUserId,
      },
    });
  }

  async findAll(filters?: {
    status?: ReportStatus;
    category?: ReportCategory;
    priority?: ReportPriority;
    emergencyId?: string;
    limit?: number;
  }) {
    const where: Prisma.ReportWhereInput = {};
    if (filters?.status) where.status = filters.status;
    if (filters?.category) where.category = filters.category;
    if (filters?.priority) where.priority = filters.priority;
    if (filters?.emergencyId) where.emergencyId = filters.emergencyId;

    return this.prisma.report.findMany({
      where,
      take: filters?.limit ? Number(filters.limit) : 50,
      orderBy: { createdAt: 'desc' },
      include: {
        emergency: { select: { id: true, title: true, severity: true, status: true } },
        reporterUser: { select: { id: true, fullName: true, email: true } },
      },
    });
  }

  async findById(id: string) {
    const report = await this.prisma.report.findUnique({
      where: { id },
      include: {
        emergency: true,
        reporterUser: { select: { id: true, fullName: true, email: true, phone: true } },
      },
    });

    if (!report) {
      throw new NotFoundException(`Reporte con ID ${id} no encontrado`);
    }

    return report;
  }

  async updateStatus(id: string, dto: UpdateReportStatusDto) {
    await this.findById(id);

    return this.prisma.report.update({
      where: { id },
      data: {
        status: dto.status,
        verifiedByUserId: dto.verifiedByUserId,
        verificationNotes: dto.verificationNotes,
      },
    });
  }

  async remove(id: string) {
    await this.findById(id);
    return this.prisma.report.delete({ where: { id } });
  }

  /**
   * Consulta espacial con PostGIS: Retorna reportes geolocalizados dentro de un radio,
   * ordenados por distancia exacta al rescatista o centro de mando.
   */
  async findNearby(query: ReportNearbyQueryDto) {
    const radiusMeters = query.radiusMeters || 5000;
    const limit = query.limit || 50;

    let statusFilter = Prisma.sql``;
    if (query.status) {
      statusFilter = Prisma.sql`AND r.status = ${query.status}::"ReportStatus"`;
    }

    let categoryFilter = Prisma.sql``;
    if (query.category) {
      categoryFilter = Prisma.sql`AND r.category = ${query.category}::"ReportCategory"`;
    }

    let priorityFilter = Prisma.sql``;
    if (query.priority) {
      priorityFilter = Prisma.sql`AND r.priority = ${query.priority}::"ReportPriority"`;
    }

    const results = await this.prisma.$queryRaw<any[]>`
      SELECT 
        r.id,
        r.title,
        r.description,
        r.category,
        r.priority,
        r.status,
        r.latitude,
        r.longitude,
        r.address,
        r.emergency_id AS "emergencyId",
        r.reporter_name AS "reporterName",
        r.reporter_contact AS "reporterContact",
        r.created_at AS "createdAt",
        ROUND(ST_Distance(
          ST_SetSRID(ST_MakePoint(r.longitude, r.latitude), 4326)::geography,
          ST_SetSRID(ST_MakePoint(${query.longitude}, ${query.latitude}), 4326)::geography
        )::numeric, 1) AS "distanceMeters"
      FROM reports r
      WHERE r.latitude IS NOT NULL AND r.longitude IS NOT NULL
        AND ST_DWithin(
          ST_SetSRID(ST_MakePoint(r.longitude, r.latitude), 4326)::geography,
          ST_SetSRID(ST_MakePoint(${query.longitude}, ${query.latitude}), 4326)::geography,
          ${radiusMeters}
        )
        ${statusFilter}
        ${categoryFilter}
        ${priorityFilter}
      ORDER BY "distanceMeters" ASC
      LIMIT ${limit};
    `;

    return results;
  }
}
