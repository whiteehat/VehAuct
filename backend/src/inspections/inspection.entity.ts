import { Entity, Column, PrimaryGeneratedColumn, OneToOne, ManyToOne, JoinColumn } from 'typeorm';
import { Vehicle } from '../vehicles/vehicle.entity';
import { User } from '../users/user.entity';

@Entity()
export class Inspection {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @OneToOne(() => Vehicle, vehicle => vehicle.inspection)
  @JoinColumn()
  vehicle: Vehicle;

  @ManyToOne(() => User)
  inspector: User;

  @Column()
  reportUrl: string;

  @Column('text')
  condition: string;

  @Column()
  passed: boolean;

  @Column()
  inspectedAt: Date;
}
