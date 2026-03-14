import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AdvertsController } from './adverts.controller';
import { AdvertsService } from './adverts.service';
import { Advert } from './entities/advert.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Advert])],
  controllers: [AdvertsController],
  providers: [AdvertsService],
})
export class AdvertsModule {}
