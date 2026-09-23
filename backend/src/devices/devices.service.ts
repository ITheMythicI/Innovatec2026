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
}
