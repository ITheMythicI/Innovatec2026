import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class FamiliesService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll() {
    return this.prisma.family.findMany({
      take: 50,
      include: {
        members: { include: { person: true } },
      },
    });
  }

  async findById(id: string) {
    return this.prisma.family.findUnique({
      where: { id },
      include: {
        members: { include: { person: true } },
      },
    });
  }
}
