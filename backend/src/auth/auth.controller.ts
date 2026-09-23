import { Controller, Post, Body, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { AuthService } from './auth.service';

@ApiTags('Auth')
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('login')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Iniciar sesión (esquema pendiente de implementación completa por el equipo)' })
  @ApiResponse({ status: 200, description: 'Sesión iniciada con éxito y retorno de JWT' })
  async login(@Body() body: any) {
    return {
      message: 'Endpoint de autenticación preparado. Implementar validación de hash y emisión de JWT.',
      received: !!body,
    };
  }

  @Post('refresh')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Renovación de token JWT' })
  async refresh() {
    return { message: 'Endpoint de refresco de token preparado.' };
  }
}
