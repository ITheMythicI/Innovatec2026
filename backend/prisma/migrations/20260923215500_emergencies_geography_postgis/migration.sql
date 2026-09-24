-- CreateEnum
CREATE TYPE "EmergencyType" AS ENUM ('EARTHQUAKE', 'FLOOD', 'HURRICANE', 'WILDFIRE', 'LANDSLIDE', 'VOLCANIC_ERUPTION', 'TSUNAMI', 'EXPLOSION', 'BUILDING_COLLAPSE', 'HAZARDOUS_SPILL', 'OTHER');

-- CreateEnum
CREATE TYPE "EmergencySeverity" AS ENUM ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL');

-- CreateEnum
CREATE TYPE "EmergencyStatus" AS ENUM ('ACTIVE', 'CONTAINED', 'RESOLVED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "ShelterStatus" AS ENUM ('OPEN', 'FULL', 'CLOSED', 'EVACUATING');

-- CreateEnum
CREATE TYPE "ShelterServiceType" AS ENUM ('MEDICAL', 'FOOD', 'WATER', 'ELECTRICITY', 'SANITATION', 'BEDS', 'PSYCHOLOGICAL_SUPPORT', 'WIFI_COMMUNICATION', 'PETS_ALLOWED', 'ACCESSIBLE', 'OTHER');

-- CreateEnum
CREATE TYPE "ShelterStayStatus" AS ENUM ('ACTIVE', 'CHECKED_OUT', 'TRANSFERRED');

-- CreateEnum
CREATE TYPE "ReportCategory" AS ENUM ('CASUALTIES', 'TRAPPED_PERSONS', 'STRUCTURAL_DAMAGE', 'FIRE_HAZARD', 'FLOODING', 'ROAD_BLOCKED', 'SUPPLY_NEED', 'MEDICAL_EMERGENCY', 'OTHER');

-- CreateEnum
CREATE TYPE "ReportPriority" AS ENUM ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL');

-- CreateEnum
CREATE TYPE "ReportStatus" AS ENUM ('PENDING', 'VERIFIED', 'IN_PROGRESS', 'RESOLVED', 'DISMISSED');

-- CreateEnum
CREATE TYPE "HazardType" AS ENUM ('FLOOD', 'LANDSLIDE', 'TSUNAMI', 'FIRE', 'STRUCTURAL_COLLAPSE', 'CONTAMINATION', 'VOLCANIC_LAHAR', 'SEISMIC_FAULT', 'OTHER');

-- CreateEnum
CREATE TYPE "RiskLevel" AS ENUM ('LOW', 'MEDIUM', 'HIGH', 'EXTREME');

-- CreateEnum
CREATE TYPE "PoiCategory" AS ENUM ('HOSPITAL', 'CLINIC', 'WATER_POINT', 'FOOD_DISTRIBUTION', 'POLICE_STATION', 'FIRE_STATION', 'HELIPAD', 'SUPPLY_DEPOT', 'TELECOM_TOWER', 'GOVERNMENT_OFFICE', 'OTHER');

-- CreateEnum
CREATE TYPE "PoiStatus" AS ENUM ('OPERATIONAL', 'LIMITED', 'DAMAGED', 'DESTROYED', 'INACCESSIBLE');

-- AlterTable
ALTER TABLE "emergencies" ADD COLUMN     "type" "EmergencyType" NOT NULL DEFAULT 'OTHER',
DROP COLUMN "severity",
ADD COLUMN     "severity" "EmergencySeverity" NOT NULL DEFAULT 'MEDIUM',
DROP COLUMN "status",
ADD COLUMN     "status" "EmergencyStatus" NOT NULL DEFAULT 'ACTIVE';

-- AlterTable
ALTER TABLE "points_of_interest" ADD COLUMN     "address" TEXT,
ADD COLUMN     "contact_phone" TEXT,
ADD COLUMN     "status" "PoiStatus" NOT NULL DEFAULT 'OPERATIONAL',
DROP COLUMN "category",
ADD COLUMN     "category" "PoiCategory" NOT NULL;

-- AlterTable
ALTER TABLE "reports" ADD COLUMN     "address" TEXT,
ADD COLUMN     "category" "ReportCategory" NOT NULL DEFAULT 'OTHER',
ADD COLUMN     "priority" "ReportPriority" NOT NULL DEFAULT 'MEDIUM',
ADD COLUMN     "verification_notes" TEXT,
ADD COLUMN     "verified_by_user_id" TEXT,
DROP COLUMN "status",
ADD COLUMN     "status" "ReportStatus" NOT NULL DEFAULT 'PENDING';

-- AlterTable
ALTER TABLE "risk_zones" ADD COLUMN     "emergency_id" TEXT,
ADD COLUMN     "hazard_type" "HazardType" NOT NULL DEFAULT 'OTHER',
DROP COLUMN "risk_level",
ADD COLUMN     "risk_level" "RiskLevel" NOT NULL DEFAULT 'HIGH',
ALTER COLUMN "geometry_geojson" SET NOT NULL;

-- AlterTable
ALTER TABLE "shelter_services" DROP COLUMN "service_name",
ADD COLUMN     "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN     "service_type" "ShelterServiceType" NOT NULL;

-- AlterTable
ALTER TABLE "shelter_stays" ADD COLUMN     "assigned_bed" TEXT,
DROP COLUMN "status",
ADD COLUMN     "status" "ShelterStayStatus" NOT NULL DEFAULT 'ACTIVE';

-- AlterTable
ALTER TABLE "shelters" ADD COLUMN     "contact_name" TEXT,
ADD COLUMN     "managed_by" TEXT,
DROP COLUMN "status",
ADD COLUMN     "status" "ShelterStatus" NOT NULL DEFAULT 'OPEN';

-- CreateIndex
CREATE INDEX "emergencies_status_severity_idx" ON "emergencies"("status", "severity");

-- CreateIndex
CREATE INDEX "emergencies_started_at_idx" ON "emergencies"("started_at");

-- CreateIndex
CREATE INDEX "emergency_events_emergency_id_recorded_at_idx" ON "emergency_events"("emergency_id", "recorded_at");

-- CreateIndex
CREATE INDEX "points_of_interest_category_status_idx" ON "points_of_interest"("category", "status");

-- CreateIndex
CREATE INDEX "reports_status_priority_idx" ON "reports"("status", "priority");

-- CreateIndex
CREATE INDEX "reports_emergency_id_idx" ON "reports"("emergency_id");

-- CreateIndex
CREATE INDEX "reports_created_at_idx" ON "reports"("created_at");

-- CreateIndex
CREATE INDEX "risk_zones_active_risk_level_idx" ON "risk_zones"("active", "risk_level");

-- CreateIndex
CREATE UNIQUE INDEX "shelter_services_shelter_id_service_type_key" ON "shelter_services"("shelter_id", "service_type");

-- CreateIndex
CREATE INDEX "shelter_stays_shelter_id_status_idx" ON "shelter_stays"("shelter_id", "status");

-- CreateIndex
CREATE INDEX "shelter_stays_person_id_status_idx" ON "shelter_stays"("person_id", "status");

-- CreateIndex
CREATE INDEX "shelters_status_current_occupancy_idx" ON "shelters"("status", "current_occupancy");

-- AddForeignKey
ALTER TABLE "risk_zones" ADD CONSTRAINT "risk_zones_emergency_id_fkey" FOREIGN KEY ("emergency_id") REFERENCES "emergencies"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- ==============================================================================
-- POSTGIS EXTENSIONS, COLUMNS & GIST SPATIAL INDEXES
-- ==============================================================================

-- PostGIS Generated Geometry Column for Risk Zones (Polygons / MultiPolygons)
ALTER TABLE "risk_zones" ADD COLUMN IF NOT EXISTS "geom" geometry(Geometry, 4326)
  GENERATED ALWAYS AS (
    CASE WHEN "geometry_geojson" IS NOT NULL
    THEN ST_SetSRID(ST_GeomFromGeoJSON("geometry_geojson"::text), 4326)
    ELSE NULL END
  ) STORED;

-- Spatial GiST Index for Risk Zones
CREATE INDEX IF NOT EXISTS "idx_risk_zones_geom_gist" ON "risk_zones" USING GIST ("geom");

-- Spatial GiST Index for Emergencies
CREATE INDEX IF NOT EXISTS "idx_emergencies_location_gist" ON "emergencies" USING GIST (
  (ST_SetSRID(ST_MakePoint(longitude, latitude), 4326)::geography)
);

-- Spatial GiST Index for Shelters
CREATE INDEX IF NOT EXISTS "idx_shelters_location_gist" ON "shelters" USING GIST (
  (ST_SetSRID(ST_MakePoint(longitude, latitude), 4326)::geography)
);

-- Spatial GiST Index for Points of Interest
CREATE INDEX IF NOT EXISTS "idx_pois_location_gist" ON "points_of_interest" USING GIST (
  (ST_SetSRID(ST_MakePoint(longitude, latitude), 4326)::geography)
);

-- Spatial GiST Index for Reports
CREATE INDEX IF NOT EXISTS "idx_reports_location_gist" ON "reports" USING GIST (
  (ST_SetSRID(ST_MakePoint(longitude, latitude), 4326)::geography)
) WHERE latitude IS NOT NULL AND longitude IS NOT NULL;
