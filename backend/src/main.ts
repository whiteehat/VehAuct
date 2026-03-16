import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.useGlobalPipes(new ValidationPipe({ whitelist: true }));
  app.enableCors({
    origin: ['https://veh-auct.vercel.app'], // no trailing slash
    credentials: true,
  });
  
  await app.listen(process.env.PORT || 3000); // use Render's PORT
}
bootstrap();
