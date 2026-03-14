import {
  IsString,
  IsNumber,
  IsOptional,
  IsIn,
  IsPositive,
  MaxLength,
  Min,
  Max,
} from 'class-validator';
import { Type } from 'class-transformer';
import { AdType, EstateType } from '../entities/advert.entity';

export const LOCATIONS = [
  'Tunis', 'Sfax', 'Sousse', 'Monastir', 'Nabeul',
  'Hammamet', 'Bizerte', 'Ariana', 'Ben Arous', 'Manouba',
] as const;

export class CreateAdvertDto {
  @IsString()
  @MaxLength(2000)
  description: string;

  @IsIn(Object.values(AdType))
  adType: AdType;

  @IsIn(Object.values(EstateType))
  estateType: EstateType;

  @Type(() => Number)
  @IsNumber()
  @IsPositive()
  @Max(100_000)
  surfaceArea: number;

  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(1)
  @Max(50)
  nbRooms?: number;

  @IsIn(LOCATIONS)
  location: string;

  @Type(() => Number)
  @IsNumber()
  @IsPositive()
  price: number;
}
