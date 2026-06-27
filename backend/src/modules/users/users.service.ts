import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class UsersService {
  constructor(private prisma: PrismaService) {}

  async getFullProfile(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: {
        wallet: true,
        learnerProfile: true,
        teacherProfile: true,
        clientProfile: true,
        achievements: { include: { achievement: true } },
      },
    });
    if (!user) throw new NotFoundException('User not found');
    const { passwordHash, ...safe } = user;
    return { data: safe };
  }

  async updateProfile(
    userId: string,
    data: { displayName?: string; avatarUrl?: string },
  ) {
    const user = await this.prisma.user.update({
      where: { id: userId },
      data,
    });
    const { passwordHash, ...safe } = user;
    return { data: safe };
  }

  async getPublicProfile(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: { teacherProfile: true },
    });
    if (!user?.teacherProfile) {
      throw new NotFoundException('Profile not found');
    }
    return {
      data: {
        id: user.id,
        displayName: user.displayName,
        avatarUrl: user.avatarUrl,
        profile: user.teacherProfile,
      },
    };
  }

  async listTeachers() {
    const teachers = await this.prisma.user.findMany({
      where: { role: 'TEACHER', teacherProfile: { isNot: null } },
      include: { teacherProfile: true },
      take: 50,
    });
    return {
      data: teachers.map(({ passwordHash: _pw, ...t }) => t),
    };
  }
}
