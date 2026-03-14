import { Controller, Post, Get, Body, UseGuards } from '@nestjs/common';
import { AuthService } from './auth.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { SetRoleDto } from './dto/set-role.dto';
import { Public } from './decorators/public.decorator';
import { AdminGuard } from './admin.guard';
import { CurrentUser } from './decorators/current-user.decorator';
import { User } from '../users/entities/user.entity';

@Controller('auth')
export class AuthController {
  constructor(private auth: AuthService) {}

  /** POST /auth/register — public, creates a regular user account */
  @Post('register')
  @Public()
  register(@Body() dto: RegisterDto) {
    return this.auth.register(dto);
  }

  /** POST /auth/login — public, returns JWT */
  @Post('login')
  @Public()
  login(@Body() dto: LoginDto) {
    return this.auth.login(dto);
  }

  /** GET /auth/me — returns current user from JWT */
  @Get('me')
  me(@CurrentUser() user: User) {
    return {
      id: user.id,
      email: user.email,
      displayName: user.displayName,
      role: user.role,
    };
  }

  /** POST /auth/set-role — admin only, promotes or demotes any user */
  @Post('set-role')
  @UseGuards(AdminGuard)
  setRole(@Body() dto: SetRoleDto) {
    return this.auth.setRole(dto.email, dto.role);
  }
}
