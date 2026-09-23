import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsISO8601, IsNotEmpty, IsOptional, IsString, IsUUID } from 'class-validator';

export class CreateShelterStayDto {
  @ApiProperty({ description: 'ID UUID de la persona a registrar', example: 'd3b07384-d113-4ec6-8d5c-d34526d11001' })
  @IsUUID()
  @IsNotEmpty()
  personId: string;

  @ApiPropertyOptional({ description: 'Cama o módulo asignado', example: 'Cama B-12' })
  @IsString()
  @IsOptional()
  assignedBed?: string;

  @ApiPropertyOptional({ description: 'Observaciones médicas o familiares al ingreso', example: 'Ingresa con requerimiento de insulina' })
  @IsString()
  @IsOptional()
  notes?: string;

  @ApiPropertyOptional({ description: 'Fecha y hora UTC de ingreso ISO 8601' })
  @IsISO8601()
  @IsOptional()
  checkInDate?: string;
}
