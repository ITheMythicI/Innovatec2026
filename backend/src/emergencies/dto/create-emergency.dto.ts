import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsEnum, IsNotEmpty, IsNumber, IsOptional, IsString, Max, Min, IsISO8601 } from 'class-validator';
import { EmergencySeverity, EmergencyStatus, EmergencyType } from '@prisma/client';

export class CreateEmergencyDto {
  @ApiProperty({ description: 'Título de la emergencia', example: 'Inundación en Sector Ribereño' })
  @IsString()
  @IsNotEmpty()
  title: string;

  @ApiPropertyOptional({ description: 'Descripción detallada', example: 'Desbordamiento del río debido a lluvias torrenciales' })
  @IsString()
  @IsOptional()
  description?: string;

  @ApiPropertyOptional({ enum: EmergencyType, default: EmergencyType.OTHER, example: EmergencyType.FLOOD })
  @IsEnum(EmergencyType)
  @IsOptional()
  type?: EmergencyType;

  @ApiPropertyOptional({ enum: EmergencySeverity, default: EmergencySeverity.MEDIUM, example: EmergencySeverity.HIGH })
  @IsEnum(EmergencySeverity)
  @IsOptional()
  severity?: EmergencySeverity;

  @ApiPropertyOptional({ enum: EmergencyStatus, default: EmergencyStatus.ACTIVE, example: EmergencyStatus.ACTIVE })
  @IsEnum(EmergencyStatus)
  @IsOptional()
  status?: EmergencyStatus;

  @ApiProperty({ description: 'Latitud (-90 a 90)', example: 19.4326 })
  @IsNumber()
  @Min(-90)
  @Max(90)
  latitude: number;

  @ApiProperty({ description: 'Longitud (-180 a 180)', example: -99.1332 })
  @IsNumber()
  @Min(-180)
  @Max(180)
  longitude: number;

  @ApiPropertyOptional({ description: 'Radio de impacto estimado en metros', example: 1500 })
  @IsNumber()
  @Min(0)
  @IsOptional()
  radiusMeters?: number;

  @ApiPropertyOptional({ description: 'Fecha y hora UTC de inicio en formato ISO 8601', example: '2026-09-23T15:00:00.000Z' })
  @IsISO8601()
  @IsOptional()
  startedAt?: string;
}
