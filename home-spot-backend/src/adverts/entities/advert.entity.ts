import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';

export enum AdType {
  SALE = 'Sale',
  RENT = 'Rent',
}

export enum EstateType {
  APARTMENT = 'Apartment',
  HOUSE = 'House',
  OFFICE = 'Office',
  FIELD = 'Field',
}

@Entity('adverts')
export class Advert {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ type: 'text' })
  description: string;

  @Column({ type: 'enum', enum: AdType })
  adType: AdType;

  @Column({ type: 'enum', enum: EstateType })
  estateType: EstateType;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  surfaceArea: number;

  @Column({ type: 'int', nullable: true })
  nbRooms: number | null;

  @Column({ length: 100 })
  location: string;

  @Column({ type: 'decimal', precision: 12, scale: 2 })
  price: number;

  @Column({ type: 'varchar', length: 500, nullable: true })
  imageURL: string | null;

  @ManyToOne(() => User, (user) => user.adverts, {
    nullable: true,
    onDelete: 'SET NULL',
  })
  @JoinColumn({ name: 'createdById' })
  createdBy: User | null;

  @Column({ nullable: true })
  createdById: number | null;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
