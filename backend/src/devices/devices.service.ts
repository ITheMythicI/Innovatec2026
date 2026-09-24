import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class DevicesService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll() {
    return this.prisma.device.findMany({
      orderBy: { updatedAt: 'desc' },
      include: {
        _count: { select: { syncEvents: true, locationEvents: true } },
      },
    });
  }

  async findById(id: string) {
    return this.prisma.device.findUnique({
      where: { id },
      include: {
        syncEvents: { take: 20, orderBy: { syncedAt: 'desc' } },
        locationEvents: { take: 20, orderBy: { recordedAt: 'desc' } },
      },
    });
  }

  async updatePosition(dto: {
    deviceIdentifier: string;
    latitude: number;
    longitude: number;
    deviceModel?: string;
    appVersion?: string;
  }) {
    const now = new Date();
    return this.prisma.device.upsert({
      where: { deviceIdentifier: dto.deviceIdentifier },
      create: {
        deviceIdentifier: dto.deviceIdentifier,
        lastLatitude: dto.latitude,
        lastLongitude: dto.longitude,
        lastPositionAt: now,
        deviceModel: dto.deviceModel,
        appVersion: dto.appVersion,
      },
      update: {
        lastLatitude: dto.latitude,
        lastLongitude: dto.longitude,
        lastPositionAt: now,
        ...(dto.deviceModel && { deviceModel: dto.deviceModel }),
        ...(dto.appVersion && { appVersion: dto.appVersion }),
      },
    });
  }

  async findNearby(latitude: number, longitude: number, radiusMeters: number) {
    return this.prisma.$queryRaw<any[]>`
      SELECT 
        id,
        device_identifier as "deviceIdentifier",
        device_model as "deviceModel",
        app_version as "appVersion",
        last_latitude as "lastLatitude",
        last_longitude as "lastLongitude",
        last_position_at as "lastPositionAt",
        ST_Distance(
          ST_SetSRID(ST_MakePoint(last_longitude, last_latitude), 4326)::geography,
          ST_SetSRID(ST_MakePoint(${longitude}, ${latitude}), 4326)::geography
        ) as "distanceMeters"
      FROM devices
      WHERE last_latitude IS NOT NULL 
        AND last_longitude IS NOT NULL
        AND ST_DWithin(
          ST_SetSRID(ST_MakePoint(last_longitude, last_latitude), 4326)::geography,
          ST_SetSRID(ST_MakePoint(${longitude}, ${latitude}), 4326)::geography,
          ${radiusMeters}
        )
      ORDER BY "distanceMeters" ASC
    `;
  }
}
