import {
  IsString,
  IsNotEmpty,
  IsEnum,
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
  @IsEnum(HazardType)
  hazardType: HazardType;

  @ApiProperty({ enum: RiskLevel })
  @IsEnum(RiskLevel)
  riskLevel: RiskLevel;

  @ApiPropertyOptional({ example: 'Zona propensa a inundaciones en temporada de lluvias' })
  @IsOptional()
  @IsString()
  @MaxLength(2000)
  description?: string;

  @ApiProperty({
    description: 'GeoJSON Polygon or MultiPolygon geometry',
    example: {
      type: 'Polygon',
      coordinates: [
        [
          [-99.14, 19.43],
          [-99.13, 19.43],
          [-99.13, 19.44],
          [-99.14, 19.44],
          [-99.14, 19.43],
        ],
      ],
    },
  })
  @IsObject()
  @IsNotEmpty()
  geometryGeoJson: object;

  @ApiPropertyOptional({ default: true })
  @IsOptional()
  @IsBoolean()
  active?: boolean;

  @ApiPropertyOptional({ description: 'ID de la emergencia asociada' })
  @IsOptional()
  @IsUUID()
  emergencyId?: string;
}
