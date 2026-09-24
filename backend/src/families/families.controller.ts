import { Controller, Get, Param } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { FamiliesService } from './families.service';

@ApiTags('Families')
@Controller('families')
export class FamiliesController {
  constructor(private readonly familiesService: FamiliesService) {}

  @Get()
  @ApiOperation({ summary: 'Listar núcleos familiares' })
  @ApiResponse({ status: 200, description: 'Lista de familias' })
  async findAll() {
    return this.familiesService.findAll();
  }

  @Get(':id')
  @ApiOperation({ summary: 'Obtener información y miembros de una familia' })
  @ApiResponse({ status: 200, description: 'Familia encontrada' })
  async findById(@Param('id') id: string) {
    return this.familiesService.findById(id);
  }
}
