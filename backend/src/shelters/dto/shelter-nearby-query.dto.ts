import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { IsBoolean, IsEnum, IsInt, IsNumber, IsOptional, Max, Min } from 'class-validator';
import { ShelterStatus } from '@prisma/client';

export class ShelterNearbyQueryDto {
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

  @ApiPropertyOptional({ description: 'Distancia máxima en metros (por defecto 15000 = 15km)', example: 15000 })
  @Type(() => Number)
  @IsNumber()
  @Min(1)
  @IsOptional()
  maxDistanceMeters?: number = 15000;

  @ApiPropertyOptional({ description: 'Filtrar solo albergues con camas/cupos disponibles', example: true })
  @Type(() => Boolean)
  @IsBoolean()
  @IsOptional()
  onlyWithCapacity?: boolean;

  @ApiPropertyOptional({ enum: ShelterStatus, description: 'Filtrar por estado del albergue' })
  @IsEnum(ShelterStatus)
  @IsOptional()
  status?: ShelterStatus;

  @ApiPropertyOptional({ description: 'Límite de resultados (1-100)', default: 20 })
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  @IsOptional()
  limit?: number = 20;
}
