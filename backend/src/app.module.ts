import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { PrismaModule } from './prisma/prisma.module';
import { HealthModule } from './health/health.module';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { PeopleModule } from './people/people.module';
import { FamiliesModule } from './families/families.module';
import { EmergenciesModule } from './emergencies/emergencies.module';
import { SheltersModule } from './shelters/shelters.module';
import { ReportsModule } from './reports/reports.module';
import { SyncModule } from './sync/sync.module';
import { GeographyModule } from './geography/geography.module';
import { DevicesModule } from './devices/devices.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: ['.env'],
    }),
    PrismaModule,
    HealthModule,
    AuthModule,
    UsersModule,
    PeopleModule,
    FamiliesModule,
    EmergenciesModule,
    SheltersModule,
    ReportsModule,
    SyncModule,
    DevicesModule,
    GeographyModule,
  ],
})
export class AppModule {}
