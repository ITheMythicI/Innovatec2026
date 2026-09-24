import {
  Controller,
  Get,
  UseGuards,
  Request,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
} from '@nestjs/swagger';
import { AdminService } from './admin.service';
import { AdminGuard } from '../common/guards/admin.guard';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/decorators/roles.decorator';
import { AppRole } from '@prisma/client';

@ApiTags('Admin — Dashboard')
@ApiBearerAuth()
@UseGuards(AdminGuard, RolesGuard)
@Controller('admin')
export class AdminController {
  constructor(private readonly adminService: AdminService) {}

  @Get('dashboard/summary')
  @Roles(AppRole.VIEWER)  // VIEWER+ (toda la jerarquía admin tiene acceso)
  @ApiOperation({
    summary: 'Resumen ejecutivo del dashboard — polling cada 30s',
    description: 'Retorna métricas clave: emergencias activas, albergues, reportes, dispositivos. Incluye campo dataFreshness (FRESH/STALE/UNKNOWN) por entidad.',
  })
  @ApiResponse({ status: 200, description: 'Métricas del dashboard' })
  @ApiResponse({ status: 401, description: 'Token inválido o ausente' })
  @ApiResponse({ status: 403, description: 'Rol insuficiente (se requiere al menos VIEWER)' })
  getDashboardSummary() {
    return this.adminService.getDashboardSummary();
  }

  @Get('analytics')
  @Roles(AppRole.OPERATOR)  // OPERATOR+
  @ApiOperation({
    summary: 'Analítica de crisis — agrupación de emergencias, reportes y albergues',
    description: 'Datos de analítica para la pantalla de métricas del dashboard. Requiere OPERATOR o superior.',
  })
  getAnalytics() {
    return this.adminService.getAnalytics();
  }

  @Get('users')
  @Roles(AppRole.SUPER_ADMIN)
  @ApiOperation({ summary: 'Listar usuarios administrativos — solo SUPER_ADMIN' })
  getAdminUsers() {
    return this.adminService.getAdminUsers();
  }

  @Get('me')
  @Roles(AppRole.VIEWER)
  @ApiOperation({ summary: 'Perfil del operador autenticado en el dashboard' })
  getProfile(@Request() req: any) {
    return {
      id: req.user.sub,
      email: req.user.email,
      fullName: req.user.fullName,
      appRole: req.user.appRole,
      tacticalId: req.user.tacticalId ?? null,
    };
  }
}
