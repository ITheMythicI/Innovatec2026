import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsEnum, IsNotEmpty, IsNumber, IsOptional, IsString, IsUUID, Max, Min } from 'class-validator';
import { ReportCategory, ReportPriority } from '@prisma/client';

export class CreateReportDto {
  @ApiProperty({ description: 'Título del reporte de situación o auxilio', example: 'Derrumbe bloqueando carretera principal' })
  @IsString()
  @IsNotEmpty()
  title: string;

  @ApiProperty({ description: 'Descripción detallada de la situación y requerimientos', example: 'Rocas de gran tamaño impiden el paso de ambulancias hacia la clínica.' })
  @IsString()
  @IsNotEmpty()
  description: string;

  @ApiPropertyOptional({ enum: ReportCategory, default: ReportCategory.OTHER, example: ReportCategory.ROAD_BLOCKED })
  @IsEnum(ReportCategory)
  @IsOptional()
  category?: ReportCategory;

  @ApiPropertyOptional({ enum: ReportPriority, default: ReportPriority.MEDIUM, example: ReportPriority.HIGH })
  @IsEnum(ReportPriority)
  @IsOptional()
  priority?: ReportPriority;

  @ApiPropertyOptional({ description: 'Latitud del incidente (-90 a 90)', example: 19.4326 })
  @IsNumber()
  @Min(-90)
  @Max(90)
  @IsOptional()
  latitude?: number;

  @ApiPropertyOptional({ description: 'Longitud del incidente (-180 a 180)', example: -99.1332 })
  @IsNumber()
  @Min(-180)
  @Max(180)
  @IsOptional()
  longitude?: number;

  @ApiPropertyOptional({ description: 'Dirección o punto de referencia en texto', example: 'Km 14 de la Carretera Federal' })
  @IsString()
  @IsOptional()
  address?: string;

  @ApiPropertyOptional({ description: 'ID de la emergencia asociada si corresponde' })
  @IsUUID()
  @IsOptional()
  emergencyId?: string;

  @ApiPropertyOptional({ description: 'Nombre del reportante (opcional)' })
  @IsString()
  @IsOptional()
  reporterName?: string;

  @ApiPropertyOptional({ description: 'Teléfono o contacto del reportante' })
  @IsString()
  @IsOptional()
  reporterContact?: string;

  @ApiPropertyOptional({ description: 'ID del usuario registrado si está autenticado' })
  @IsUUID()
  @IsOptional()
  reporterUserId?: string;
}
