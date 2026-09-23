import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class ReportsService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll() {
    return this.prisma.report.findMany({
      orderBy: { createdAt: 'desc' },
      take: 50,
      include: {
        emergency: true,
      },
    });
  }

  async findById(id: string) {
    return this.prisma.report.findUnique({
      where: { id },
      include: {
        emergency: true,
        reporterUser: { select: { id: true, fullName: true, email: true } },
      },
    });
  }
}
