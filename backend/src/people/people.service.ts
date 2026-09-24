import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class PeopleService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll() {
    return this.prisma.person.findMany({
      take: 50,
      orderBy: { createdAt: 'desc' },
    });
  }

  async findById(id: string) {
    return this.prisma.person.findUnique({
      where: { id },
      include: {
        familyMembers: { include: { family: true } },
        missingReports: true,
        shelterStays: { include: { shelter: true } },
      },
    });
  }
}
