import { Controller, Get, Post, UseGuards, Req } from '@nestjs/common';
import { GamificationService } from './gamification.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('gamification')
@UseGuards(JwtAuthGuard)
export class GamificationController {
  constructor(private gamificationService: GamificationService) {}

  @Get('wallet')
  wallet(@Req() req: { user: { id: string } }) {
    return this.gamificationService.getWallet(req.user.id);
  }

  @Get('leaderboard')
  leaderboard() {
    return this.gamificationService.getLeaderboard();
  }

  @Post('daily-login')
  dailyLogin(@Req() req: { user: { id: string } }) {
    return this.gamificationService.claimDailyLogin(req.user.id);
  }
}
