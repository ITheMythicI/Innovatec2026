import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { IsEnum, IsInt, IsNumber, IsOptional, Max, Min } from 'class-validator';
import { ReportCategory, ReportPriority, ReportStatus } from '@prisma/client';

export class ReportNearbyQueryDto {
  @ApiProperty({ description: 'Latitud del punto de consulta (-90 a 90)', example: 19.4326 })
  @Type(() => Number)
  @IsNumber()
  @Min(-90)
  @Max(90)
  latitude: number;

  @ApiProperty({ description: 'Longitud del punto de consulta (-180 a 180)', example: -99.1332 })
  @Type(() => Number)
  @IsNumber()
  @Min(-180)
  @Max(180)
  longitude: number;

  @ApiPropertyOptional({ description: 'Radio de búsqueda en metros (por defecto 5000 = 5km)', example: 5000 })
  @Type(() => Number)
  @IsNumber()
  @Min(1)
  @IsOptional()
  radiusMeters?: number = 5000;

  @ApiPropertyOptional({ enum: ReportStatus, description: 'Filtrar por estado' })
  @IsEnum(ReportStatus)
  @IsOptional()
  status?: ReportStatus;

  @ApiPropertyOptional({ enum: ReportCategory, description: 'Filtrar por categoría' })
  @IsEnum(ReportCategory)
  @IsOptional()
  category?: ReportCategory;

  @ApiPropertyOptional({ enum: ReportPriority, description: 'Filtrar por prioridad' })
  @IsEnum(ReportPriority)
  @IsOptional()
  priority?: ReportPriority;

  @ApiPropertyOptional({ description: 'Límite de resultados (1-100)', default: 50 })
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  @IsOptional()
  limit?: number = 50;
}
