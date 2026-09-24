import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsEnum, IsInt, IsNotEmpty, IsNumber, IsOptional, IsString, Max, Min } from 'class-validator';
import { ShelterStatus } from '@prisma/client';

export class CreateShelterDto {
  @ApiProperty({ description: 'Nombre del albergue o refugio', example: 'Albergue Deportivo Benito Juárez' })
  @IsString()
  @IsNotEmpty()
  name: string;

  @ApiPropertyOptional({ description: 'Dirección física', example: 'Av. Cuauhtémoc 1234, Col. Narvarte' })
  @IsString()
  @IsOptional()
  address?: string;

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

  @ApiPropertyOptional({ description: 'Capacidad máxima de personas', example: 250 })
  @IsInt()
  @Min(1)
  @IsOptional()
  capacity?: number;

  @ApiPropertyOptional({ description: 'Alias de capacidad total', example: 250 })
  @IsInt()
  @Min(1)
  @IsOptional()
  totalCapacity?: number;

  @ApiPropertyOptional({ description: 'Ocupación actual', default: 0, example: 20 })
  @IsInt()
  @Min(0)
  @IsOptional()
  currentOccupancy?: number;

  @ApiPropertyOptional({ description: 'Alias de ocupación actual', default: 0, example: 20 })
  @IsInt()
  @Min(0)
  @IsOptional()
  occupancy?: number;

  @ApiPropertyOptional({ enum: ShelterStatus, default: ShelterStatus.OPEN, example: ShelterStatus.OPEN })
  @IsEnum(ShelterStatus)
  @IsOptional()
  status?: ShelterStatus;

  @ApiPropertyOptional({ description: 'Persona o contacto responsable', example: 'Dra. Elena Ramos' })
  @IsString()
  @IsOptional()
  contactName?: string;

  @ApiPropertyOptional({ description: 'Teléfono de contacto o radio', example: '+52 55 1234 5678' })
  @IsString()
  @IsOptional()
  contactPhone?: string;

  @ApiPropertyOptional({ description: 'Institución u organización administradora', example: 'Cruz Roja Mexicana' })
  @IsString()
  @IsOptional()
  managedBy?: string;
}
