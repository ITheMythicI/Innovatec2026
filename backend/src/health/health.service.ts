import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class HealthService {
  constructor(private readonly prisma: PrismaService) {}

  async checkHealth() {
    let databaseStatus = 'disconnected';
    try {
      // Verifica conectividad real con PostgreSQL ejecutando un query ligero
      await this.prisma.$queryRaw`SELECT 1`;
      databaseStatus = 'connected';
    } catch (error) {
      databaseStatus = `error: ${error instanceof Error ? error.message : 'Unknown database error'}`;
    }

    return {
      status: databaseStatus === 'connected' ? 'ok' : 'degraded',
      database: databaseStatus,
      timestamp: new Date().toISOString(),
      uptimeSeconds: Math.floor(process.uptime()),
    };
  }
}
