import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsEnum, IsInt, IsNumber, IsOptional, IsString, Max, Min } from 'class-validator';
import { ShelterStatus } from '@prisma/client';

export class UpdateShelterDto {
  @ApiPropertyOptional({ description: 'Nombre del albergue' })
  @IsString()
  @IsOptional()
  name?: string;

  @ApiPropertyOptional({ description: 'Dirección física' })
  @IsString()
  @IsOptional()
  address?: string;

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

  @ApiPropertyOptional({ description: 'Capacidad máxima de personas' })
  @IsInt()
  @Min(1)
  @IsOptional()
  capacity?: number;

  @ApiPropertyOptional({ description: 'Ocupación actual' })
  @IsInt()
  @Min(0)
  @IsOptional()
  currentOccupancy?: number;

  @ApiPropertyOptional({ enum: ShelterStatus })
  @IsEnum(ShelterStatus)
  @IsOptional()
  status?: ShelterStatus;

  @ApiPropertyOptional({ description: 'Persona o contacto responsable' })
  @IsString()
  @IsOptional()
  contactName?: string;

  @ApiPropertyOptional({ description: 'Teléfono de contacto' })
  @IsString()
  @IsOptional()
  contactPhone?: string;

  @ApiPropertyOptional({ description: 'Institución administradora' })
  @IsString()
  @IsOptional()
  managedBy?: string;
}
