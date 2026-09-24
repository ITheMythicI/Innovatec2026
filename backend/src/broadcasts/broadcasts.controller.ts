import { Controller, Post, Get, Delete, Body, Param, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { BroadcastsService } from './broadcasts.service';
import { CreateBroadcastDto } from './dto/create-broadcast.dto';
import { AdminGuard } from '../common/guards/admin.guard';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/decorators/roles.decorator';
import { AppRole } from '@prisma/client';

@ApiTags('Admin — Broadcasts & Alertas')
@ApiBearerAuth()
@UseGuards(AdminGuard, RolesGuard)
@Controller('admin/broadcasts')
export class BroadcastsController {
  constructor(private readonly broadcastsService: BroadcastsService) {}

  @Post()
  @Roles(AppRole.COMMANDER) // Solo COMMANDER o SUPER_ADMIN pueden emitir comunicados oficiales
  @ApiOperation({ summary: 'Emitir o programar un comunicado/alerta oficial (Global o Geocerca PostGIS)' })
  @ApiResponse({ status: 201, description: 'Comunicado emitido correctamente' })
  async create(@Body() dto: CreateBroadcastDto, @Request() req: any) {
    return this.broadcastsService.create(dto, req.user.sub);
  }

  @Get()
  @Roles(AppRole.OPERATOR)
  @ApiOperation({ summary: 'Consultar historial y estado de emisiones y comunicados' })
  @ApiResponse({ status: 200, description: 'Lista de emisiones con métricas de entrega' })
  async findAll() {
    return this.broadcastsService.findAll();
  }

  @Get(':id')
  @Roles(AppRole.OPERATOR)
  @ApiOperation({ summary: 'Consultar detalles y telemetría de entrega de un comunicado' })
  @ApiResponse({ status: 200, description: 'Detalle de emisión' })
  async findById(@Param('id') id: string) {
    return this.broadcastsService.findById(id);
  }

  @Delete(':id/cancel')
  @Roles(AppRole.COMMANDER)
  @ApiOperation({ summary: 'Cancelar un comunicado o alerta activa' })
  @ApiResponse({ status: 200, description: 'Comunicado cancelado' })
  async cancel(@Param('id') id: string) {
    return this.broadcastsService.cancel(id);
  }
}
