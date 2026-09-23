import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  Query,
  ParseUUIDPipe,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiQuery,
} from '@nestjs/swagger';
import { GeographyService } from './geography.service';
import { CreatePoiDto } from './dto/create-poi.dto';
import { UpdatePoiDto } from './dto/update-poi.dto';
import { PoiNearbyQueryDto } from './dto/poi-nearby-query.dto';
import { CreateRiskZoneDto } from './dto/create-risk-zone.dto';
import { UpdateRiskZoneDto } from './dto/update-risk-zone.dto';
import { EvaluateSafetyDto } from './dto/evaluate-safety.dto';
import { PoiCategory, PoiStatus, RiskLevel, HazardType } from '@prisma/client';

@ApiTags('Geography')
@Controller('geography')
export class GeographyController {
  constructor(private readonly geographyService: GeographyService) {}

  // ─────────────────────────────────────────────
  // Points of Interest
  // ─────────────────────────────────────────────

  @Post('pois')
  @ApiOperation({ summary: 'Crear un punto de interés' })
  @ApiResponse({ status: 201, description: 'POI creado exitosamente' })
  createPoi(@Body() dto: CreatePoiDto) {
    return this.geographyService.createPoi(dto);
  }

  @Get('pois')
  @ApiOperation({ summary: 'Listar todos los puntos de interés' })
  @ApiQuery({ name: 'category', enum: PoiCategory, required: false })
  @ApiQuery({ name: 'status', enum: PoiStatus, required: false })
  findAllPois(
    @Query('category') category?: PoiCategory,
    @Query('status') status?: PoiStatus,
  ) {
    return this.geographyService.findAllPois({ category, status });
  }

  @Get('pois/nearby')
  @ApiOperation({ summary: 'Buscar POIs cercanos a una coordenada (PostGIS)' })
  findNearbyPois(@Query() query: PoiNearbyQueryDto) {
    return this.geographyService.findNearbyPois(query);
  }

  @Get('pois/:id')
  @ApiOperation({ summary: 'Obtener un POI por ID' })
  @ApiResponse({ status: 404, description: 'POI no encontrado' })
  findPoiById(@Param('id', ParseUUIDPipe) id: string) {
    return this.geographyService.findPoiById(id);
  }

  @Patch('pois/:id')
  @ApiOperation({ summary: 'Actualizar un POI' })
  @ApiResponse({ status: 404, description: 'POI no encontrado' })
  updatePoi(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdatePoiDto,
  ) {
    return this.geographyService.updatePoi(id, dto);
  }

  @Delete('pois/:id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Eliminar un POI' })
  @ApiResponse({ status: 204, description: 'POI eliminado' })
  @ApiResponse({ status: 404, description: 'POI no encontrado' })
  removePoi(@Param('id', ParseUUIDPipe) id: string) {
    return this.geographyService.removePoi(id);
  }

  // ─────────────────────────────────────────────
  // Risk Zones
  // ─────────────────────────────────────────────

  @Post('risk-zones')
  @ApiOperation({ summary: 'Crear una zona de riesgo con geometría GeoJSON' })
  @ApiResponse({ status: 201, description: 'Zona de riesgo creada' })
  createRiskZone(@Body() dto: CreateRiskZoneDto) {
    return this.geographyService.createRiskZone(dto);
  }

  @Get('risk-zones')
  @ApiOperation({ summary: 'Listar zonas de riesgo' })
  @ApiQuery({ name: 'active', type: Boolean, required: false })
  @ApiQuery({ name: 'riskLevel', enum: RiskLevel, required: false })
  @ApiQuery({ name: 'hazardType', enum: HazardType, required: false })
  findAllRiskZones(
    @Query('active') active?: string,
    @Query('riskLevel') riskLevel?: RiskLevel,
    @Query('hazardType') hazardType?: HazardType,
  ) {
    const activeFilter =
      active === 'true' ? true : active === 'false' ? false : undefined;
    return this.geographyService.findAllRiskZones({
      active: activeFilter,
      riskLevel,
      hazardType,
    });
  }

  @Get('risk-zones/check')
  @ApiOperation({
    summary: 'Verificar si un punto está dentro de zonas de riesgo activas',
  })
  @ApiQuery({ name: 'latitude', type: Number })
  @ApiQuery({ name: 'longitude', type: Number })
  checkRiskZones(
    @Query('latitude') latitude: string,
    @Query('longitude') longitude: string,
  ) {
    return this.geographyService.checkRiskZones(
      parseFloat(latitude),
      parseFloat(longitude),
    );
  }

  @Get('risk-zones/:id')
  @ApiOperation({ summary: 'Obtener una zona de riesgo por ID' })
  @ApiResponse({ status: 404, description: 'Zona de riesgo no encontrada' })
  findRiskZoneById(@Param('id', ParseUUIDPipe) id: string) {
    return this.geographyService.findRiskZoneById(id);
  }

  @Patch('risk-zones/:id')
  @ApiOperation({ summary: 'Actualizar una zona de riesgo' })
  @ApiResponse({ status: 404, description: 'Zona de riesgo no encontrada' })
  updateRiskZone(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateRiskZoneDto,
  ) {
    return this.geographyService.updateRiskZone(id, dto);
  }

  @Delete('risk-zones/:id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Eliminar una zona de riesgo' })
  @ApiResponse({ status: 204, description: 'Zona eliminada' })
  @ApiResponse({ status: 404, description: 'Zona no encontrada' })
  removeRiskZone(@Param('id', ParseUUIDPipe) id: string) {
    return this.geographyService.removeRiskZone(id);
  }

  // ─────────────────────────────────────────────
  // Safety Evaluation
  // ─────────────────────────────────────────────

  @Post('evaluate-safety')
  @ApiOperation({
    summary:
      'Evaluación de seguridad de un punto: zonas de riesgo, emergencias activas, albergues y POIs más cercanos',
  })
  @ApiResponse({ status: 200, description: 'Resultado de evaluación de seguridad' })
  evaluateSafety(@Body() dto: EvaluateSafetyDto) {
    return this.geographyService.evaluateSafety(dto);
  }
}
