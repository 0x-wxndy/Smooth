import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { JobStatus } from '@prisma/client';

@Injectable()
export class JobsService {
  constructor(private prisma: PrismaService) {}

  async findAll(filters: { remote?: string; type?: string; category?: string }) {
    const jobs = await this.prisma.jobPosting.findMany({
      where: {
        status: JobStatus.OPEN,
        ...(filters.remote !== undefined && { remote: filters.remote === 'true' }),
        ...(filters.type && { type: filters.type as never }),
        ...(filters.category && { category: filters.category as never }),
      },
      include: { company: true },
      orderBy: { createdAt: 'desc' },
    });
    return { data: jobs };
  }

  async findOne(id: string) {
    const job = await this.prisma.jobPosting.findUnique({
      where: { id },
      include: { company: true },
    });
    if (!job) throw new NotFoundException('Job not found');
    return { data: job };
  }
}
