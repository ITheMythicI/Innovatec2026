import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsISO8601, IsNotEmpty, IsNumber, IsOptional, IsString, Max, Min } from 'class-validator';

export class CreateEmergencyEventDto {
  @ApiProperty({ description: 'Tipo o título del evento', example: 'RÉPLICA_SÍSMICA' })
  @IsString()
  @IsNotEmpty()
  eventType: string;

  @ApiPropertyOptional({ description: 'Descripción o detalles del suceso', example: 'Magnitud 4.5 registrada en el epicentro' })
  @IsString()
  @IsOptional()
  description?: string;

  @ApiPropertyOptional({ description: 'Latitud del sub-evento si difiere del epicentro' })
  @IsNumber()
  @Min(-90)
  @Max(90)
  @IsOptional()
  latitude?: number;

  @ApiPropertyOptional({ description: 'Longitud del sub-evento si difiere del epicentro' })
  @IsNumber()
  @Min(-180)
  @Max(180)
  @IsOptional()
  longitude?: number;

  @ApiPropertyOptional({ description: 'Fecha y hora UTC del evento ISO 8601' })
  @IsISO8601()
  @IsOptional()
  recordedAt?: string;
}
