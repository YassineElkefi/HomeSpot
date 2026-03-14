import {
  Controller, Get, Post, Put, Delete,
  Body, Param, Query, ParseIntPipe,
  UploadedFile, UseInterceptors, UseGuards,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import { extname, join } from 'path';
import { mkdirSync } from 'fs';
import { v4 as uuid } from 'uuid';
import { AdminGuard } from '../auth/admin.guard';
import { Public } from '../auth/decorators/public.decorator';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { AdvertsService, FindAllQuery } from './adverts.service';
import { CreateAdvertDto } from './dto/create-advert.dto';
import { UpdateAdvertDto } from './dto/update-advert.dto';
import { User } from '../users/entities/user.entity';

// Ensure uploads directory exists at startup
const UPLOAD_DIR = join(process.cwd(), 'uploads');
mkdirSync(UPLOAD_DIR, { recursive: true });

const imageStorage = diskStorage({
  destination: (_req, _file, cb) => cb(null, UPLOAD_DIR),
  filename: (_req, file, cb) => {
    const ext = extname(file.originalname).toLowerCase() || '.jpg';
    cb(null, `${uuid()}${ext}`);
  },
});

const imageUpload = FileInterceptor('image', {
  storage: imageStorage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5 MB
  fileFilter: (_req, file, cb) => {
    if (!file.mimetype.startsWith('image/')) {
      return cb(new Error('Only image files are allowed'), false);
    }
    cb(null, true);
  },
});

@Controller('adverts')
export class AdvertsController {
  constructor(private readonly advertsService: AdvertsService) {}

  /**
   * GET /adverts
   * Public. Query params: q, adType, estateType, location,
   *                       minPrice, maxPrice, minSurface, maxSurface,
   *                       page (default 1), limit (default 20)
   */
  @Get()
  @Public()
  findAll(
    @Query('q')          q?: string,
    @Query('adType')     adType?: string,
    @Query('estateType') estateType?: string,
    @Query('location')   location?: string,
    @Query('minPrice')   minPrice?: string,
    @Query('maxPrice')   maxPrice?: string,
    @Query('minSurface') minSurface?: string,
    @Query('maxSurface') maxSurface?: string,
    @Query('page')       page?: string,
    @Query('limit')      limit?: string,
  ) {
    const query: FindAllQuery = {
      q,
      adType,
      estateType,
      location,
      minPrice:   minPrice   ? parseFloat(minPrice)   : undefined,
      maxPrice:   maxPrice   ? parseFloat(maxPrice)   : undefined,
      minSurface: minSurface ? parseFloat(minSurface) : undefined,
      maxSurface: maxSurface ? parseFloat(maxSurface) : undefined,
      page:       page       ? parseInt(page)         : 1,
      limit:      limit      ? parseInt(limit)        : 20,
    };
    return this.advertsService.findAll(query);
  }

  /** GET /adverts/:id — public */
  @Get(':id')
  @Public()
  findOne(@Param('id', ParseIntPipe) id: number) {
    return this.advertsService.findOne(id);
  }

  /**
   * POST /adverts — admin only
   * Content-Type: multipart/form-data
   * Fields: all CreateAdvertDto fields + optional 'image' file
   */
  @Post()
  @UseGuards(AdminGuard)
  @UseInterceptors(imageUpload)
  create(
    @Body() dto: CreateAdvertDto,
    @CurrentUser() user: User,
    @UploadedFile() file?: Express.Multer.File,
  ) {
    return this.advertsService.create(dto, file, user);
  }

  /**
   * PUT /adverts/:id — admin only
   * Content-Type: multipart/form-data
   * All fields optional; include new 'image' file to replace the old one
   */
  @Put(':id')
  @UseGuards(AdminGuard)
  @UseInterceptors(imageUpload)
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateAdvertDto,
    @UploadedFile() file?: Express.Multer.File,
  ) {
    return this.advertsService.update(id, dto, file);
  }

  /** DELETE /adverts/:id — admin only. Also removes image from disk. */
  @Delete(':id')
  @UseGuards(AdminGuard)
  remove(@Param('id', ParseIntPipe) id: number) {
    return this.advertsService.remove(id);
  }
}
