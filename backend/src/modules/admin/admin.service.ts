import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class AdminService {
  constructor(private prisma: PrismaService) {}

  async getOverview() {
    const [users, courses, services, jobs] = await Promise.all([
      this.prisma.user.count(),
      this.prisma.course.count(),
      this.prisma.service.count(),
      this.prisma.jobPosting.count(),
    ]);
    return {
      data: { users, courses, services, jobs },
    };
  }

  async listUsers() {
    const users = await this.prisma.user.findMany({
      take: 100,
      orderBy: { createdAt: 'desc' },
      select: {
        id: true,
        email: true,
        role: true,
        displayName: true,
        isActive: true,
        createdAt: true,
      },
    });
    return { data: users };
  }
}
