import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { EmergencyStatus, ShelterStatus, ReportStatus, AppRole } from '@prisma/client';

@Injectable()
export class AdminService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Resumen ejecutivo del dashboard — polling cada 30s desde el panel principal.
   * Incluye indicador de frescura para que el dashboard muestre el badge correcto.
   */
  async getDashboardSummary() {
    const [
      activeEmergencies,
      totalShelters,
      openShelters,
      totalPeople,
      pendingReports,
      activeReports,
      devicesWithPosition,
      devicesTotal,
      topShelters,
      recentEmergencies,
    ] = await Promise.all([
      this.prisma.emergency.count({ where: { status: EmergencyStatus.ACTIVE } }),
      this.prisma.shelter.count(),
      this.prisma.shelter.count({ where: { status: ShelterStatus.OPEN } }),
      this.prisma.person.count({ where: { status: { not: 'DECEASED' } } }),
      this.prisma.report.count({ where: { status: ReportStatus.PENDING } }),
      this.prisma.report.count({
        where: { status: { in: [ReportStatus.PENDING, ReportStatus.IN_PROGRESS] } },
      }),
      this.prisma.device.count({
        where: { lastPositionAt: { not: null } },
      }),
      this.prisma.device.count(),
      // Top 3 albergues más llenos
      this.prisma.shelter.findMany({
        where: { status: { in: [ShelterStatus.OPEN, ShelterStatus.FULL] } },
        orderBy: { currentOccupancy: 'desc' },
        take: 3,
        select: {
          id: true,
          name: true,
          capacity: true,
          currentOccupancy: true,
          status: true,
          updatedAt: true,
        },
      }),
      // Últimas 5 emergencias activas
      this.prisma.emergency.findMany({
        where: { status: EmergencyStatus.ACTIVE },
        orderBy: { createdAt: 'desc' },
        take: 5,
        select: {
          id: true,
          title: true,
          type: true,
          severity: true,
          latitude: true,
          longitude: true,
          radiusMeters: true,
          startedAt: true,
          updatedAt: true,
        },
      }),
    ]);

    // Ocupación total en albergues abiertos
    const shelterOccupancyData = await this.prisma.shelter.aggregate({
      where: { status: { in: [ShelterStatus.OPEN, ShelterStatus.FULL] } },
      _sum: { currentOccupancy: true, capacity: true },
    });

    const totalOccupancy = shelterOccupancyData._sum.currentOccupancy ?? 0;
    const totalCapacity = shelterOccupancyData._sum.capacity ?? 1;
    const occupancyPercentage = Math.round((totalOccupancy / totalCapacity) * 100);

    return {
      generatedAt: new Date().toISOString(),
      emergencies: {
        active: activeEmergencies,
        recent: recentEmergencies.map((e) => ({
          ...e,
          dataFreshness: this.freshness(e.updatedAt),
        })),
      },
      shelters: {
        total: totalShelters,
        open: openShelters,
        full: totalShelters - openShelters,
        totalOccupancy,
        totalCapacity,
        occupancyPercentage,
        top: topShelters.map((s) => ({
          ...s,
          occupancyPercentage: s.capacity > 0
            ? Math.round((s.currentOccupancy / s.capacity) * 100)
            : 0,
          dataFreshness: this.freshness(s.updatedAt),
        })),
      },
      reports: {
        pending: pendingReports,
        active: activeReports,
      },
      people: {
        registered: totalPeople,
      },
      devices: {
        total: devicesTotal,
        withPosition: devicesWithPosition,
        positionCoverage: devicesTotal > 0
          ? Math.round((devicesWithPosition / devicesTotal) * 100)
          : 0,
      },
    };
  }

  /**
   * Métricas de analítica de crisis — usado por la pantalla de métricas del dashboard.
   */
  async getAnalytics() {
    const [emergenciesByType, emergenciesBySeverity, reportsByCategory, shelterStats] =
      await Promise.all([
        this.prisma.emergency.groupBy({
          by: ['type'],
          _count: { _all: true },
          orderBy: { _count: { type: 'desc' } },
        }),
        this.prisma.emergency.groupBy({
          by: ['severity'],
          _count: { _all: true },
        }),
        this.prisma.report.groupBy({
          by: ['category'],
          _count: { _all: true },
          orderBy: { _count: { category: 'desc' } },
        }),
        this.prisma.shelter.findMany({
          select: {
            id: true,
            name: true,
            capacity: true,
            currentOccupancy: true,
            status: true,
            services: { select: { serviceType: true, isAvailable: true } },
            updatedAt: true,
          },
        }),
      ]);

    return {
      generatedAt: new Date().toISOString(),
      emergencies: {
        byType: emergenciesByType.map((e) => ({
          type: e.type,
          count: e._count._all,
        })),
        bySeverity: emergenciesBySeverity.map((e) => ({
          severity: e.severity,
          count: e._count._all,
        })),
      },
      reports: {
        byCategory: reportsByCategory.map((r) => ({
          category: r.category,
          count: r._count._all,
        })),
      },
      shelters: shelterStats.map((s) => ({
        id: s.id,
        name: s.name,
        capacity: s.capacity,
        currentOccupancy: s.currentOccupancy,
        occupancyPercentage:
          s.capacity > 0
            ? Math.round((s.currentOccupancy / s.capacity) * 100)
            : 0,
        status: s.status,
        services: s.services,
        dataFreshness: this.freshness(s.updatedAt),
      })),
    };
  }

  /**
   * Lista de usuarios administrativos (para gestión por SUPER_ADMIN).
   */
  async getAdminUsers() {
    return this.prisma.user.findMany({
      where: {
        appRole: {
          in: [AppRole.SUPER_ADMIN, AppRole.COMMANDER, AppRole.OPERATOR, AppRole.VIEWER],
        },
        isActive: true,
      },
      select: {
        id: true,
        email: true,
        fullName: true,
        appRole: true,
        tacticalId: true,
        createdAt: true,
        updatedAt: true,
      },
      orderBy: [{ appRole: 'asc' }, { fullName: 'asc' }],
    });
  }

  // ─── Helper: indicador de frescura de datos ──────────────────────────────
  private freshness(updatedAt: Date): 'FRESH' | 'STALE' | 'UNKNOWN' {
    if (!updatedAt) return 'UNKNOWN';
    const ageMs = Date.now() - new Date(updatedAt).getTime();
    if (ageMs < 5 * 60 * 1000) return 'FRESH';       // < 5 min
    if (ageMs < 30 * 60 * 1000) return 'STALE';      // 5-30 min
    return 'UNKNOWN';                                  // > 30 min
  }
}
