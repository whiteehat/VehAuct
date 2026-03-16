# PowerShell script to generate VehAuction project files

# Create directory tree
$dirs = @(
    "backend\src\auth",
    "backend\src\users",
    "backend\src\vehicles",
    "backend\src\inspections",
    "backend\src\auctions",
    "backend\src\bids",
    "backend\src\wallet",
    "backend\src\admin",
    "backend\src\common",
    "backend\src\database",
    "frontend\src\components",
    "frontend\src\pages",
    "frontend\src\context",
    "frontend\src\services",
    "frontend\src\socket",
    "frontend\src\assets",
    "frontend\public"
)

foreach ($dir in $dirs) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
}

# Helper function to write file content
function Write-File($path, $content) {
    Set-Content -Path $path -Value $content -Encoding UTF8
}

# Backend package.json
Write-File "backend\package.json" @"
{
  "name": "vehauction-backend",
  "version": "1.0.0",
  "description": "VehAuction API",
  "scripts": {
    "start": "nest start",
    "start:dev": "nest start --watch",
    "build": "nest build"
  },
  "dependencies": {
    "@nestjs/common": "^9.0.0",
    "@nestjs/core": "^9.0.0",
    "@nestjs/platform-express": "^9.0.0",
    "@nestjs/websockets": "^9.0.0",
    "@nestjs/platform-socket.io": "^9.0.0",
    "@nestjs/typeorm": "^9.0.0",
    "@nestjs/config": "^2.0.0",
    "@nestjs/jwt": "^9.0.0",
    "@nestjs/passport": "^9.0.0",
    "typeorm": "^0.3.0",
    "pg": "^8.7.0",
    "redis": "^4.0.0",
    "socket.io": "^4.5.0",
    "passport": "^0.6.0",
    "passport-jwt": "^4.0.0",
    "bcrypt": "^5.0.0",
    "class-validator": "^0.13.0",
    "class-transformer": "^0.5.0",
    "dotenv": "^16.0.0"
  },
  "devDependencies": {
    "@nestjs/cli": "^9.0.0",
    "@types/node": "^18.0.0",
    "typescript": "^4.7.0"
  }
}
"@

Write-File "backend\tsconfig.json" @"
{
  "compilerOptions": {
    "module": "commonjs",
    "declaration": true,
    "removeComments": true,
    "emitDecoratorMetadata": true,
    "experimentalDecorators": true,
    "allowSyntheticDefaultImports": true,
    "target": "es2017",
    "sourceMap": true,
    "outDir": "./dist",
    "baseUrl": "./",
    "incremental": true,
    "skipLibCheck": true,
    "strictNullChecks": false,
    "noImplicitAny": false,
    "strictBindCallApply": false,
    "forceConsistentCasingInFileNames": false,
    "noFallthroughCasesInSwitch": false
  }
}
"@

Write-File "backend\.env" @"
DB_HOST=postgres
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=postgres
DB_NAME=vehauction
REDIS_HOST=redis
REDIS_PORT=6379
JWT_SECRET=supersecret
PAYSTACK_SECRET_KEY=sk_test_...
"@

Write-File "backend\Dockerfile" @"
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build
EXPOSE 3000
CMD ["node", "dist/main"]
"@

Write-File "backend\src\main.ts" @"
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.useGlobalPipes(new ValidationPipe({ whitelist: true }));
  app.enableCors();
  await app.listen(3000);
}
bootstrap();
"@

Write-File "backend\src\app.module.ts" @"
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { VehiclesModule } from './vehicles/vehicles.module';
import { InspectionsModule } from './inspections/inspections.module';
import { AuctionsModule } from './auctions/auctions.module';
import { BidsModule } from './bids/bids.module';
import { WalletModule } from './wallet/wallet.module';
import { AdminModule } from './admin/admin.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        type: 'postgres',
        host: config.get('DB_HOST'),
        port: +config.get('DB_PORT'),
        username: config.get('DB_USER'),
        password: config.get('DB_PASSWORD'),
        database: config.get('DB_NAME'),
        autoLoadEntities: true,
        synchronize: true,
      }),
    }),
    AuthModule,
    UsersModule,
    VehiclesModule,
    InspectionsModule,
    AuctionsModule,
    BidsModule,
    WalletModule,
    AdminModule,
  ],
})
export class AppModule {}
"@

