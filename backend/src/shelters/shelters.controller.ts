import { Controller, Get, Param } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { SheltersService } from './shelters.service';

@ApiTags('Shelters')
@Controller('shelters')
export class SheltersController {
  constructor(private readonly sheltersService: SheltersService) {}

  @Get()
  @ApiOperation({ summary: 'Listar albergues y centros de asistencia' })
  @ApiResponse({ status: 200, description: 'Lista de albergues' })
  async findAll() {
    return this.sheltersService.findAll();
  }

  @Get(':id')
  @ApiOperation({ summary: 'Obtener detalle de un albergue (capacidad, servicios y estancias activas)' })
  @ApiResponse({ status: 200, description: 'Albergue encontrado' })
  async findById(@Param('id') id: string) {
    return this.sheltersService.findById(id);
  }
}
