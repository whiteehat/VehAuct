import { CanActivate, ExecutionContext, Injectable } from '@nestjs/common';

@Injectable()
export class WsJwtGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    // You can add real JWT validation later
    return true;
  }
}
