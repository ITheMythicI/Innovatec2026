import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class SheltersService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll() {
    return this.prisma.shelter.findMany({
      include: {
        services: true,
      },
      orderBy: { name: 'asc' },
    });
  }

  async findById(id: string) {
    return this.prisma.shelter.findUnique({
      where: { id },
      include: {
        services: true,
        stays: { where: { status: 'ACTIVE' }, include: { person: true } },
      },
    });
  }
}
