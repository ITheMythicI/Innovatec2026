import {
  Injectable,
  UnauthorizedException,
  ConflictException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import * as bcrypt from 'bcryptjs';
import { PrismaService } from '../prisma/prisma.service';
import { AppRole } from '@prisma/client';

export interface JwtPayload {
  sub: string;        // userId
  email: string;
  appRole: AppRole;
  fullName: string;
  tacticalId?: string;
  iat?: number;
  exp?: number;
}

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
  ) {}

  // ─── Login ───────────────────────────────────────────────────────────────
  async login(email: string, password: string) {
    const user = await this.prisma.user.findUnique({
      where: { email: email.toLowerCase().trim() },
      select: {
        id: true,
        email: true,
        passwordHash: true,
        fullName: true,
        appRole: true,
        tacticalId: true,
        isActive: true,
      },
    });

    if (!user || !user.isActive) {
      throw new UnauthorizedException('Credenciales inválidas');
    }

    const passwordValid = await bcrypt.compare(password, user.passwordHash);
    if (!passwordValid) {
      throw new UnauthorizedException('Credenciales inválidas');
    }

    return this.issueTokens(user);
  }

  // ─── Registro (usado solo por SUPER_ADMIN para crear operadores) ────────
  async register(data: {
    email: string;
    password: string;
    fullName: string;
    appRole?: AppRole;
    tacticalId?: string;
    phone?: string;
  }) {
    const existing = await this.prisma.user.findUnique({
      where: { email: data.email.toLowerCase().trim() },
    });

    if (existing) {
      throw new ConflictException('El email ya está registrado');
    }

    const passwordHash = await bcrypt.hash(data.password, 12);

    const user = await this.prisma.user.create({
      data: {
        email: data.email.toLowerCase().trim(),
        passwordHash,
        fullName: data.fullName,
        appRole: data.appRole ?? AppRole.USER,
        tacticalId: data.tacticalId,
        phone: data.phone,
        isActive: true,
      },
      select: {
        id: true,
        email: true,
        fullName: true,
        appRole: true,
        tacticalId: true,
        createdAt: true,
      },
    });

    return user;
  }

  // ─── Refresh Token ───────────────────────────────────────────────────────
  async refreshToken(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        email: true,
        fullName: true,
        appRole: true,
        tacticalId: true,
        isActive: true,
      },
    });

    if (!user || !user.isActive) {
      throw new UnauthorizedException('Usuario no encontrado o inactivo');
    }

    return this.issueTokens(user);
  }

  // ─── Validar token (para guards) ────────────────────────────────────────
  async validateUserToken(userId: string) {
    return this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        email: true,
        fullName: true,
        appRole: true,
        isActive: true,
      },
    });
  }

  // ─── Helpers privados ───────────────────────────────────────────────────
  private issueTokens(user: {
    id: string;
    email: string;
    fullName: string;
    appRole: AppRole;
    tacticalId?: string | null;
  }) {
    const payload: JwtPayload = {
      sub: user.id,
      email: user.email,
      appRole: user.appRole,
      fullName: user.fullName,
      ...(user.tacticalId && { tacticalId: user.tacticalId }),
    };

    const accessToken = this.jwtService.sign(payload, {
      expiresIn: (this.configService.get('JWT_EXPIRES_IN', '15m') as any),
    });

    const refreshToken = this.jwtService.sign(
      { sub: user.id },
      {
        secret: this.configService.get('JWT_REFRESH_SECRET', 'refresh_secret'),
        expiresIn: (this.configService.get('JWT_REFRESH_EXPIRES_IN', '8h') as any),
      },
    );

    return {
      accessToken,
      refreshToken,
      expiresIn: 900, // 15 minutos en segundos
      user: {
        id: user.id,
        email: user.email,
        fullName: user.fullName,
        appRole: user.appRole,
        tacticalId: user.tacticalId ?? null,
      },
    };
  }
}
