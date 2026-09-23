import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class EmergenciesService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll() {
    return this.prisma.emergency.findMany({
      orderBy: { startedAt: 'desc' },
      include: {
        events: true,
      },
    });
  }

  async findById(id: string) {
    return this.prisma.emergency.findUnique({
      where: { id },
      include: {
        events: { orderBy: { recordedAt: 'desc' } },
        reports: { take: 20 },
      },
    });
  }
}
