import { PrismaClient, AppRole } from '@prisma/client';
import * as bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Iniciando sembrado de usuarios tácticos y de prueba...');

  const defaultPassword = 'Password123!';
  const passwordHash = await bcrypt.hash(defaultPassword, 12);

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
    console.log(`✅ Usuario configurado: [${user.appRole}] ${user.fullName} (${user.email}) - Tactical ID: ${user.tacticalId || 'N/A'}`);
  }

  // Registrar un dispositivo inicial de prueba vinculado al prototipo Stitch
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
  console.log(`📱 Dispositivo de prueba sembrado: ${testDevice.deviceIdentifier} (${testDevice.deviceModel})`);

  console.log('✨ Sembrado finalizado con éxito.');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
