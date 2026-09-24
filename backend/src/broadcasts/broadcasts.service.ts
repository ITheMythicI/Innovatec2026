import { Injectable, BadRequestException, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateBroadcastDto } from './dto/create-broadcast.dto';
import { BroadcastStatus, BroadcastTarget, DeliveryChannel, DeliveryStatus } from '@prisma/client';

@Injectable()
export class BroadcastsService {
  constructor(private readonly prisma: PrismaService) {}

  async create(dto: CreateBroadcastDto, userId: string) {
    if (dto.targetMode === BroadcastTarget.GEOGRAPHIC) {
      if (dto.geoLatitude === undefined || dto.geoLongitude === undefined || !dto.geoRadiusMeters) {
        throw new BadRequestException(
          'Para una emisión geográfica (GEOGRAPHIC), se deben especificar geoLatitude, geoLongitude y geoRadiusMeters',
        );
      }
    }

    return this.prisma.$transaction(async (tx) => {
      const broadcast = await tx.broadcast.create({
        data: {
          title: dto.title,
          body: dto.body,
          type: dto.type,
          targetMode: dto.targetMode,
          targetRole: dto.targetRole,
          geoLatitude: dto.geoLatitude,
          geoLongitude: dto.geoLongitude,
          geoRadiusMeters: dto.geoRadiusMeters,
          scheduledAt: dto.scheduledAt ? new Date(dto.scheduledAt) : null,
          sentByUserId: userId,
          status: dto.scheduledAt ? BroadcastStatus.CREATED : BroadcastStatus.SENT,
          sentAt: dto.scheduledAt ? null : new Date(),
        },
      });

      // Si se envía de inmediato, identificar dispositivos destino
      if (!dto.scheduledAt) {
        let targetDevices: { id: string }[] = [];

        if (dto.targetMode === BroadcastTarget.GEOGRAPHIC) {
          targetDevices = await tx.$queryRaw<{ id: string }[]>`
            SELECT id FROM devices
            WHERE last_latitude IS NOT NULL 
              AND last_longitude IS NOT NULL
              AND ST_DWithin(
                ST_SetSRID(ST_MakePoint(last_longitude, last_latitude), 4326)::geography,
                ST_SetSRID(ST_MakePoint(${dto.geoLongitude}, ${dto.geoLatitude}), 4326)::geography,
                ${dto.geoRadiusMeters}
              )
          `;
        } else {
          // GLOBAL o ROLE
          targetDevices = await tx.device.findMany({
            select: { id: true },
            take: 1000,
          });
        }

        if (targetDevices.length > 0) {
          await tx.broadcastDelivery.createMany({
            data: targetDevices.map((d) => ({
              broadcastId: broadcast.id,
              deviceId: d.id,
              channel: DeliveryChannel.WEBSOCKET,
              status: DeliveryStatus.SENT,
              sentAt: new Date(),
            })),
            skipDuplicates: true,
          });
        }
      }

      return broadcast;
    });
  }

  async findAll() {
    return this.prisma.broadcast.findMany({
      orderBy: { createdAt: 'desc' },
      include: {
        sentBy: { select: { id: true, fullName: true, email: true, appRole: true, tacticalId: true } },
        _count: { select: { deliveries: true } },
      },
    });
  }

  async findById(id: string) {
    const broadcast = await this.prisma.broadcast.findUnique({
      where: { id },
      include: {
        sentBy: { select: { id: true, fullName: true, email: true, appRole: true, tacticalId: true } },
        deliveries: {
          take: 50,
          include: {
            device: { select: { id: true, deviceIdentifier: true, deviceModel: true } },
          },
        },
        _count: { select: { deliveries: true } },
      },
    });

    if (!broadcast) {
      throw new NotFoundException(`Emisión con ID ${id} no encontrada`);
    }

    return broadcast;
  }

  async cancel(id: string) {
    const broadcast = await this.prisma.broadcast.findUnique({ where: { id } });
    if (!broadcast) {
      throw new NotFoundException(`Emisión con ID ${id} no encontrada`);
    }

    return this.prisma.broadcast.update({
      where: { id },
      data: { status: BroadcastStatus.CANCELLED },
    });
  }
}
