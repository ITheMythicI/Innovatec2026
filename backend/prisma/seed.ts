import { PrismaClient, AppRole, EmergencyType, EmergencySeverity, EmergencyStatus, ShelterStatus, ShelterServiceType } from '@prisma/client';
import * as bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Iniciando sembrado integral táctico...');

  const defaultPassword = 'Password123!';
  const passwordHash = await bcrypt.hash(defaultPassword, 12);

  // 1. USUARIOS
  const usersToSeed = [
    {
      email: 'admin.general@resguardo.gob.mx',
      fullName: 'Gral. Luis Cresencio',
      appRole: AppRole.SUPER_ADMIN,
      tacticalId: 'CMD-01',
      phone: '+525500000001',
    },
    {
      email: 'operador.morales@resguardo.gob.mx',
      fullName: 'Cmdte. J. Morales',
      appRole: AppRole.COMMANDER,
      tacticalId: 'OP-04',
      phone: '+525500000004',
    },
    {
      email: 'operativo.campo@resguardo.gob.mx',
      fullName: 'Oficial R. Garza',
      appRole: AppRole.OPERATOR,
      tacticalId: 'BRIG-12',
      phone: '+525500000012',
    },
    {
      email: 'observador.c5@resguardo.gob.mx',
      fullName: 'Analista M. Torres',
      appRole: AppRole.VIEWER,
      tacticalId: 'OBS-02',
      phone: '+525500000002',
    },
    {
      email: 'ciudadano.prueba@gmail.com',
      fullName: 'Carmen Domínguez Rivera',
      appRole: AppRole.USER,
      tacticalId: null,
      phone: '+525512345678',
    },
  ];

  for (const u of usersToSeed) {
    const user = await prisma.user.upsert({
      where: { email: u.email },
      update: {
        fullName: u.fullName,
        appRole: u.appRole,
        tacticalId: u.tacticalId,
        passwordHash,
      },
      create: {
        email: u.email,
        fullName: u.fullName,
        appRole: u.appRole,
        tacticalId: u.tacticalId,
        passwordHash,
        phone: u.phone,
        isActive: true,
      },
    });
    console.log(`✅ Usuario configurado: [${user.appRole}] ${user.fullName}`);
  }

  // 2. DISPOSITIVOS
  const testDevice = await prisma.device.upsert({
    where: { deviceIdentifier: 'RSG-TEL-1029' },
    update: {
      lastLatitude: 19.4326,
      lastLongitude: -99.1332,
      lastPositionAt: new Date(),
      deviceModel: 'Pixel 8 Pro (Carmen Domínguez)',
    },
    create: {
      deviceIdentifier: 'RSG-TEL-1029',
      deviceModel: 'Pixel 8 Pro (Carmen Domínguez)',
      appVersion: '1.0.0+1',
      lastLatitude: 19.4326,
      lastLongitude: -99.1332,
      lastPositionAt: new Date(),
    },
  });
  console.log(`📱 Dispositivo sembrado: ${testDevice.deviceIdentifier}`);

  // 3. EMERGENCIAS REALES
  const emergenciesToSeed = [
    {
      title: 'Inundación por Desborde de Presa - Sector Norte',
      description: 'Nivel crítico de agua excedente en Río San Jerónimo. Evacuación inmediata a zonas altas.',
      type: EmergencyType.FLOOD,
      severity: EmergencySeverity.CRITICAL,
      status: EmergencyStatus.ACTIVE,
      latitude: 19.4326,
      longitude: -99.1332,
      radiusMeters: 1800,
    },
    {
      title: 'Sismo Magnitud 6.8 - Sector Cuauhtémoc',
      description: 'Revisión estructural en curso. Puesto de mando militar establecido en Explanada Central.',
      type: EmergencyType.EARTHQUAKE,
      severity: EmergencySeverity.HIGH,
      status: EmergencyStatus.ACTIVE,
      latitude: 19.4285,
      longitude: -99.1456,
      radiusMeters: 2500,
    },
  ];

  for (const em of emergenciesToSeed) {
    const existing = await prisma.emergency.findFirst({ where: { title: em.title } });
    if (!existing) {
      const createdEm = await prisma.emergency.create({
        data: {
          title: em.title,
          description: em.description,
          type: em.type,
          severity: em.severity,
          status: em.status,
          latitude: em.latitude,
          longitude: em.longitude,
          radiusMeters: em.radiusMeters,
          startedAt: new Date(),
        },
      });
      console.log(`🚨 Emergencia sembrada: ${createdEm.title}`);
    }
  }

  // 4. ALBERGUES REALES
  const sheltersToSeed = [
    {
      name: 'Gimnasio Benito Juárez',
      address: 'Av. Cuauhtémoc #450, Col. Narvarte',
      latitude: 19.4385,
      longitude: -99.1310,
      capacity: 250,
      currentOccupancy: 85,
      status: ShelterStatus.OPEN,
      contactName: 'Cmdte. J. Morales',
      contactPhone: '+525500000004',
      managedBy: 'Protección Civil / SEDENA',
      services: [
        ShelterServiceType.MEDICAL,
        ShelterServiceType.FOOD,
        ShelterServiceType.WATER,
        ShelterServiceType.ELECTRICITY,
        ShelterServiceType.PETS_ALLOWED,
      ],
    },
    {
      name: 'Centro Deportivo Olímpico Chapultepec',
      address: 'Calz. Chivatito s/n, 1ra Secc. Bosque de Chapultepec',
      latitude: 19.4215,
      longitude: -99.1820,
      capacity: 500,
      currentOccupancy: 120,
      status: ShelterStatus.OPEN,
      contactName: 'Dr. Roberto Mendoza',
      contactPhone: '+525555123456',
      managedBy: 'Cruz Roja Mexicana',
      services: [
        ShelterServiceType.MEDICAL,
        ShelterServiceType.FOOD,
        ShelterServiceType.WATER,
        ShelterServiceType.WIFI_COMMUNICATION,
      ],
    },
    {
      name: 'Explanada Secundaria Técnica #14',
      address: 'Calle República de Cuba #88, Centro Histórico',
      latitude: 19.4350,
      longitude: -99.1360,
      capacity: 150,
      currentOccupancy: 40,
      status: ShelterStatus.OPEN,
      contactName: 'Oficial R. Garza',
      contactPhone: '+525500000012',
      managedBy: 'Secretaría de Seguridad Ciudadana',
      services: [
        ShelterServiceType.FOOD,
        ShelterServiceType.WATER,
        ShelterServiceType.PSYCHOLOGICAL_SUPPORT,
      ],
    },
  ];

  for (const sh of sheltersToSeed) {
    const existing = await prisma.shelter.findFirst({ where: { name: sh.name } });
    if (!existing) {
      const shelter = await prisma.shelter.create({
        data: {
          name: sh.name,
          address: sh.address,
          latitude: sh.latitude,
          longitude: sh.longitude,
          capacity: sh.capacity,
          currentOccupancy: sh.currentOccupancy,
          status: sh.status,
          contactName: sh.contactName,
          contactPhone: sh.contactPhone,
          managedBy: sh.managedBy,
          services: {
            create: sh.services.map((svc) => ({
              serviceType: svc,
              isAvailable: true,
            })),
          },
        },
      });
      console.log(`⛺ Albergue sembrado: ${shelter.name} (${shelter.currentOccupancy}/${shelter.capacity} personas)`);
    }
  }

  console.log('✨ Sembrado integral de Fase 1 finalizado con éxito.');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
