import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsBoolean, IsEnum, IsOptional, IsString } from 'class-validator';
import { ShelterServiceType } from '@prisma/client';

export class AddShelterServiceDto {
  @ApiProperty({ enum: ShelterServiceType, example: ShelterServiceType.MEDICAL })
  @IsEnum(ShelterServiceType)
  serviceType: ShelterServiceType;

  @ApiPropertyOptional({ description: 'Detalle o capacidad del servicio', example: 'Primeros auxilios y medicamentos básicos' })
  @IsString()
  @IsOptional()
  description?: string;

  @ApiPropertyOptional({ description: 'Disponibilidad activa del servicio', default: true })
  @IsBoolean()
  @IsOptional()
  isAvailable?: boolean;
}
