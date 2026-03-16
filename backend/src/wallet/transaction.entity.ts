import { Entity, Column, PrimaryGeneratedColumn, ManyToOne } from 'typeorm';
import { Wallet } from './wallet.entity';

export enum TransactionType {
  INSPECTION_FEE = 'inspection_fee',
  BID_REFUND = 'bid_refund',
  COMMISSION = 'commission',
  PAYMENT = 'payment',
  WALLET_FUND = 'wallet_fund',
}

export enum TransactionStatus {
  PENDING = 'pending',
  SUCCESS = 'success',
  FAILED = 'failed',
}

@Entity()
export class Transaction {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @ManyToOne(() => Wallet)
  fromWallet: Wallet;

  @ManyToOne(() => Wallet)
  toWallet: Wallet;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  amount: number;

  @Column({ type: 'enum', enum: TransactionType })
  type: TransactionType;

  @Column({ unique: true })
  reference: string;

  @Column({ type: 'enum', enum: TransactionStatus, default: TransactionStatus.PENDING })
  status: TransactionStatus;
}
