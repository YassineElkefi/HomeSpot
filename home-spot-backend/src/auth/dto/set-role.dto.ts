import { IsEmail, IsIn } from 'class-validator';
import { UserRole } from '../../users/entities/user.entity';

export class SetRoleDto {
  @IsEmail()
  email: string;

  @IsIn([UserRole.ADMIN, UserRole.USER])
  role: UserRole;
}
