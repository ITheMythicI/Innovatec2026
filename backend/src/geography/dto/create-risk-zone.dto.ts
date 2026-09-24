import {
  IsString,
  IsNotEmpty,
  IsOptional,
  IsBoolean,
  IsUUID,
  IsObject,
  MaxLength,
} from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { HazardType, RiskLevel } from '@prisma/client';

export class CreateRiskZoneDto {
  @ApiProperty({ example: 'Zona de inundación norte' })
  @IsString()
  @IsNotEmpty()
  @MaxLength(255)
  name: string;

  @ApiProperty({ enum: HazardType })
  @IsNotEmpty()
  hazardType: HazardType | string;

  @ApiProperty({ enum: RiskLevel })
  @IsNotEmpty()
  riskLevel: RiskLevel | string;

  @ApiPropertyOptional({ example: 'Zona propensa a inundaciones en temporada de lluvias' })
  @IsOptional()
  @IsString()
  @MaxLength(2000)
  description?: string;

  @ApiPropertyOptional({
    description: 'GeoJSON Polygon or geometry object',
  })
  @IsOptional()
  geometryGeoJson?: object;

  @ApiPropertyOptional({
    description: 'Alias for geometryGeoJson',
  })
  @IsOptional()
  geometry?: object;

  @ApiPropertyOptional({ default: true })
  @IsOptional()
  @IsBoolean()
  active?: boolean;

  @ApiPropertyOptional({ description: 'ID de la emergencia asociada' })
  @IsOptional()
  @IsUUID()
  emergencyId?: string;
}

