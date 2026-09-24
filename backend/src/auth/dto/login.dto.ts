import { IsEmail, IsString, MinLength, IsNotEmpty } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class LoginDto {
  @ApiProperty({ example: 'operador.morales@resguardo.gob.mx' })
  @IsEmail()
  email: string;

  @ApiProperty({ example: '••••••••••••' })
  @IsString()
  @IsNotEmpty()
  @MinLength(8)
  password: string;
}
