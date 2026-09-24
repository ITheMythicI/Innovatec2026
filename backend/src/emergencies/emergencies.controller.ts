import { Controller, Get, Post, Patch, Delete, Body, Param, Query, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiQuery } from '@nestjs/swagger';
import { EmergenciesService } from './emergencies.service';
import { CreateEmergencyDto } from './dto/create-emergency.dto';
import { UpdateEmergencyDto } from './dto/update-emergency.dto';
import { EmergencyNearbyQueryDto } from './dto/emergency-nearby-query.dto';
import { CreateEmergencyEventDto } from './dto/create-emergency-event.dto';
import { EmergencySeverity, EmergencyStatus, EmergencyType } from '@prisma/client';

@ApiTags('Emergencies')
@Controller('emergencies')
export class EmergenciesController {
  constructor(private readonly emergenciesService: EmergenciesService) {}

  @Post()
  @ApiOperation({ summary: 'Registrar una nueva emergencia o desastre' })
  @ApiResponse({ status: 201, description: 'Emergencia creada exitosamente' })
  async create(@Body() dto: CreateEmergencyDto) {
    return this.emergenciesService.create(dto);
  }

  @Get()
  @ApiOperation({ summary: 'Listar emergencias con filtros opcionales' })
  @ApiQuery({ name: 'status', enum: EmergencyStatus, required: false })
  @ApiQuery({ name: 'severity', enum: EmergencySeverity, required: false })
  @ApiQuery({ name: 'type', enum: EmergencyType, required: false })
  @ApiQuery({ name: 'limit', type: Number, required: false })
  @ApiResponse({ status: 200, description: 'Lista de emergencias' })
  async findAll(
    @Query('status') status?: EmergencyStatus,
    @Query('severity') severity?: EmergencySeverity,
    @Query('type') type?: EmergencyType,
    @Query('limit') limit?: number,
  ) {
    return this.emergenciesService.findAll({ status, severity, type, limit });
  }

  @Get('nearby')
  @ApiOperation({ summary: 'Buscar emergencias cercanas usando PostGIS con cálculo geodésico de distancia' })
  @ApiResponse({ status: 200, description: 'Emergencias cercanas ordenadas por distancia' })
  async findNearby(@Query() query: EmergencyNearbyQueryDto) {
    return this.emergenciesService.findNearby(query);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Obtener detalle completo de una emergencia (incluye eventos y zonas de riesgo)' })
  @ApiResponse({ status: 200, description: 'Emergencia encontrada' })
  @ApiResponse({ status: 404, description: 'Emergencia no encontrada' })
  async findById(@Param('id') id: string) {
    return this.emergenciesService.findById(id);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Actualizar datos de una emergencia' })
  @ApiResponse({ status: 200, description: 'Emergencia actualizada' })
  async update(@Param('id') id: string, @Body() dto: UpdateEmergencyDto) {
    return this.emergenciesService.update(id, dto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Eliminar una emergencia' })
  @ApiResponse({ status: 204, description: 'Emergencia eliminada' })
  async remove(@Param('id') id: string) {
    return this.emergenciesService.remove(id);
  }

  @Post(':id/events')
  @ApiOperation({ summary: 'Registrar un evento o actualización cronológica en la emergencia' })
  @ApiResponse({ status: 201, description: 'Evento registrado con éxito' })
  async addEvent(@Param('id') id: string, @Body() dto: CreateEmergencyEventDto) {
    return this.emergenciesService.addEvent(id, dto);
  }

  @Get(':id/events')
  @ApiOperation({ summary: 'Listar cronología de eventos de una emergencia' })
  @ApiResponse({ status: 200, description: 'Lista de eventos ordenados cronológicamente' })
  async getEvents(@Param('id') id: string) {
    return this.emergenciesService.getEvents(id);
  }
}
