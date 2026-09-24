import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

export interface SyncEventInput {
  event_id: string;
  device_id: string;
  entity_type: string;
  entity_id: string;
  operation: string;
  version: number;
  payload: any;
  created_at: string;
}

@Injectable()
export class SyncService {
  private readonly logger = new Logger(SyncService.name);

  constructor(private readonly prisma: PrismaService) {}

  /**
   * Procesa un evento de sincronización garantizando IDEMPOTENCIA.
   * Si un mismo `event_id` llega múltiples veces (por ejemplo, vía Internet y luego retransmitido por BLE o SMS),
   * no se duplicará ni se alterará el estado ya procesado.
   */
  async processEvent(eventData: SyncEventInput) {
    const existingEvent = await this.prisma.syncEvent.findUnique({
      where: { eventId: eventData.event_id },
    });

    if (existingEvent) {
      this.logger.log(`[Idempotencia] Evento ${eventData.event_id} ya procesado previamente.`);
      return {
        status: 'DUPLICATE_IGNORED',
        eventId: existingEvent.eventId,
        syncedAt: existingEvent.syncedAt,
      };
    }

    // Asegura o registra el dispositivo emisor si no existía
    await this.prisma.device.upsert({
      where: { deviceIdentifier: eventData.device_id },
      create: { deviceIdentifier: eventData.device_id },
      update: { lastSyncAt: new Date() },
    });

    const device = await this.prisma.device.findUnique({
      where: { deviceIdentifier: eventData.device_id },
    });

    const recordedEvent = await this.prisma.syncEvent.create({
      data: {
        eventId: eventData.event_id,
        deviceId: device!.id,
        entityType: eventData.entity_type,
        entityId: eventData.entity_id,
        operation: eventData.operation,
        version: eventData.version || 1,
        payload: eventData.payload || {},
        clientCreatedAt: new Date(eventData.created_at || Date.now()),
        status: 'PROCESSED',
      },
    });

    return {
      status: 'PROCESSED',
      eventId: recordedEvent.eventId,
      syncedAt: recordedEvent.syncedAt,
    };
  }

  async getRecentEvents(limit = 100) {
    return this.prisma.syncEvent.findMany({
      take: limit,
      orderBy: { syncedAt: 'desc' },
      include: { device: true },
    });
  }
}
