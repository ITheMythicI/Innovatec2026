-- =============================================================================
-- FASE 2: Seguridad, Roles y Broadcasts
-- Descripción: Agrega AppRole enum, campo app_role y tactical_id a users,
--              tablas de broadcasts y broadcast_deliveries,
--              campos de posición a devices.
-- NOTA: Se usan RENAME COLUMN para preservar datos existentes en users.
-- =============================================================================

-- CreateEnum: Roles de la aplicación
CREATE TYPE "AppRole" AS ENUM ('SUPER_ADMIN', 'COMMANDER', 'OPERATOR', 'VIEWER', 'USER');

-- CreateEnum: Estados de broadcast
CREATE TYPE "BroadcastStatus" AS ENUM ('CREATED', 'SENT', 'PARTIALLY_DELIVERED', 'DELIVERED', 'FAILED', 'CANCELLED');
CREATE TYPE "BroadcastType" AS ENUM ('NEWS', 'ALERT', 'EVACUATION', 'WARNING');
CREATE TYPE "BroadcastTarget" AS ENUM ('GLOBAL', 'GEOGRAPHIC', 'ROLE');
CREATE TYPE "DeliveryStatus" AS ENUM ('PENDING', 'SENT', 'DELIVERED', 'ACKNOWLEDGED', 'FAILED');
CREATE TYPE "DeliveryChannel" AS ENUM ('WEBSOCKET', 'FCM', 'SMS', 'BLE');

-- AlterTable users: Renombrar columnas existentes para concordar con @map()
-- y agregar campos nuevos
ALTER TABLE "users"
  RENAME COLUMN "passwordHash" TO "password_hash";

ALTER TABLE "users"
  RENAME COLUMN "fullName" TO "full_name";

ALTER TABLE "users"
  RENAME COLUMN "isActive" TO "is_active";

ALTER TABLE "users"
  RENAME COLUMN "createdAt" TO "created_at";

ALTER TABLE "users"
  RENAME COLUMN "updatedAt" TO "updated_at";

-- Agregar nuevos campos a users
ALTER TABLE "users"
  ADD COLUMN "tactical_id"  TEXT,
  ADD COLUMN "app_role"     "AppRole" NOT NULL DEFAULT 'USER';

-- CreateIndex en users
CREATE UNIQUE INDEX "users_tactical_id_key" ON "users"("tactical_id");
CREATE INDEX "users_email_idx" ON "users"("email");
CREATE INDEX "users_app_role_idx" ON "users"("app_role");

-- AlterTable devices: agregar campos de posición GPS
ALTER TABLE "devices"
  ADD COLUMN "last_latitude"    DOUBLE PRECISION,
  ADD COLUMN "last_longitude"   DOUBLE PRECISION,
  ADD COLUMN "last_position_at" TIMESTAMP(3);

-- CreateIndex en devices para búsqueda geográfica de broadcast
CREATE INDEX "devices_last_latitude_last_longitude_idx" ON "devices"("last_latitude", "last_longitude");

-- CreateTable broadcasts
CREATE TABLE "broadcasts" (
    "id"                TEXT            NOT NULL,
    "title"             TEXT            NOT NULL,
    "body"              TEXT            NOT NULL,
    "type"              "BroadcastType" NOT NULL,
    "target_mode"       "BroadcastTarget" NOT NULL DEFAULT 'GLOBAL',
    "target_role"       "AppRole",
    "geo_latitude"      DOUBLE PRECISION,
    "geo_longitude"     DOUBLE PRECISION,
    "geo_radius_meters" INTEGER,
    "status"            "BroadcastStatus" NOT NULL DEFAULT 'CREATED',
    "sent_at"           TIMESTAMP(3),
    "scheduled_at"      TIMESTAMP(3),
    "sent_by_user_id"   TEXT            NOT NULL,
    "created_at"        TIMESTAMP(3)    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at"        TIMESTAMP(3)    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "broadcasts_pkey" PRIMARY KEY ("id")
);

-- CreateIndex en broadcasts
CREATE INDEX "broadcasts_status_created_at_idx" ON "broadcasts"("status", "created_at");
CREATE INDEX "broadcasts_type_status_idx" ON "broadcasts"("type", "status");

-- AddForeignKey broadcasts → users
ALTER TABLE "broadcasts"
  ADD CONSTRAINT "broadcasts_sent_by_user_id_fkey"
  FOREIGN KEY ("sent_by_user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- CreateTable broadcast_deliveries
CREATE TABLE "broadcast_deliveries" (
    "id"           TEXT              NOT NULL,
    "broadcast_id" TEXT              NOT NULL,
    "device_id"    TEXT              NOT NULL,
    "channel"      "DeliveryChannel" NOT NULL DEFAULT 'WEBSOCKET',
    "status"       "DeliveryStatus"  NOT NULL DEFAULT 'PENDING',
    "sent_at"      TIMESTAMP(3),
    "delivered_at" TIMESTAMP(3),
    "ack_at"       TIMESTAMP(3),
    "fail_reason"  TEXT,
    "created_at"   TIMESTAMP(3)      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "broadcast_deliveries_pkey" PRIMARY KEY ("id")
);

-- CreateIndex en broadcast_deliveries
CREATE UNIQUE INDEX "broadcast_deliveries_broadcast_id_device_id_channel_key"
  ON "broadcast_deliveries"("broadcast_id", "device_id", "channel");
CREATE INDEX "broadcast_deliveries_broadcast_id_status_idx"
  ON "broadcast_deliveries"("broadcast_id", "status");
CREATE INDEX "broadcast_deliveries_device_id_status_idx"
  ON "broadcast_deliveries"("device_id", "status");

-- AddForeignKey broadcast_deliveries → broadcasts
ALTER TABLE "broadcast_deliveries"
  ADD CONSTRAINT "broadcast_deliveries_broadcast_id_fkey"
  FOREIGN KEY ("broadcast_id") REFERENCES "broadcasts"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey broadcast_deliveries → devices
ALTER TABLE "broadcast_deliveries"
  ADD CONSTRAINT "broadcast_deliveries_device_id_fkey"
  FOREIGN KEY ("device_id") REFERENCES "devices"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- NOTA: La columna risk_zones.geom (PostGIS generada) se mantiene intacta.
-- No es gestionada por Prisma, fue creada por migración SQL manual anterior.
