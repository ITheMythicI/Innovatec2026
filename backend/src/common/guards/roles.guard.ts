import {
  Injectable,
  CanActivate,
  ExecutionContext,
  UnauthorizedException,
  ForbiddenException,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { AppRole } from '@prisma/client';
import { ROLES_KEY } from '../decorators/roles.decorator';

/**
 * Mapa de precedencia de roles (mayor número = más privilegios).
 * Permite validar "rol mínimo requerido" con una sola comparación numérica.
 */
const ROLE_HIERARCHY: Record<AppRole, number> = {
  [AppRole.USER]: 1,
  [AppRole.VIEWER]: 2,
  [AppRole.OPERATOR]: 3,
  [AppRole.COMMANDER]: 4,
  [AppRole.SUPER_ADMIN]: 5,
};

@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const requiredRoles = this.reflector.getAllAndOverride<AppRole[]>(ROLES_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);

    // Si no se especifica @Roles(...), el endpoint es público (debe estar protegido por JwtAuthGuard por separado)
    if (!requiredRoles || requiredRoles.length === 0) {
      return true;
    }

    const request = context.switchToHttp().getRequest();
    const user = request.user;

    if (!user) {
      throw new UnauthorizedException('Token de autenticación requerido');
    }

    const userRoleLevel = ROLE_HIERARCHY[user.appRole as AppRole] ?? 0;

    // El usuario debe tener AL MENOS el nivel del rol requerido más bajo entre los especificados
    const minimumRequiredLevel = Math.min(
      ...requiredRoles.map((r) => ROLE_HIERARCHY[r] ?? 999),
    );

    if (userRoleLevel < minimumRequiredLevel) {
      throw new ForbiddenException(
        `Se requiere rol ${requiredRoles.join(' o ')} o superior. Tu rol actual: ${user.appRole}`,
      );
    }

    return true;
  }
}
