import { Entity, Column, PrimaryGeneratedColumn, OneToOne } from 'typeorm';
import { Wallet } from '../wallet/wallet.entity';

export enum UserRole {
  ADMIN = 'admin',
  INSPECTOR = 'inspector',
  SELLER = 'seller',
  BIDDER = 'bidder',
}

export enum KYCStatus {
  PENDING = 'pending',
  VERIFIED = 'verified',
  REJECTED = 'rejected',
}

@Entity()
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  email: string;

  @Column()
  phone: string;

  @Column()
  passwordHash: string;

  @Column({ type: 'enum', enum: UserRole })
  role: UserRole;

  @Column({ type: 'enum', enum: KYCStatus, default: KYCStatus.PENDING })
  kycStatus: KYCStatus;

  @Column({ nullable: true })
  kycDocumentUrl: string;

  @OneToOne(() => Wallet, wallet => wallet.user)
  wallet: Wallet;
}
