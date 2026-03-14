import {
  Injectable,
  NotFoundException,
  Logger,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ConfigService } from '@nestjs/config';
import { join } from 'path';
import { existsSync, unlinkSync } from 'fs';
import { Advert } from './entities/advert.entity';
import { User } from '../users/entities/user.entity';
import { CreateAdvertDto } from './dto/create-advert.dto';
import { UpdateAdvertDto } from './dto/update-advert.dto';

export interface FindAllQuery {
  q?: string;
  adType?: string;
  estateType?: string;
  location?: string;
  minPrice?: number;
  maxPrice?: number;
  minSurface?: number;
  maxSurface?: number;
  page?: number;
  limit?: number;
}

@Injectable()
export class AdvertsService {
  private readonly logger = new Logger(AdvertsService.name);

  constructor(
    @InjectRepository(Advert)
    private advertRepo: Repository<Advert>,
    private config: ConfigService,
  ) {}

  async findAll(query: FindAllQuery) {
    const {
      q, adType, estateType, location,
      minPrice, maxPrice, minSurface, maxSurface,
      page = 1, limit = 20,
    } = query;

    const qb = this.advertRepo
      .createQueryBuilder('advert')
      .leftJoin('advert.createdBy', 'user')
      .addSelect(['user.id', 'user.email', 'user.displayName'])
      .orderBy('advert.createdAt', 'DESC')
      .skip((page - 1) * limit)
      .take(limit);

    if (q) {
      qb.andWhere(
        '(advert.description LIKE :q OR advert.location LIKE :q OR advert.adType LIKE :q OR advert.estateType LIKE :q)',
        { q: `%${q}%` },
      );
    }

    if (adType)     qb.andWhere('advert.adType = :adType', { adType });
    if (estateType) qb.andWhere('advert.estateType = :estateType', { estateType });
    if (location)   qb.andWhere('advert.location = :location', { location });

    if (minPrice !== undefined && maxPrice !== undefined) {
      qb.andWhere('advert.price BETWEEN :minPrice AND :maxPrice', { minPrice, maxPrice });
    } else if (minPrice !== undefined) {
      qb.andWhere('advert.price >= :minPrice', { minPrice });
    } else if (maxPrice !== undefined) {
      qb.andWhere('advert.price <= :maxPrice', { maxPrice });
    }

    if (minSurface !== undefined && maxSurface !== undefined) {
      qb.andWhere('advert.surfaceArea BETWEEN :minSurface AND :maxSurface', { minSurface, maxSurface });
    } else if (minSurface !== undefined) {
      qb.andWhere('advert.surfaceArea >= :minSurface', { minSurface });
    } else if (maxSurface !== undefined) {
      qb.andWhere('advert.surfaceArea <= :maxSurface', { maxSurface });
    }

    const [data, total] = await qb.getManyAndCount();
    return { data, meta: { total, page, limit, totalPages: Math.ceil(total / limit) } };
  }

  async findOne(id: number): Promise<Advert> {
    const advert = await this.advertRepo.findOne({
      where: { id },
      relations: ['createdBy'],
    });
    if (!advert) throw new NotFoundException(`Advert #${id} not found`);
    return advert;
  }

  async create(dto: CreateAdvertDto, file: Express.Multer.File | undefined, user: User): Promise<Advert> {
    const imageURL = file ? `/uploads/${file.filename}` : null;
    const advert = this.advertRepo.create({
      ...dto,
      nbRooms: dto.estateType === 'Field' ? null : (dto.nbRooms ?? null),
      imageURL,
      createdBy: user,
    });
    const saved = await this.advertRepo.save(advert);
    this.logger.log(`Created advert #${saved.id}`);
    return saved;
  }

  async update(id: number, dto: UpdateAdvertDto, file: Express.Multer.File | undefined): Promise<Advert> {
    const advert = await this.findOne(id);

    if (file) {
      this.deleteImageFile(advert.imageURL);
      advert.imageURL = `/uploads/${file.filename}`;
    }

    const newEstateType = dto.estateType ?? advert.estateType;
    Object.assign(advert, dto);
    if (newEstateType === 'Field') advert.nbRooms = null;

    const saved = await this.advertRepo.save(advert);
    this.logger.log(`Updated advert #${id}`);
    return saved;
  }

  async remove(id: number): Promise<{ deleted: number }> {
    const advert = await this.findOne(id);
    this.deleteImageFile(advert.imageURL);
    await this.advertRepo.remove(advert);
    this.logger.log(`Deleted advert #${id}`);
    return { deleted: id };
  }

  private deleteImageFile(imageURL: string | null): void {
    if (!imageURL) return;
    try {
      const filename = imageURL.replace('/uploads/', '');
      const fullPath = join(process.cwd(), 'uploads', filename);
      if (existsSync(fullPath)) unlinkSync(fullPath);
    } catch (err) {
      this.logger.warn(`Could not delete image: ${err.message}`);
    }
  }
}
