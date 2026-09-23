import { Controller, Get, Param } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { EmergenciesService } from './emergencies.service';

@ApiTags('Emergencies')
@Controller('emergencies')
export class EmergenciesController {
  constructor(private readonly emergenciesService: EmergenciesService) {}

  @Get()
  @ApiOperation({ summary: 'Listar emergencias e incidentes' })
  @ApiResponse({ status: 200, description: 'Lista de emergencias' })
  async findAll() {
    return this.emergenciesService.findAll();
  }

  @Get(':id')
  @ApiOperation({ summary: 'Obtener detalle de una emergencia' })
  @ApiResponse({ status: 200, description: 'Emergencia encontrada' })
  async findById(@Param('id') id: string) {
    return this.emergenciesService.findById(id);
  }
}
