import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { PrismaModule } from './prisma/prisma.module';
import { AuthModule } from './modules/auth/auth.module';
import { UsersModule } from './modules/users/users.module';
import { CoursesModule } from './modules/courses/courses.module';
import { MarketplaceModule } from './modules/marketplace/marketplace.module';
import { BookingsModule } from './modules/bookings/bookings.module';
import { JobsModule } from './modules/jobs/jobs.module';
import { GamificationModule } from './modules/gamification/gamification.module';
import { AiModule } from './modules/ai/ai.module';
import { SearchModule } from './modules/search/search.module';
import { AdminModule } from './modules/admin/admin.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    PrismaModule,
    AuthModule,
    UsersModule,
    CoursesModule,
    MarketplaceModule,
    BookingsModule,
    JobsModule,
    GamificationModule,
    AiModule,
    SearchModule,
    AdminModule,
  ],
})
export class AppModule {}
