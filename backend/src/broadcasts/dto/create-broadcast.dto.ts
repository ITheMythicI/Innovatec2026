import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsEnum,
  IsLatitude,
  IsLongitude,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
  Min,
} from 'class-validator';
import { AppRole, BroadcastTarget, BroadcastType } from '@prisma/client';

export class CreateBroadcastDto {
  @ApiProperty({ description: 'Título o encabezado de la alerta/comunicado', example: 'ALERTA DE EVACUACIÓN INMEDIATA' })
  @IsString()
  @IsNotEmpty()
  title: string;

  @ApiProperty({ description: 'Cuerpo del mensaje detallado', example: 'Se reporta riesgo de desbordamiento en Río San Juan. Diríjase a los albergues designados.' })
  @IsString()
  @IsNotEmpty()
  body: string;

  @ApiProperty({ enum: BroadcastType, example: BroadcastType.EVACUATION })
  @IsEnum(BroadcastType)
  type: BroadcastType;

  @ApiProperty({ enum: BroadcastTarget, example: BroadcastTarget.GEOGRAPHIC, default: BroadcastTarget.GLOBAL })
  @IsEnum(BroadcastTarget)
  targetMode: BroadcastTarget;

  @ApiPropertyOptional({ enum: AppRole, description: 'Solo si targetMode es ROLE' })
  @IsEnum(AppRole)
  @IsOptional()
  targetRole?: AppRole;

  @ApiPropertyOptional({ description: 'Latitud del centro geográfico (requerido si targetMode = GEOGRAPHIC)', example: 19.4326 })
  @IsLatitude()
  @IsOptional()
  geoLatitude?: number;

  @ApiPropertyOptional({ description: 'Longitud del centro geográfico (requerido si targetMode = GEOGRAPHIC)', example: -99.1332 })
  @IsLongitude()
  @IsOptional()
  geoLongitude?: number;

  @ApiPropertyOptional({ description: 'Radio en metros del área de cobertura (ej. 3000m)', example: 3000 })
  @IsNumber()
  @Min(50)
  @IsOptional()
  geoRadiusMeters?: number;

  @ApiPropertyOptional({ description: 'Fecha programada de emisión (opcional)', example: '2026-09-24T12:00:00.000Z' })
  @IsOptional()
  scheduledAt?: Date;
}
