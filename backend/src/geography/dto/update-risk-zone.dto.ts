import { PartialType } from '@nestjs/swagger';
import { CreateRiskZoneDto } from './create-risk-zone.dto';

export class UpdateRiskZoneDto extends PartialType(CreateRiskZoneDto) {}
