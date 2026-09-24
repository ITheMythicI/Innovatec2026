import { Controller, Get, Post, Patch, Delete, Body, Param, Query, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiQuery } from '@nestjs/swagger';
import { SheltersService } from './shelters.service';
import { CreateShelterDto } from './dto/create-shelter.dto';
import { UpdateShelterDto } from './dto/update-shelter.dto';
import { ShelterNearbyQueryDto } from './dto/shelter-nearby-query.dto';
import { AddShelterServiceDto } from './dto/add-shelter-service.dto';
import { CreateShelterStayDto } from './dto/create-shelter-stay.dto';
import { ShelterServiceType, ShelterStatus } from '@prisma/client';

@ApiTags('Shelters')
@Controller('shelters')
export class SheltersController {
  constructor(private readonly sheltersService: SheltersService) {}

  @Post()
  @ApiOperation({ summary: 'Registrar un nuevo albergue o centro de refugio' })
  @ApiResponse({ status: 201, description: 'Albergue registrado con éxito' })
  async create(@Body() dto: CreateShelterDto) {
    return this.sheltersService.create(dto);
  }

  @Get()
  @ApiOperation({ summary: 'Listar albergues con métricas de ocupación' })
  @ApiQuery({ name: 'status', enum: ShelterStatus, required: false })
  @ApiQuery({ name: 'onlyAvailable', type: Boolean, required: false })
  @ApiQuery({ name: 'limit', type: Number, required: false })
  @ApiResponse({ status: 200, description: 'Lista de albergues' })
  async findAll(
    @Query('status') status?: ShelterStatus,
    @Query('onlyAvailable') onlyAvailable?: boolean,
    @Query('limit') limit?: number,
  ) {
    return this.sheltersService.findAll({ status, onlyAvailable, limit });
  }

  @Get('nearby')
  @ApiOperation({ summary: 'Buscar albergues cercanos ordenados por distancia exacta en metros (PostGIS)' })
  @ApiResponse({ status: 200, description: 'Albergues cercanos' })
  async findNearby(@Query() query: ShelterNearbyQueryDto) {
    return this.sheltersService.findNearby(query);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Obtener detalle de un albergue (servicios, ocupación y albergados activos)' })
  @ApiResponse({ status: 200, description: 'Albergue encontrado' })
  @ApiResponse({ status: 404, description: 'Albergue no encontrado' })
  async findById(@Param('id') id: string) {
    return this.sheltersService.findById(id);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Actualizar información o capacidad de un albergue' })
  @ApiResponse({ status: 200, description: 'Albergue actualizado' })
  async update(@Param('id') id: string, @Body() dto: UpdateShelterDto) {
    return this.sheltersService.update(id, dto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Eliminar un albergue' })
  @ApiResponse({ status: 204, description: 'Albergue eliminado' })
  async remove(@Param('id') id: string) {
    return this.sheltersService.remove(id);
  }

  @Post(':id/services')
  @ApiOperation({ summary: 'Agregar o actualizar un servicio provisto por el albergue (Agua, Médico, WiFi, etc.)' })
  @ApiResponse({ status: 201, description: 'Servicio registrado' })
  async addService(@Param('id') id: string, @Body() dto: AddShelterServiceDto) {
    return this.sheltersService.addService(id, dto);
  }

  @Delete(':id/services/:serviceType')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Eliminar un servicio del albergue' })
  @ApiResponse({ status: 204, description: 'Servicio eliminado' })
  async removeService(@Param('id') id: string, @Param('serviceType') serviceType: ShelterServiceType) {
    return this.sheltersService.removeService(id, serviceType);
  }

  @Post(':id/stays')
  @ApiOperation({ summary: 'Registrar ingreso de una persona al albergue (actualiza ocupación atómicamente)' })
  @ApiResponse({ status: 201, description: 'Ingreso registrado exitosamente' })
  async registerStay(@Param('id') id: string, @Body() dto: CreateShelterStayDto) {
    return this.sheltersService.registerStay(id, dto);
  }

  @Post('stays/:stayId/checkout')
  @ApiOperation({ summary: 'Registrar egreso o salida de un albergado (libera cupo en el albergue)' })
  @ApiResponse({ status: 200, description: 'Egreso registrado exitosamente' })
  async checkOutStay(@Param('stayId') stayId: string, @Body('notes') notes?: string) {
    return this.sheltersService.checkOutStay(stayId, notes);
  }
}