# User entity
Write-File "backend\src\users\user.entity.ts" @"
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
"@

# Wallet entities
Write-File "backend\src\wallet\wallet.entity.ts" @"
import { Entity, Column, PrimaryGeneratedColumn, OneToOne, JoinColumn } from 'typeorm';
import { User } from '../users/user.entity';

@Entity()
export class Wallet {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @OneToOne(() => User, user => user.wallet)
  @JoinColumn()
  user: User;

  @Column({ type: 'decimal', precision: 10, scale: 2, default: 0 })
  balance: number;

  @Column({ type: 'decimal', precision: 10, scale: 2, default: 0 })
  lockedBalance: number;

  @Column({ default: 'NGN' })
  currency: string;
}
"@

Write-File "backend\src\wallet\transaction.entity.ts" @"
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
"@

# Vehicle entity
Write-File "backend\src\vehicles\vehicle.entity.ts" @"
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
"@

# Inspection entity
Write-File "backend\src\inspections\inspection.entity.ts" @"
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
"@

# Auction entity
Write-File "backend\src\auctions\auction.entity.ts" @"
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
"@

# Bids gateway
Write-File "backend\src\bids\bids.gateway.ts" @"
import {
  WebSocketGateway,
  WebSocketServer,
  SubscribeMessage,
  MessageBody,
  ConnectedSocket,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { BidsService } from './bids.service';
import { UseGuards } from '@nestjs/common';
import { WsJwtGuard } from '../auth/ws-jwt.guard';

@WebSocketGateway({ cors: true })
export class BidsGateway {
  @WebSocketServer()
  server: Server;

  constructor(private bidsService: BidsService) {}

  @SubscribeMessage('joinAuction')
  handleJoin(@MessageBody() auctionId: string, @ConnectedSocket() client: Socket) {
    client.join(`auction_\${auctionId}`);
  }

  @SubscribeMessage('leaveAuction')
  handleLeave(@MessageBody() auctionId: string, @ConnectedSocket() client: Socket) {
    client.leave(`auction_\${auctionId}`);
  }

  @UseGuards(WsJwtGuard)
  @SubscribeMessage('placeBid')
  async handleBid(
    @MessageBody() data: { auctionId: string; amount: number },
    @ConnectedSocket() client: Socket,
  ) {
    const user = client.data.user;
    try {
      const bid = await this.bidsService.placeBid(user.id, data.auctionId, data.amount);
      this.server.to(`auction_\${data.auctionId}`).emit('newBid', bid);
    } catch (error) {
      client.emit('bidError', error.message);
    }
  }
}
"@

Write-File "backend\src\bids\bids.service.ts" @"
import { Injectable } from '@nestjs/common';

@Injectable()
export class BidsService {
  placeBid(userId: string, auctionId: string, amount: number) {
    // Implement bid logic: check wallet, save to DB, update auction currentBid
    return { userId, auctionId, amount };
  }
}
"@

# Auth module placeholder
Write-File "backend\src\auth\auth.module.ts" @"
import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';

@Module({
  imports: [
    JwtModule.registerAsync({
      useFactory: (config: ConfigService) => ({
        secret: config.get('JWT_SECRET'),
        signOptions: { expiresIn: '7d' },
      }),
      inject: [ConfigService],
    }),
  ],
  controllers: [],
  providers: [],
})
export class AuthModule {}
"@

# Create empty module files (needed for NestJS to compile)
$null | Set-Content "backend\src\users\users.module.ts"
$null | Set-Content "backend\src\vehicles\vehicles.module.ts"
$null | Set-Content "backend\src\inspections\inspections.module.ts"
$null | Set-Content "backend\src\auctions\auctions.module.ts"
$null | Set-Content "backend\src\bids\bids.module.ts"
$null | Set-Content "backend\src\wallet\wallet.module.ts"
$null | Set-Content "backend\src\admin\admin.module.ts"
$null | Set-Content "backend\src\auth\ws-jwt.guard.ts"

# ========== FRONTEND ==========

Write-File "frontend\package.json" @"
{
  "name": "vehauction-frontend",
  "version": "1.0.0",
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-router-dom": "^6.3.0",
    "axios": "^0.27.2",
    "socket.io-client": "^4.5.0",
    "tailwindcss": "^3.1.0"
  },
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build"
  },
  "devDependencies": {
    "react-scripts": "5.0.1",
    "@types/react": "^18.0.0",
    "@types/react-dom": "^18.0.0",
    "typescript": "^4.7.0"
  }
}
"@

