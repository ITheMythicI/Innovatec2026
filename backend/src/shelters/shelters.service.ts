import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateShelterDto } from './dto/create-shelter.dto';
import { UpdateShelterDto } from './dto/update-shelter.dto';
import { ShelterNearbyQueryDto } from './dto/shelter-nearby-query.dto';
import { AddShelterServiceDto } from './dto/add-shelter-service.dto';
import { CreateShelterStayDto } from './dto/create-shelter-stay.dto';
import { Prisma, ShelterServiceType, ShelterStatus, ShelterStayStatus } from '@prisma/client';

@Injectable()
export class SheltersService {
  constructor(private readonly prisma: PrismaService) {}

  async create(dto: CreateShelterDto) {
    return this.prisma.shelter.create({
      data: {
        name: dto.name,
        address: dto.address,
        latitude: dto.latitude,
        longitude: dto.longitude,
        capacity: dto.capacity,
        currentOccupancy: dto.currentOccupancy || 0,
        status: dto.status || ShelterStatus.OPEN,
        contactName: dto.contactName,
        contactPhone: dto.contactPhone,
        managedBy: dto.managedBy,
      },
    });
  }

  async findAll(filters?: {
    status?: ShelterStatus;
    onlyAvailable?: boolean;
    limit?: number;
  }) {
    const where: Prisma.ShelterWhereInput = {};
    if (filters?.status) where.status = filters.status;
    if (filters?.onlyAvailable) {
      // OPEN status already signals available capacity (auto-set to FULL when currentOccupancy >= capacity)
      where.status = ShelterStatus.OPEN;
    }

    const shelters = await this.prisma.shelter.findMany({
      where,
      take: filters?.limit ? Number(filters.limit) : 50,
      orderBy: { name: 'asc' },
      include: {
        services: true,
        _count: { select: { stays: true } },
      },
    });

    return shelters.map((s) => ({
      ...s,
      occupancyPercentage: s.capacity > 0 ? Number(((s.currentOccupancy / s.capacity) * 100).toFixed(1)) : 0,
      availableBeds: Math.max(0, s.capacity - s.currentOccupancy),
    }));
  }

  async findById(id: string) {
    const shelter = await this.prisma.shelter.findUnique({
      where: { id },
      include: {
        services: true,
        stays: {
          where: { status: ShelterStayStatus.ACTIVE },
          include: { person: true },
          take: 50,
        },
      },
    });

    if (!shelter) {
      throw new NotFoundException(`Albergue con ID ${id} no encontrado`);
    }

    return {
      ...shelter,
      occupancyPercentage: shelter.capacity > 0 ? Number(((shelter.currentOccupancy / shelter.capacity) * 100).toFixed(1)) : 0,
      availableBeds: Math.max(0, shelter.capacity - shelter.currentOccupancy),
    };
  }

  async update(id: string, dto: UpdateShelterDto) {
    await this.findById(id);

    return this.prisma.shelter.update({
      where: { id },
      data: {
        name: dto.name,
        address: dto.address,
        latitude: dto.latitude,
        longitude: dto.longitude,
        capacity: dto.capacity,
        currentOccupancy: dto.currentOccupancy,
        status: dto.status,
        contactName: dto.contactName,
        contactPhone: dto.contactPhone,
        managedBy: dto.managedBy,
      },
    });
  }

  async remove(id: string) {
    await this.findById(id);
    return this.prisma.shelter.delete({ where: { id } });
  }

  /**
   * Consulta espacial con PostGIS: Retorna los albergues más cercanos al punto dado,
   * calculando la distancia geodésica en metros y porcentaje de ocupación.
   */
  async findNearby(query: ShelterNearbyQueryDto) {
    const maxDistance = query.maxDistanceMeters || 15000;
    const limit = query.limit || 20;

    let capacityFilter = Prisma.sql``;
    if (query.onlyWithCapacity) {
      capacityFilter = Prisma.sql`AND s.current_occupancy < s.capacity AND s.status = 'OPEN'::"ShelterStatus"`;
    }

    let statusFilter = Prisma.sql``;
    if (query.status) {
      statusFilter = Prisma.sql`AND s.status = ${query.status}::"ShelterStatus"`;
    }

    const results = await this.prisma.$queryRaw<any[]>`
      SELECT 
        s.id,
        s.name,
        s.address,
        s.latitude,
        s.longitude,
        s.capacity,
        s.current_occupancy AS "currentOccupancy",
        s.status,
        s.contact_name AS "contactName",
        s.contact_phone AS "contactPhone",
        s.managed_by AS "managedBy",
        ROUND(((s.current_occupancy::numeric / NULLIF(s.capacity, 0)::numeric) * 100), 1) AS "occupancyPercentage",
        GREATEST(0, s.capacity - s.current_occupancy) AS "availableBeds",
        ROUND(ST_Distance(
          ST_SetSRID(ST_MakePoint(s.longitude, s.latitude), 4326)::geography,
          ST_SetSRID(ST_MakePoint(${query.longitude}, ${query.latitude}), 4326)::geography
        )::numeric, 1) AS "distanceMeters"
      FROM shelters s
      WHERE ST_DWithin(
        ST_SetSRID(ST_MakePoint(s.longitude, s.latitude), 4326)::geography,
        ST_SetSRID(ST_MakePoint(${query.longitude}, ${query.latitude}), 4326)::geography,
        ${maxDistance}
      )
      ${capacityFilter}
      ${statusFilter}
      ORDER BY "distanceMeters" ASC
      LIMIT ${limit};
    `;

    return results;
  }

