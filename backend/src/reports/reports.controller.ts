import { Controller, Get, Param } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { ReportsService } from './reports.service';

@ApiTags('Reports')
@Controller('reports')
export class ReportsController {
  constructor(private readonly reportsService: ReportsService) {}

  @Get()
  @ApiOperation({ summary: 'Listar reportes de situación' })
  @ApiResponse({ status: 200, description: 'Lista de reportes' })
  async findAll() {
    return this.reportsService.findAll();
  }

  @Get(':id')
  @ApiOperation({ summary: 'Obtener información de un reporte por ID' })
  @ApiResponse({ status: 200, description: 'Reporte encontrado' })
  async findById(@Param('id') id: string) {
    return this.reportsService.findById(id);
  }
}
