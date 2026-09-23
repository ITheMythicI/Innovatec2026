import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsEnum, IsNumber, IsOptional, IsString, Max, Min } from 'class-validator';
import { PoiCategory, PoiStatus } from '@prisma/client';

export class UpdatePoiDto {
  @ApiPropertyOptional({ description: 'Nombre del punto de interés' })
  @IsString()
  @IsOptional()
  name?: string;

  @ApiPropertyOptional({ enum: PoiCategory })
  @IsEnum(PoiCategory)
  @IsOptional()
  category?: PoiCategory;

  @ApiPropertyOptional({ enum: PoiStatus })
  @IsEnum(PoiStatus)
  @IsOptional()
  status?: PoiStatus;

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

  @ApiPropertyOptional({ description: 'Dirección física' })
  @IsString()
  @IsOptional()
  address?: string;

  @ApiPropertyOptional({ description: 'Teléfono de contacto' })
  @IsString()
  @IsOptional()
  contactPhone?: string;

  @ApiPropertyOptional({ description: 'Descripción' })
  @IsString()
  @IsOptional()
  description?: string;
}
