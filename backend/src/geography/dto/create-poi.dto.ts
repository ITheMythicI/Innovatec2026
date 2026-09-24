import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsEnum, IsNotEmpty, IsNumber, IsOptional, IsString, Max, Min } from 'class-validator';
import { PoiCategory, PoiStatus } from '@prisma/client';

export class CreatePoiDto {
  @ApiProperty({ description: 'Nombre del punto de interés', example: 'Hospital General Dr. Balmis' })
  @IsString()
  @IsNotEmpty()
  name: string;

  @ApiProperty({ enum: PoiCategory, example: PoiCategory.HOSPITAL })
  @IsEnum(PoiCategory)
  category: PoiCategory;

  @ApiPropertyOptional({ enum: PoiStatus, default: PoiStatus.OPERATIONAL, example: PoiStatus.OPERATIONAL })
  @IsEnum(PoiStatus)
  @IsOptional()
  status?: PoiStatus;

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

  @ApiPropertyOptional({ description: 'Dirección física', example: 'Dr. Pasteur s/n, Doctores' })
  @IsString()
  @IsOptional()
  address?: string;

  @ApiPropertyOptional({ description: 'Teléfono de contacto o emergencias' })
  @IsString()
  @IsOptional()
  contactPhone?: string;

  @ApiPropertyOptional({ description: 'Descripción o servicios clave disponibles' })
  @IsString()
  @IsOptional()
  description?: string;
}
