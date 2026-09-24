import {
  Injectable,
  CanActivate,
  ExecutionContext,
  UnauthorizedException,
  ForbiddenException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { AppRole } from '@prisma/client';

/**
 * Guard exclusivo para módulos administrativos del dashboard.
 * Rechaza cualquier token con appRole = USER (ciudadanos).
 * Los endpoints del módulo Admin SOLO son accesibles para:
 * VIEWER, OPERATOR, COMMANDER y SUPER_ADMIN.
 */
@Injectable()
export class AdminGuard implements CanActivate {
  private readonly adminRoles = new Set<AppRole>([
    AppRole.VIEWER,
    AppRole.OPERATOR,
    AppRole.COMMANDER,
    AppRole.SUPER_ADMIN,
  ]);

  constructor(private readonly jwtService: JwtService) {}

  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest();
    const authHeader = request.headers['authorization'];

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw new UnauthorizedException('Token de acceso administrativo requerido');
    }

    try {
      const token = authHeader.slice(7);
      const payload = this.jwtService.verify(token);
      request.user = payload;

      if (!this.adminRoles.has(payload.appRole)) {
        throw new ForbiddenException(
          'Acceso denegado. Esta área es exclusiva para personal autorizado del centro de mando.',
        );
      }

      return true;
    } catch (err) {
      if (err instanceof ForbiddenException) throw err;
      throw new UnauthorizedException('Token inválido o expirado');
    }
  }
}
