import { IsEmail, IsString, MinLength, IsNotEmpty, IsOptional, IsEnum } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { AppRole } from '@prisma/client';

export class RegisterDto {
  @ApiProperty({ example: 'ciudadano@resguardo.gob.mx' })
  @IsEmail()
  email: string;

  @ApiProperty({ example: 'ClaveSegura2026!' })
  @IsString()
  @IsNotEmpty()
  @MinLength(8)
  password: string;

  @ApiProperty({ example: 'Carlos Mendoza Ruiz' })
  @IsString()
  @IsNotEmpty()
  fullName: string;

  @ApiPropertyOptional({ example: '+52 55 9876 5432' })
  @IsString()
  @IsOptional()
  phone?: string;

  @ApiPropertyOptional({ enum: AppRole, default: AppRole.USER })
  @IsEnum(AppRole)
  @IsOptional()
  appRole?: AppRole;

  @ApiPropertyOptional({ example: 'PC-CDMX-4821' })
  @IsString()
  @IsOptional()
  tacticalId?: string;
}
