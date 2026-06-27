import { Injectable, HttpException, HttpStatus } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../../prisma/prisma.service';

const MOCK_RESPONSES: Record<string, string> = {
  default:
    'Based on your goals, I recommend starting with fundamentals then building a small project. Would you like a weekly study plan?',
  mobile:
    'For mobile development, begin with Dart/Flutter basics or Swift/Kotlin depending on your target. Complete one UI project and one API-integrated app.',
  design:
    'Start with visual hierarchy and typography, then move to Figma prototyping. Practice by redesigning one app screen daily.',
};

@Injectable()
export class AiService {
  private dailyLimit: number;

  constructor(
    private prisma: PrismaService,
    config: ConfigService,
  ) {
    this.dailyLimit = Number(config.get('AI_DAILY_LIMIT') ?? 5);
  }

  async getUsage(userId: string) {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const log = await this.prisma.aiUsageLog.findUnique({
      where: { userId_date: { userId, date: today } },
    });
    const used = log?.interactionsCount ?? 0;
    return {
      data: {
        used,
        limit: this.dailyLimit,
        remaining: Math.max(0, this.dailyLimit - used),
      },
    };
  }

  async chat(userId: string, message: string) {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const log = await this.prisma.aiUsageLog.upsert({
      where: { userId_date: { userId, date: today } },
      create: { userId, date: today, interactionsCount: 0 },
      update: {},
    });

    if (log.interactionsCount >= this.dailyLimit) {
      throw new HttpException(
        'Daily AI limit reached. Use coins to unlock more.',
        HttpStatus.TOO_MANY_REQUESTS,
      );
    }

    await this.prisma.aiUsageLog.update({
      where: { id: log.id },
      data: { interactionsCount: { increment: 1 } },
    });

    const lower = message.toLowerCase();
    let reply = MOCK_RESPONSES.default;
    if (lower.includes('mobile') || lower.includes('flutter')) {
      reply = MOCK_RESPONSES.mobile;
    } else if (lower.includes('design') || lower.includes('ui')) {
      reply = MOCK_RESPONSES.design;
    }

    return {
      data: {
        message: reply,
        role: 'assistant',
      },
    };
  }
}
