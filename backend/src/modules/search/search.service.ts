import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { CourseStatus, ServiceStatus, JobStatus } from '@prisma/client';

@Injectable()
export class SearchService {
  constructor(private prisma: PrismaService) {}

  async search(q: string, type: string) {
    if (!q.trim()) {
      return { data: { courses: [], services: [], jobs: [], teachers: [] } };
    }

    const [courses, services, jobs, teachers] = await Promise.all([
      type === 'all' || type === 'courses'
        ? this.prisma.course.findMany({
            where: {
              status: CourseStatus.PUBLISHED,
              OR: [
                { title: { contains: q, mode: 'insensitive' } },
                { description: { contains: q, mode: 'insensitive' } },
              ],
            },
            take: 10,
          })
        : [],
      type === 'all' || type === 'services'
        ? this.prisma.service.findMany({
            where: {
              status: ServiceStatus.ACTIVE,
              title: { contains: q, mode: 'insensitive' },
            },
            take: 10,
          })
        : [],
      type === 'all' || type === 'jobs'
        ? this.prisma.jobPosting.findMany({
            where: {
              status: JobStatus.OPEN,
              title: { contains: q, mode: 'insensitive' },
            },
            take: 10,
          })
        : [],
      type === 'all' || type === 'teachers'
        ? this.prisma.user.findMany({
            where: {
              role: 'TEACHER',
              displayName: { contains: q, mode: 'insensitive' },
            },
            take: 10,
            select: { id: true, displayName: true, avatarUrl: true },
          })
        : [],
    ]);

    return { data: { courses, services, jobs, teachers } };
  }
}