Write-File "frontend\tsconfig.json" @"
{
  "compilerOptions": {
    "target": "es5",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    "strict": true,
    "forceConsistentCasingInFileNames": true,
    "noFallthroughCasesInSwitch": true,
    "module": "esnext",
    "moduleResolution": "node",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx"
  },
  "include": ["src"]
}
"@

Write-File "frontend\tailwind.config.js" @"
module.exports = {
  content: ["./src/**/*.{js,jsx,ts,tsx}"],
  theme: { extend: {} },
  plugins: [],
}
"@

Write-File "frontend\src\index.css" @"
@tailwind base;
@tailwind components;
@tailwind utilities;
"@

Write-File "frontend\src\index.tsx" @"
import React from 'react';
import ReactDOM from 'react-dom/client';
import './index.css';
import App from './App';
import { BrowserRouter } from 'react-router-dom';
import { AuthProvider } from './context/AuthContext';
import { WalletProvider } from './context/WalletContext';

const root = ReactDOM.createRoot(document.getElementById('root')!);
root.render(
  <React.StrictMode>
    <BrowserRouter>
      <AuthProvider>
        <WalletProvider>
          <App />
        </WalletProvider>
      </AuthProvider>
    </BrowserRouter>
  </React.StrictMode>
);
"@

Write-File "frontend\src\App.tsx" @"
import { Routes, Route } from 'react-router-dom';
import { Login } from './pages/Login';
import { Register } from './pages/Register';
import { Dashboard } from './pages/Dashboard';
import { AuctionDetail } from './pages/AuctionDetail';
import { Wallet } from './pages/Wallet';

function App() {
  return (
    <Routes>
      <Route path=\"/login\" element={<Login />} />
      <Route path=\"/register\" element={<Register />} />
      <Route path=\"/dashboard\" element={<Dashboard />} />
      <Route path=\"/auction/:id\" element={<AuctionDetail />} />
      <Route path=\"/wallet\" element={<Wallet />} />
    </Routes>
  );
}
export default App;
"@

Write-File "frontend\src\pages\AuctionDetail.tsx" @"
import { useEffect, useState } from 'react';
import { useParams } from 'react-router-dom';
import { useSocket } from '../socket/useSocket';
import { api } from '../services/api';

export function AuctionDetail() {
  const { id } = useParams();
  const [auction, setAuction] = useState<any>(null);
  const [bidAmount, setBidAmount] = useState('');
  const socket = useSocket();

  useEffect(() => {
    api.get(`/auctions/\${id}`).then(res => setAuction(res.data));
    socket.emit('joinAuction', id);
    socket.on('newBid', (bid) => {
      setAuction(prev => ({ ...prev, currentBid: bid.amount }));
    });
    return () => {
      socket.emit('leaveAuction', id);
      socket.off('newBid');
    };
  }, [id, socket]);

  const placeBid = () => {
    socket.emit('placeBid', { auctionId: id, amount: parseFloat(bidAmount) });
  };

  if (!auction) return <div>Loading...</div>;

  return (
    <div className=\"p-4\">
      <h1 className=\"text-2xl font-bold\">{auction.vehicle?.make} {auction.vehicle?.model}</h1>
      <p className=\"text-lg\">Current Bid: ₦{auction.currentBid}</p>
      <input
        type=\"number\"
        value={bidAmount}
        onChange={(e) => setBidAmount(e.target.value)}
        placeholder=\"Your bid\"
        className=\"border p-2 mr-2\"
      />
      <button onClick={placeBid} className=\"bg-blue-500 text-white px-4 py-2\">Place Bid</button>
    </div>
  );
}
"@

