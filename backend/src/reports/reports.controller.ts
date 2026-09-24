import { Controller, Get, Post, Patch, Delete, Body, Param, Query, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiQuery } from '@nestjs/swagger';
import { ReportsService } from './reports.service';
import { CreateReportDto } from './dto/create-report.dto';
import { UpdateReportStatusDto } from './dto/update-report-status.dto';
import { ReportNearbyQueryDto } from './dto/report-nearby-query.dto';
import { ReportCategory, ReportPriority, ReportStatus } from '@prisma/client';

@ApiTags('Reports')
@Controller('reports')
export class ReportsController {
  constructor(private readonly reportsService: ReportsService) {}

  @Post()
  @ApiOperation({ summary: 'Crear un reporte ciudadano o de brigada en campo' })
  @ApiResponse({ status: 201, description: 'Reporte registrado exitosamente' })
  async create(@Body() dto: CreateReportDto) {
    return this.reportsService.create(dto);
  }

  @Get()
  @ApiOperation({ summary: 'Listar reportes con filtros opcionales' })
  @ApiQuery({ name: 'status', enum: ReportStatus, required: false })
  @ApiQuery({ name: 'category', enum: ReportCategory, required: false })
  @ApiQuery({ name: 'priority', enum: ReportPriority, required: false })
  @ApiQuery({ name: 'emergencyId', type: String, required: false })
  @ApiQuery({ name: 'limit', type: Number, required: false })
  @ApiResponse({ status: 200, description: 'Lista de reportes' })
  async findAll(
    @Query('status') status?: ReportStatus,
    @Query('category') category?: ReportCategory,
    @Query('priority') priority?: ReportPriority,
    @Query('emergencyId') emergencyId?: string,
    @Query('limit') limit?: number,
  ) {
    return this.reportsService.findAll({ status, category, priority, emergencyId, limit });
  }

  @Get('nearby')
  @ApiOperation({ summary: 'Buscar reportes cercanos dentro de un radio geodésico (PostGIS)' })
  @ApiResponse({ status: 200, description: 'Reportes cercanos ordenados por distancia' })
  async findNearby(@Query() query: ReportNearbyQueryDto) {
    return this.reportsService.findNearby(query);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Obtener información detallada de un reporte' })
  @ApiResponse({ status: 200, description: 'Reporte encontrado' })
  @ApiResponse({ status: 404, description: 'Reporte no encontrado' })
  async findById(@Param('id') id: string) {
    return this.reportsService.findById(id);
  }

  @Patch(':id/status')
  @ApiOperation({ summary: 'Verificar o cambiar el estado de un reporte (PENDING, VERIFIED, RESOLVED, etc.)' })
  @ApiResponse({ status: 200, description: 'Estado actualizado' })
  async updateStatus(@Param('id') id: string, @Body() dto: UpdateReportStatusDto) {
    return this.reportsService.updateStatus(id, dto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Eliminar un reporte' })
  @ApiResponse({ status: 204, description: 'Reporte eliminado' })
  async remove(@Param('id') id: string) {
    return this.reportsService.remove(id);
  }
}
