import { Controller, Get } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { BroadcastsService } from './broadcasts.service';

@ApiTags('Public — Broadcasts & Comunicados Oficiales')
@Controller('broadcasts')
export class BroadcastsFeedController {
  constructor(private readonly broadcastsService: BroadcastsService) {}

  @Get('feed')
  @ApiOperation({ summary: 'Obtener el feed de boletines y comunicados oficiales activos para la app móvil' })
  @ApiResponse({ status: 200, description: 'Feed de comunicados ordenados cronológicamente' })
  async getFeed() {
    return this.broadcastsService.getActiveFeed();
  }
}
