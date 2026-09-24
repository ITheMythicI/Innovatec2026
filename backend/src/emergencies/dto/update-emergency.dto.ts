import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsEnum, IsNumber, IsOptional, IsString, Max, Min, IsISO8601 } from 'class-validator';
import { EmergencySeverity, EmergencyStatus, EmergencyType } from '@prisma/client';

export class UpdateEmergencyDto {
  @ApiPropertyOptional({ description: 'Título de la emergencia' })
  @IsString()
  @IsOptional()
  title?: string;

  @ApiPropertyOptional({ description: 'Descripción detallada' })
  @IsString()
  @IsOptional()
  description?: string;

  @ApiPropertyOptional({ enum: EmergencyType })
  @IsEnum(EmergencyType)
  @IsOptional()
  type?: EmergencyType;

  @ApiPropertyOptional({ enum: EmergencySeverity })
  @IsEnum(EmergencySeverity)
  @IsOptional()
  severity?: EmergencySeverity;

  @ApiPropertyOptional({ enum: EmergencyStatus })
  @IsEnum(EmergencyStatus)
  @IsOptional()
  status?: EmergencyStatus;

  @ApiPropertyOptional({ description: 'Latitud (-90 a 90)' })
  @IsNumber()
  @Min(-90)
  @Max(90)
  @IsOptional()
  latitude?: number;

  @ApiPropertyOptional({ description: 'Longitud (-180 a 180)' })
  @IsNumber()
  @Min(-180)
  @Max(180)
  @IsOptional()
  longitude?: number;

  @ApiPropertyOptional({ description: 'Radio de impacto estimado en metros' })
  @IsNumber()
  @Min(0)
  @IsOptional()
  radiusMeters?: number;

  @ApiPropertyOptional({ description: 'Fecha y hora UTC de finalización ISO 8601' })
  @IsISO8601()
  @IsOptional()
  endedAt?: string;
}
