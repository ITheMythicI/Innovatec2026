import { IsNumber, Min, Max } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';
import { Type } from 'class-transformer';

export class EvaluateSafetyDto {
  @ApiProperty({ example: 19.4326, description: 'Latitud del punto a evaluar' })
  @Type(() => Number)
  @IsNumber()
  @Min(-90)
  @Max(90)
  latitude: number;

  @ApiProperty({ example: -99.1332, description: 'Longitud del punto a evaluar' })
  @Type(() => Number)
  @IsNumber()
  @Min(-180)
  @Max(180)
  longitude: number;
}
