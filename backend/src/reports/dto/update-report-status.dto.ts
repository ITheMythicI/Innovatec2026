import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsEnum, IsOptional, IsString, IsUUID } from 'class-validator';
import { ReportStatus } from '@prisma/client';

export class UpdateReportStatusDto {
  @ApiProperty({ enum: ReportStatus, example: ReportStatus.VERIFIED })
  @IsEnum(ReportStatus)
  status: ReportStatus;

  @ApiPropertyOptional({ description: 'ID del rescatista o coordinador que verifica' })
  @IsUUID()
  @IsOptional()
  verifiedByUserId?: string;

  @ApiPropertyOptional({ description: 'Notas u observaciones del dictamen de verificación' })
  @IsString()
  @IsOptional()
  verificationNotes?: string;
}
