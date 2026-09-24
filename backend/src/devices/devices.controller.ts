import { Controller, Get, Param, Post, Body, HttpCode, HttpStatus, Query } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { DevicesService } from './devices.service';
import { UpdateDevicePositionDto } from './dto/update-device-position.dto';

@ApiTags('Devices')
@Controller('devices')
export class DevicesController {
  constructor(private readonly devicesService: DevicesService) {}

  @Get()
  @ApiOperation({ summary: 'Listar dispositivos registrados y su última sincronización' })
  @ApiResponse({ status: 200, description: 'Lista de dispositivos' })
  async findAll() {
    return this.devicesService.findAll();
  }

  @Get(':id')
  @ApiOperation({ summary: 'Obtener información de un dispositivo y sus eventos recientes' })
  @ApiResponse({ status: 200, description: 'Dispositivo encontrado' })
  async findById(@Param('id') id: string) {
    return this.devicesService.findById(id);
  }

  @Post('position')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Registrar o actualizar la última posición geográfica del dispositivo' })
  @ApiResponse({ status: 200, description: 'Posición actualizada correctamente' })
  async updatePosition(@Body() dto: UpdateDevicePositionDto) {
    return this.devicesService.updatePosition(dto);
  }

  @Get('nearby/search')
  @ApiOperation({ summary: 'Buscar dispositivos dentro de un radio geográfico (PostGIS)' })
  @ApiResponse({ status: 200, description: 'Dispositivos encontrados con su distancia' })
  async findNearby(
    @Query('latitude') latitude: number,
    @Query('longitude') longitude: number,
    @Query('radiusMeters') radiusMeters: number = 5000,
  ) {
    return this.devicesService.findNearby(Number(latitude), Number(longitude), Number(radiusMeters));
  }
}
