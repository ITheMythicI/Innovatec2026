import { Controller, Get, Param } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { DevicesService } from './devices.service';

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
}
