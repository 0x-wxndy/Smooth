import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { CourseStatus } from '@prisma/client';

@Injectable()
export class CoursesService {
  constructor(private prisma: PrismaService) {}

  async findAll(filters: {
    category?: string;
    difficulty?: string;
    isFree?: string;
    search?: string;
  }) {
    const courses = await this.prisma.course.findMany({
      where: {
        status: CourseStatus.PUBLISHED,
        ...(filters.category && {
          category: filters.category as never,
        }),
        ...(filters.difficulty && {
          difficulty: filters.difficulty as never,
        }),
        ...(filters.isFree !== undefined && {
          isFree: filters.isFree === 'true',
        }),
        ...(filters.search && {
          OR: [
            { title: { contains: filters.search, mode: 'insensitive' } },
            { description: { contains: filters.search, mode: 'insensitive' } },
          ],
        }),
      },
      include: { teacher: { select: { id: true, displayName: true, avatarUrl: true } } },
      orderBy: { enrollmentCount: 'desc' },
    });
    return { data: courses };
  }

  async findOne(id: string) {
    const course = await this.prisma.course.findUnique({
      where: { id },
      include: {
        modules: { include: { lessons: true }, orderBy: { sortOrder: 'asc' } },
        teacher: { select: { id: true, displayName: true, avatarUrl: true } },
        quizzes: true,
      },
    });
    if (!course) throw new NotFoundException('Course not found');
    return { data: course };
  }

  async getRecommended() {
    const courses = await this.prisma.course.findMany({
      where: { status: CourseStatus.PUBLISHED },
      take: 6,
      orderBy: { ratingAvg: 'desc' },
    });
    return { data: courses };
  }

  async enroll(userId: string, courseId: string) {
    const enrollment = await this.prisma.enrollment.upsert({
      where: { userId_courseId: { userId, courseId } },
      create: { userId, courseId },
      update: {},
    });
    return { data: enrollment };
  }

  async toggleBookmark(userId: string, courseId: string) {
    const existing = await this.prisma.enrollment.findUnique({
      where: { userId_courseId: { userId, courseId } },
    });
    if (!existing) {
      const enrollment = await this.prisma.enrollment.create({
        data: { userId, courseId, bookmarked: true },
      });
      return { data: enrollment };
    }
    const updated = await this.prisma.enrollment.update({
      where: { id: existing.id },
      data: { bookmarked: !existing.bookmarked },
    });
    return { data: updated };
  }
}