Write-File "frontend\src\pages\Login.tsx" @"
export function Login() {
  return <div>Login Page (implement form)</div>;
}
"@

Write-File "frontend\src\pages\Register.tsx" @"
export function Register() {
  return <div>Register Page</div>;
}
"@

Write-File "frontend\src\pages\Dashboard.tsx" @"
export function Dashboard() {
  return <div>Dashboard</div>;
}
"@

Write-File "frontend\src\pages\Wallet.tsx" @"
export function Wallet() {
  return <div>Wallet Page</div>;
}
"@

Write-File "frontend\src\context\AuthContext.tsx" @"
import React, { createContext, useContext, useState } from 'react';

interface AuthContextType {
  user: any;
  login: (token: string) => void;
  logout: () => void;
}

const AuthContext = createContext<AuthContextType>(null!);

export const AuthProvider = ({ children }: { children: React.ReactNode }) => {
  const [user, setUser] = useState(null);
  const login = (token: string) => { /* set token, fetch user */ };
  const logout = () => { /* remove token */ };
  return (
    <AuthContext.Provider value={{ user, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
};
export const useAuth = () => useContext(AuthContext);
"@

Write-File "frontend\src\context\WalletContext.tsx" @"
import React, { createContext, useContext, useState } from 'react';

interface WalletContextType {
  balance: number;
  refreshBalance: () => void;
}

const WalletContext = createContext<WalletContextType>(null!);

export const WalletProvider = ({ children }: { children: React.ReactNode }) => {
  const [balance, setBalance] = useState(0);
  const refreshBalance = async () => { /* fetch from API */ };
  return (
    <WalletContext.Provider value={{ balance, refreshBalance }}>
      {children}
    </WalletContext.Provider>
  );
};
export const useWallet = () => useContext(WalletContext);
"@

Write-File "frontend\src\services\api.ts" @"
import axios from 'axios';

export const api = axios.create({
  baseURL: process.env.REACT_APP_API_URL || 'http://localhost:3000',
});
api.interceptors.request.use(config => {
  const token = localStorage.getItem('token');
  if (token) config.headers.Authorization = `Bearer \${token}`;
  return config;
});
"@

Write-File "frontend\src\socket\useSocket.ts" @"
import { io } from 'socket.io-client';
import { useMemo } from 'react';

export const useSocket = () => {
  return useMemo(() => io(process.env.REACT_APP_API_URL || 'http://localhost:3000'), []);
};
"@

Write-File "frontend\Dockerfile" @"
FROM node:18-alpine as builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=builder /app/build /usr/share/nginx/html
EXPOSE 80
CMD [\"nginx\", \"-g\", \"daemon off;\"]
"@

# docker-compose.yml at root
Write-File "docker-compose.yml" @"
version: '3'
services:
  postgres:
    image: postgres:13
    environment:
      POSTGRES_DB: vehauction
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    ports:
      - \"5432:5432\"
    volumes:
      - pgdata:/var/lib/postgresql/data

  redis:
    image: redis:6
    ports:
      - \"6379:6379\"

  backend:
    build: ./backend
    ports:
      - \"3000:3000\"
    depends_on:
      - postgres
      - redis
    environment:
      DB_HOST: postgres
      REDIS_HOST: redis

  frontend:
    build: ./frontend
    ports:
      - \"80:80\"
    depends_on:
      - backend
volumes:
  pgdata:
"@

Write-Host "✅ All files created successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:"
Write-Host "1. cd backend"
Write-Host "2. npm install"
Write-Host "3. cd ../frontend"
Write-Host "4. npm install"
Write-Host "5. cd .."
Write-Host "6. docker-compose up"
Write-Host "7. Open http://localhost in your browser"