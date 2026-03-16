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
    client.join(uction_\);
  }

  @SubscribeMessage('leaveAuction')
  handleLeave(@MessageBody() auctionId: string, @ConnectedSocket() client: Socket) {
    client.leave(uction_\);
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
      this.server.to(uction_\).emit('newBid', bid);
    } catch (error) {
      client.emit('bidError', error.message);
    }
  }
}
