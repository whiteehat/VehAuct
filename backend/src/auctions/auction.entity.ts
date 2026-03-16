import { Entity, Column, PrimaryGeneratedColumn, OneToOne, ManyToOne, JoinColumn } from 'typeorm';
import { Vehicle } from '../vehicles/vehicle.entity';
import { User } from '../users/user.entity';

export enum AuctionStatus {
  SCHEDULED = 'scheduled',
  LIVE = 'live',
  ENDED = 'ended',
  SOLD = 'sold',
  UNSOLD = 'unsold',
}

@Entity()
export class Auction {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @OneToOne(() => Vehicle)
  @JoinColumn()
  vehicle: Vehicle;

  @Column()
  startTime: Date;

  @Column()
  endTime: Date;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  thresholdPrice: number;

  @Column({ type: 'decimal', precision: 10, scale: 2, default: 0 })
  currentBid: number;

  @Column({ type: 'enum', enum: AuctionStatus, default: AuctionStatus.SCHEDULED })
  status: AuctionStatus;

  @ManyToOne(() => User, { nullable: true })
  winner: User;

  @Column({ type: 'decimal', precision: 10, scale: 2, nullable: true })
  winningBid: number;

  @Column({ type: 'decimal', precision: 10, scale: 2, default: 100000 })
  commission: number;

  @Column({ nullable: true })
  paymentDeadline: Date;
}
