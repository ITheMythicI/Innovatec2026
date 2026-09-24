import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsLatitude, IsLongitude, IsNotEmpty, IsOptional, IsString } from 'class-validator';

export class UpdateDevicePositionDto {
  @ApiProperty({ description: 'Identificador único del dispositivo (UUID generado por el cliente)', example: 'f3918b95-46aa-4573-98fe-08246bc682a8' })
  @IsString()
  @IsNotEmpty()
  deviceIdentifier: string;

  @ApiProperty({ description: 'Latitud WGS84', example: 19.4326 })
  @IsLatitude()
  latitude: number;

  @ApiProperty({ description: 'Longitud WGS84', example: -99.1332 })
  @IsLongitude()
  longitude: number;

  @ApiPropertyOptional({ description: 'Modelo o nombre del dispositivo', example: 'Samsung Galaxy S23' })
  @IsString()
  @IsOptional()
  deviceModel?: string;

  @ApiPropertyOptional({ description: 'Versión de la aplicación móvil', example: '1.0.0+1' })
  @IsString()
  @IsOptional()
  appVersion?: string;
}
