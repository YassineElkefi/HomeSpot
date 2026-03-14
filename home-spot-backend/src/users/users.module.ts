import {
  Controller, Get, Patch, Delete,
  Param, ParseIntPipe, UseGuards,
  Body, Module, NotFoundException,
} from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User, UserRole } from './entities/user.entity';
import { AdminGuard } from '../auth/admin.guard';
import { IsBoolean, IsOptional, IsString, MaxLength } from 'class-validator';

class UpdateUserDto {
  @IsOptional() @IsString() @MaxLength(100)
  displayName?: string;

  @IsOptional() @IsBoolean()
  disabled?: boolean;
}

@Controller('users')
class UsersController {
  constructor(@InjectRepository(User) private users: Repository<User>) {}

  /** GET /users — admin only, paginated list of all users */
  @Get()
  @UseGuards(AdminGuard)
  async findAll() {
    const users = await this.users.find({
      select: ['id', 'email', 'displayName', 'role', 'disabled', 'createdAt'],
      order: { createdAt: 'DESC' },
    });
    return users;
  }

  /** GET /users/:id — admin only */
  @Get(':id')
  @UseGuards(AdminGuard)
  async findOne(@Param('id', ParseIntPipe) id: number) {
    const user = await this.users.findOne({
      where: { id },
      select: ['id', 'email', 'displayName', 'role', 'disabled', 'createdAt'],
      relations: ['adverts'],
    });
    if (!user) throw new NotFoundException(`User #${id} not found`);
    return user;
  }

  /** PATCH /users/:id — admin only, update displayName or disable/enable */
  @Patch(':id')
  @UseGuards(AdminGuard)
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateUserDto,
  ) {
    const user = await this.users.findOne({ where: { id } });
    if (!user) throw new NotFoundException(`User #${id} not found`);
    Object.assign(user, dto);
    await this.users.save(user);
    const { password, ...safe } = user as any;
    return safe;
  }

  /** DELETE /users/:id — admin only */
  @Delete(':id')
  @UseGuards(AdminGuard)
  async remove(@Param('id', ParseIntPipe) id: number) {
    const user = await this.users.findOne({ where: { id } });
    if (!user) throw new NotFoundException(`User #${id} not found`);
    await this.users.remove(user);
    return { deleted: id };
  }
}

@Module({
  imports: [TypeOrmModule.forFeature([User])],
  controllers: [UsersController],
})
export class UsersModule {}
