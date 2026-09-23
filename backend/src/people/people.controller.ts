import { Controller, Get, Param } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { PeopleService } from './people.service';

@ApiTags('People')
@Controller('people')
export class PeopleController {
  constructor(private readonly peopleService: PeopleService) {}

  @Get()
  @ApiOperation({ summary: 'Listar personas registradas' })
  @ApiResponse({ status: 200, description: 'Lista de personas' })
  async findAll() {
    return this.peopleService.findAll();
  }

  @Get(':id')
  @ApiOperation({ summary: 'Obtener detalle de persona por ID (incluyendo vínculos familiares y albergues)' })
  @ApiResponse({ status: 200, description: 'Persona encontrada' })
  async findById(@Param('id') id: string) {
    return this.peopleService.findById(id);
  }
}
