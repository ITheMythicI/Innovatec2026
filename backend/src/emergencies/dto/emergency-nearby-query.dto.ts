import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { IsEnum, IsInt, IsNumber, IsOptional, Max, Min } from 'class-validator';
import { EmergencySeverity, EmergencyStatus } from '@prisma/client';

export class EmergencyNearbyQueryDto {
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

  @ApiPropertyOptional({ description: 'Radio de búsqueda en metros (por defecto 10000 = 10km)', example: 10000 })
  @Type(() => Number)
  @IsNumber()
  @Min(1)
  @IsOptional()
  radiusMeters?: number = 10000;

  @ApiPropertyOptional({ enum: EmergencyStatus, description: 'Filtrar por estado' })
  @IsEnum(EmergencyStatus)
  @IsOptional()
  status?: EmergencyStatus;

  @ApiPropertyOptional({ enum: EmergencySeverity, description: 'Filtrar por severidad' })
  @IsEnum(EmergencySeverity)
  @IsOptional()
  severity?: EmergencySeverity;

  @ApiPropertyOptional({ description: 'Límite de resultados (1-100)', default: 20 })
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  @IsOptional()
  limit?: number = 20;
}
