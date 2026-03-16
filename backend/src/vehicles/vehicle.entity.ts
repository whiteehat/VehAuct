import { Entity, Column, PrimaryGeneratedColumn, ManyToOne, OneToOne } from 'typeorm';
import { User } from '../users/user.entity';
import { Inspection } from '../inspections/inspection.entity';

export enum VehicleStatus {
  PENDING_INSPECTION = 'pending_inspection',
  VERIFIED = 'verified',
  REJECTED = 'rejected',
  SOLD = 'sold',
}

@Entity()
export class Vehicle {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @ManyToOne(() => User)
  seller: User;

  @Column()
  vin: string;

  @Column()
  make: string;

  @Column()
  model: string;

  @Column()
  year: number;

  @Column({ type: 'enum', enum: VehicleStatus, default: VehicleStatus.PENDING_INSPECTION })
  status: VehicleStatus;

  @OneToOne(() => Inspection, inspection => inspection.vehicle)
  inspection: Inspection;
}
