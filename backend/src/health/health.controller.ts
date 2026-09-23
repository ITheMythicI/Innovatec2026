import { Controller, Get } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { HealthService } from './health.service';

@ApiTags('Health')
@Controller('health')
export class HealthController {
  constructor(private readonly healthService: HealthService) {}

  @Get()
  @ApiOperation({ summary: 'Verificar el estado del backend y la conexión a PostgreSQL/PostGIS' })
  @ApiResponse({
    status: 200,
    description: 'Estado del sistema reportado con éxito',
    schema: {
      example: {
        status: 'ok',
        database: 'connected',
        timestamp: '2026-09-23T20:47:00.000Z',
        uptimeSeconds: 15,
      },
    },
  })
  async getHealth() {
    return this.healthService.checkHealth();
  }
}
