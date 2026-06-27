import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class GamificationService {
  constructor(private prisma: PrismaService) {}

  async getWallet(userId: string) {
    const wallet = await this.prisma.gamificationWallet.findUnique({
      where: { userId },
    });
    return { data: wallet };
  }

  async getLeaderboard() {
    const leaders = await this.prisma.gamificationWallet.findMany({
      take: 20,
      orderBy: { xp: 'desc' },
      include: {
        user: { select: { id: true, displayName: true, avatarUrl: true } },
      },
    });
    return { data: leaders };
  }

  async claimDailyLogin(userId: string) {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const wallet = await this.prisma.gamificationWallet.findUnique({
      where: { userId },
    });
    if (!wallet) return { data: null };

    const lastLogin = wallet.lastLoginDate
      ? new Date(wallet.lastLoginDate)
      : null;
    if (lastLogin) {
      lastLogin.setHours(0, 0, 0, 0);
      if (lastLogin.getTime() === today.getTime()) {
        return { data: { alreadyClaimed: true, wallet } };
      }
    }

    const yesterday = new Date(today);
    yesterday.setDate(yesterday.getDate() - 1);
    const continued =
      lastLogin && lastLogin.getTime() === yesterday.getTime();
    const newStreak = continued ? wallet.currentStreak + 1 : 1;

    const updated = await this.prisma.gamificationWallet.update({
      where: { userId },
      data: {
        coins: { increment: 5 },
        xp: { increment: 10 },
        currentStreak: newStreak,
        longestStreak: Math.max(wallet.longestStreak, newStreak),
        lastLoginDate: today,
        level: Math.floor((wallet.xp + 10) / 300) + 1,
      },
    });
    return { data: { reward: { coins: 5, xp: 10 }, wallet: updated } };
  }
}
