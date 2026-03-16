import { CanActivate, ExecutionContext, Injectable } from '@nestjs/common';

@Injectable()
export class WsJwtGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    // You'll implement actual JWT validation later
    return true;
  }
}
