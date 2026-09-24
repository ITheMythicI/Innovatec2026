import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { Prisma, PoiCategory, PoiStatus, RiskLevel, HazardType } from '@prisma/client';
import { CreatePoiDto } from './dto/create-poi.dto';
import { UpdatePoiDto } from './dto/update-poi.dto';
import { PoiNearbyQueryDto } from './dto/poi-nearby-query.dto';
import { CreateRiskZoneDto } from './dto/create-risk-zone.dto';
import { UpdateRiskZoneDto } from './dto/update-risk-zone.dto';
import { EvaluateSafetyDto } from './dto/evaluate-safety.dto';

@Injectable()
export class GeographyService {
  constructor(private readonly prisma: PrismaService) {}

  // ─────────────────────────────────────────────
  // Points of Interest
  // ─────────────────────────────────────────────

  async createPoi(dto: CreatePoiDto) {
    return this.prisma.pointOfInterest.create({
      data: {
        name: dto.name,
        category: dto.category,
        latitude: dto.latitude,
        longitude: dto.longitude,
        address: dto.address,
        description: dto.description,
        contactPhone: dto.contactPhone,
        status: dto.status ?? PoiStatus.OPERATIONAL,
      },
    });
  }

  async findAllPois(filters: { category?: PoiCategory; status?: PoiStatus }) {
    return this.prisma.pointOfInterest.findMany({
      where: {
        ...(filters.category ? { category: filters.category } : {}),
        ...(filters.status ? { status: filters.status } : {}),
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async findPoiById(id: string) {
    const poi = await this.prisma.pointOfInterest.findUnique({ where: { id } });
    if (!poi) throw new NotFoundException(`POI con id ${id} no encontrado`);
    return poi;
  }

  async updatePoi(id: string, dto: UpdatePoiDto) {
    await this.findPoiById(id);
    return this.prisma.pointOfInterest.update({
      where: { id },
      data: {
        ...(dto.name !== undefined && { name: dto.name }),
        ...(dto.category !== undefined && { category: dto.category }),
        ...(dto.latitude !== undefined && { latitude: dto.latitude }),
        ...(dto.longitude !== undefined && { longitude: dto.longitude }),
        ...(dto.address !== undefined && { address: dto.address }),
        ...(dto.description !== undefined && { description: dto.description }),
        ...(dto.contactPhone !== undefined && { contactPhone: dto.contactPhone }),
        ...(dto.status !== undefined && { status: dto.status }),
      },
    });
  }

  async removePoi(id: string) {
    await this.findPoiById(id);
    return this.prisma.pointOfInterest.delete({ where: { id } });
  }

  async findNearbyPois(query: PoiNearbyQueryDto) {
    const { latitude, longitude, radiusMeters = 5000, category } = query;

    const categoryFilter = category ? Prisma.sql`AND category = ${category}::"PoiCategory"` : Prisma.empty;

    const results = await this.prisma.$queryRaw<
      Array<{
        id: string;
        name: string;
        category: string;
        latitude: number;
        longitude: number;
        address: string | null;
        description: string | null;
        contact_phone: string | null;
        status: string;
        distance_meters: number;
      }>
    >(Prisma.sql`
      SELECT
        id,
        name,
        category,
        latitude,
        longitude,
        address,
        description,
        contact_phone,
        status,
        ROUND(ST_Distance(
          ST_SetSRID(ST_MakePoint(longitude, latitude), 4326)::geography,
          ST_SetSRID(ST_MakePoint(${longitude}, ${latitude}), 4326)::geography
        )::numeric, 2) AS distance_meters
      FROM points_of_interest
      WHERE ST_DWithin(
        ST_SetSRID(ST_MakePoint(longitude, latitude), 4326)::geography,
        ST_SetSRID(ST_MakePoint(${longitude}, ${latitude}), 4326)::geography,
        ${radiusMeters}
      )
      ${categoryFilter}
      ORDER BY distance_meters ASC
      LIMIT 50
    `);

    return results.map((r) => ({
      id: r.id,
      name: r.name,
      category: r.category,
      latitude: r.latitude,
      longitude: r.longitude,
      address: r.address,
      description: r.description,
      contactPhone: r.contact_phone,
      status: r.status,
      distanceMeters: Number(r.distance_meters),
    }));
  }

  // ─────────────────────────────────────────────
  // Risk Zones
  // ─────────────────────────────────────────────

  async createRiskZone(dto: CreateRiskZoneDto) {
    // Basic GeoJSON structure validation
    const geo = dto.geometryGeoJson as { type?: string };
    if (!geo.type || !['Polygon', 'MultiPolygon'].includes(geo.type)) {
      throw new BadRequestException(
        'geometryGeoJson debe ser un GeoJSON de tipo Polygon o MultiPolygon',
      );
    }

    return this.prisma.riskZone.create({
      data: {
        name: dto.name,
        hazardType: dto.hazardType,
        riskLevel: dto.riskLevel,
        description: dto.description,
        geometryGeoJson: dto.geometryGeoJson as Prisma.InputJsonValue,
        active: dto.active ?? true,
        ...(dto.emergencyId && { emergencyId: dto.emergencyId }),
      },
    });
  }

  async findAllRiskZones(filters: {
    active?: boolean;
    riskLevel?: RiskLevel;
    hazardType?: HazardType;
  }) {
    return this.prisma.riskZone.findMany({
      where: {
        ...(filters.active !== undefined ? { active: filters.active } : {}),
        ...(filters.riskLevel ? { riskLevel: filters.riskLevel } : {}),
        ...(filters.hazardType ? { hazardType: filters.hazardType } : {}),
      },
      include: { emergency: { select: { id: true, title: true, status: true } } },
      orderBy: { createdAt: 'desc' },
    });
  }

  async findRiskZoneById(id: string) {
    const zone = await this.prisma.riskZone.findUnique({
      where: { id },
      include: { emergency: { select: { id: true, title: true, status: true } } },
    });
    if (!zone) throw new NotFoundException(`Zona de riesgo con id ${id} no encontrada`);
    return zone;
  }

  async updateRiskZone(id: string, dto: UpdateRiskZoneDto) {
    await this.findRiskZoneById(id);

    if (dto.geometryGeoJson !== undefined) {
      const geo = dto.geometryGeoJson as { type?: string };
      if (!geo.type || !['Polygon', 'MultiPolygon'].includes(geo.type)) {
        throw new BadRequestException(
          'geometryGeoJson debe ser un GeoJSON de tipo Polygon o MultiPolygon',
        );
      }
    }

    return this.prisma.riskZone.update({
      where: { id },
      data: {
        ...(dto.name !== undefined && { name: dto.name }),
        ...(dto.hazardType !== undefined && { hazardType: dto.hazardType }),
        ...(dto.riskLevel !== undefined && { riskLevel: dto.riskLevel }),
        ...(dto.description !== undefined && { description: dto.description }),
        ...(dto.geometryGeoJson !== undefined && {
          geometryGeoJson: dto.geometryGeoJson as Prisma.InputJsonValue,
        }),
        ...(dto.active !== undefined && { active: dto.active }),
        ...(dto.emergencyId !== undefined && { emergencyId: dto.emergencyId }),
      },
    });
  }

  async removeRiskZone(id: string) {
    await this.findRiskZoneById(id);
    return this.prisma.riskZone.delete({ where: { id } });
  }

  async checkRiskZones(latitude: number, longitude: number) {
    const zones = await this.prisma.$queryRaw<
      Array<{
        id: string;
        name: string;
        hazard_type: string;
        risk_level: string;
        description: string | null;
        active: boolean;
      }>
    >(Prisma.sql`
      SELECT
        id,
        name,
        hazard_type,
        risk_level,
        description,
        active
      FROM risk_zones
      WHERE active = true
        AND geom IS NOT NULL
        AND ST_Contains(
          geom,
          ST_SetSRID(ST_MakePoint(${longitude}, ${latitude}), 4326)
        )
      ORDER BY risk_level DESC
    `);

    return zones.map((z) => ({
      id: z.id,
      name: z.name,
      hazardType: z.hazard_type,
      riskLevel: z.risk_level,
      description: z.description,
      active: z.active,
    }));
  }

  // ─────────────────────────────────────────────
  // Safety Evaluation
  // ─────────────────────────────────────────────

  async evaluateSafety(dto: EvaluateSafetyDto) {
    const { latitude, longitude } = dto;

    const [riskZones, nearbyEmergencies, shelterRows, hospitalRows, waterRows] =
      await Promise.all([
        // 1. Risk zones containing the point
        this.prisma.$queryRaw<
          Array<{ id: string; name: string; hazard_type: string; risk_level: string }>
        >(Prisma.sql`
          SELECT id, name, hazard_type, risk_level
          FROM risk_zones
          WHERE active = true
            AND geom IS NOT NULL
            AND ST_Contains(
              geom,
              ST_SetSRID(ST_MakePoint(${longitude}, ${latitude}), 4326)
            )
        `),

        // 2. Active emergencies within their own radiusMeters
        this.prisma.$queryRaw<
          Array<{
            id: string;
            title: string;
            type: string;
            severity: string;
            latitude: number;
            longitude: number;
            radius_meters: number;
            distance_meters: number;
          }>
        >(Prisma.sql`
          SELECT
            id,
            title,
            type,
            severity,
            latitude,
            longitude,
            radius_meters,
            ROUND(ST_Distance(
              ST_SetSRID(ST_MakePoint(longitude, latitude), 4326)::geography,
              ST_SetSRID(ST_MakePoint(${longitude}, ${latitude}), 4326)::geography
            )::numeric, 2) AS distance_meters
          FROM emergencies
          WHERE status = 'ACTIVE'
            AND ST_DWithin(
              ST_SetSRID(ST_MakePoint(longitude, latitude), 4326)::geography,
              ST_SetSRID(ST_MakePoint(${longitude}, ${latitude}), 4326)::geography,
              radius_meters
            )
          ORDER BY distance_meters ASC
          LIMIT 10
        `),

        // 3. Nearest available shelter (within 30 km)
        this.prisma.$queryRaw<
          Array<{
            id: string;
            name: string;
            latitude: number;
            longitude: number;
            capacity: number;
            current_occupancy: number;
            distance_meters: number;
          }>
        >(Prisma.sql`
          SELECT
            id,
            name,
            latitude,
            longitude,
            capacity,
            current_occupancy,
            ROUND(ST_Distance(
              ST_SetSRID(ST_MakePoint(longitude, latitude), 4326)::geography,
              ST_SetSRID(ST_MakePoint(${longitude}, ${latitude}), 4326)::geography
            )::numeric, 2) AS distance_meters
          FROM shelters
          WHERE status = 'OPEN'
            AND ST_DWithin(
              ST_SetSRID(ST_MakePoint(longitude, latitude), 4326)::geography,
              ST_SetSRID(ST_MakePoint(${longitude}, ${latitude}), 4326)::geography,
              30000
            )
          ORDER BY distance_meters ASC
          LIMIT 1
        `),

        // 4. Nearest hospital POI (within 20 km)
        this.prisma.$queryRaw<
          Array<{
            id: string;
            name: string;
            latitude: number;
            longitude: number;
            address: string | null;
            contact_phone: string | null;
            distance_meters: number;
          }>
        >(Prisma.sql`
          SELECT
            id,
            name,
            latitude,
            longitude,
            address,
            contact_phone,
            ROUND(ST_Distance(
              ST_SetSRID(ST_MakePoint(longitude, latitude), 4326)::geography,
              ST_SetSRID(ST_MakePoint(${longitude}, ${latitude}), 4326)::geography
            )::numeric, 2) AS distance_meters
          FROM points_of_interest
          WHERE category = 'HOSPITAL'
            AND status = 'OPERATIONAL'
            AND ST_DWithin(
              ST_SetSRID(ST_MakePoint(longitude, latitude), 4326)::geography,
              ST_SetSRID(ST_MakePoint(${longitude}, ${latitude}), 4326)::geography,
              20000
            )
          ORDER BY distance_meters ASC
          LIMIT 1
        `),

        // 5. Nearest water point POI (within 10 km)
        this.prisma.$queryRaw<
          Array<{
            id: string;
            name: string;
            latitude: number;
            longitude: number;
            address: string | null;
            distance_meters: number;
          }>
        >(Prisma.sql`
          SELECT
            id,
            name,
            latitude,
            longitude,
            address,
            ROUND(ST_Distance(
              ST_SetSRID(ST_MakePoint(longitude, latitude), 4326)::geography,
              ST_SetSRID(ST_MakePoint(${longitude}, ${latitude}), 4326)::geography
            )::numeric, 2) AS distance_meters
          FROM points_of_interest
          WHERE category = 'WATER_POINT'
            AND status = 'OPERATIONAL'
            AND ST_DWithin(
              ST_SetSRID(ST_MakePoint(longitude, latitude), 4326)::geography,
              ST_SetSRID(ST_MakePoint(${longitude}, ${latitude}), 4326)::geography,
              10000
            )
          ORDER BY distance_meters ASC
          LIMIT 1
        `),
      ]);

    const nearestShelter = shelterRows[0]
      ? { ...shelterRows[0], distanceMeters: Number(shelterRows[0].distance_meters) }
      : null;

    const nearestHospital = hospitalRows[0]
      ? {
          id: hospitalRows[0].id,
          name: hospitalRows[0].name,
          latitude: hospitalRows[0].latitude,
          longitude: hospitalRows[0].longitude,
          address: hospitalRows[0].address,
          contactPhone: hospitalRows[0].contact_phone,
          distanceMeters: Number(hospitalRows[0].distance_meters),
        }
      : null;

    const nearestWaterPoint = waterRows[0]
      ? {
          id: waterRows[0].id,
          name: waterRows[0].name,
          latitude: waterRows[0].latitude,
          longitude: waterRows[0].longitude,
          address: waterRows[0].address,
          distanceMeters: Number(waterRows[0].distance_meters),
        }
      : null;

    return {
      coordinates: { latitude, longitude },
      isInRiskZone: riskZones.length > 0,
      riskZones: riskZones.map((z) => ({
        id: z.id,
        name: z.name,
        hazardType: z.hazard_type,
        riskLevel: z.risk_level,
      })),
      nearbyActiveEmergencies: nearbyEmergencies.map((e) => ({
        id: e.id,
        title: e.title,
        type: e.type,
        severity: e.severity,
        latitude: e.latitude,
        longitude: e.longitude,
        radiusMeters: e.radius_meters,
        distanceMeters: Number(e.distance_meters),
      })),
      nearestAvailableShelter: nearestShelter,
      nearestHospital,
      nearestWaterPoint,
      evaluatedAt: new Date().toISOString(),
    };
  }
}