  async addService(shelterId: string, dto: AddShelterServiceDto) {
    await this.findById(shelterId);

    return this.prisma.shelterService.upsert({
      where: {
        shelterId_serviceType: {
          shelterId,
          serviceType: dto.serviceType,
        },
      },
      create: {
        shelterId,
        serviceType: dto.serviceType,
        description: dto.description,
        isAvailable: dto.isAvailable ?? true,
      },
      update: {
        description: dto.description,
        isAvailable: dto.isAvailable ?? true,
      },
    });
  }

  async removeService(shelterId: string, serviceType: ShelterServiceType) {
    await this.findById(shelterId);

    return this.prisma.shelterService.deleteMany({
      where: { shelterId, serviceType },
    });
  }

  /**
   * Registro atómico de ingreso de una persona a un albergue.
   * Incrementa la ocupación y actualiza el estado a FULL si se agota la capacidad.
   */
  async registerStay(shelterId: string, dto: CreateShelterStayDto) {
    const shelter = await this.findById(shelterId);

    if (shelter.status === ShelterStatus.CLOSED) {
      throw new BadRequestException('El albergue se encuentra actualmente CERRADO');
    }

    if (shelter.currentOccupancy >= shelter.capacity) {
      throw new BadRequestException('El albergue ha alcanzado su capacidad máxima');
    }

    return this.prisma.$transaction(async (tx) => {
      const stay = await tx.shelterStay.create({
        data: {
          shelterId,
          personId: dto.personId,
          assignedBed: dto.assignedBed,
          notes: dto.notes,
          checkInDate: dto.checkInDate ? new Date(dto.checkInDate) : undefined,
          status: ShelterStayStatus.ACTIVE,
        },
        include: { person: true },
      });

      const updatedOccupancy = shelter.currentOccupancy + 1;
      const newStatus = updatedOccupancy >= shelter.capacity ? ShelterStatus.FULL : shelter.status;

      await tx.shelter.update({
        where: { id: shelterId },
        data: {
          currentOccupancy: updatedOccupancy,
          status: newStatus,
        },
      });

      return stay;
    });
  }

  /**
   * Registro de egreso de un albergado.
   * Decrementa la ocupación y reabre el albergue si estaba en estado FULL.
   */
  async checkOutStay(stayId: string, notes?: string) {
    const stay = await this.prisma.shelterStay.findUnique({
      where: { id: stayId },
      include: { shelter: true },
    });

    if (!stay) {
      throw new NotFoundException(`Estancia con ID ${stayId} no encontrada`);
    }

    if (stay.status !== ShelterStayStatus.ACTIVE) {
      throw new BadRequestException('La estancia ya no se encuentra activa');
    }

    return this.prisma.$transaction(async (tx) => {
      const updatedStay = await tx.shelterStay.update({
        where: { id: stayId },
        data: {
          status: ShelterStayStatus.CHECKED_OUT,
          checkOutDate: new Date(),
          notes: notes ? `${stay.notes ? stay.notes + ' | ' : ''}${notes}` : stay.notes,
        },
      });

      const newOccupancy = Math.max(0, stay.shelter.currentOccupancy - 1);
      const newStatus =
        stay.shelter.status === ShelterStatus.FULL && newOccupancy < stay.shelter.capacity
          ? ShelterStatus.OPEN
          : stay.shelter.status;

      await tx.shelter.update({
        where: { id: stay.shelterId },
        data: {
          currentOccupancy: newOccupancy,
          status: newStatus,
        },
      });

      return updatedStay;
    });
  }
}
