import { SetMetadata } from '@nestjs/common';
import { AppRole } from '@prisma/client';

export const ROLES_KEY = 'roles';

/**
 * Decorador para requerir un rol mínimo en un endpoint.
 * Uso: @Roles(AppRole.OPERATOR)
 */
export const Roles = (...roles: AppRole[]) => SetMetadata(ROLES_KEY, roles);
