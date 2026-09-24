import { Controller, Post, Get, Body, HttpCode, HttpStatus, Query } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBody } from '@nestjs/swagger';
import { SyncService, SyncEventInput } from './sync.service';

@ApiTags('Sync')
@Controller('sync')
export class SyncController {
  constructor(private readonly syncService: SyncService) {}

  @Post('events')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Recibir y procesar un evento de sincronización idempotente desde un cliente (HTTPS/BLE/SMS)' })
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        event_id: { type: 'string', example: '123e4567-e89b-12d3-a456-426614174000' },
        device_id: { type: 'string', example: 'dev-phone-pixel-01' },
        entity_type: { type: 'string', example: 'person' },
        entity_id: { type: 'string', example: '987fcdeb-51a2-43f7-9abc-def012345678' },
        operation: { type: 'string', example: 'CREATE' },
        version: { type: 'integer', example: 1 },
        payload: { type: 'object', example: { firstName: 'Juan', lastName: 'Pérez' } },
        created_at: { type: 'string', example: '2026-09-23T20:30:00.000Z' },
      },
    },
  })
  @ApiResponse({ status: 200, description: 'Evento procesado o duplicado ignorado con éxito' })
  async syncEvent(@Body() body: SyncEventInput) {
    return this.syncService.processEvent(body);
  }

  @Get('events')
  @ApiOperation({ summary: 'Listar eventos de sincronización registrados' })
  @ApiResponse({ status: 200, description: 'Lista de eventos de sincronización' })
  async getEvents(@Query('limit') limit?: number) {
    return this.syncService.getRecentEvents(limit ? Number(limit) : 50);
  }
}
