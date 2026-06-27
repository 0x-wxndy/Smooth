import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { ServiceStatus } from '@prisma/client';

@Injectable()
export class MarketplaceService {
  constructor(private prisma: PrismaService) {}

  async findAll(category?: string) {
    const services = await this.prisma.service.findMany({
      where: {
        status: ServiceStatus.ACTIVE,
        ...(category && { category: category as never }),
      },
      include: {
        provider: { select: { id: true, displayName: true, avatarUrl: true } },
      },
    });
    return { data: services };
  }

  async findOne(id: string) {
    const service = await this.prisma.service.findUnique({
      where: { id },
      include: {
        provider: {
          select: { id: true, displayName: true, avatarUrl: true },
        },
      },
    });
    if (!service) throw new NotFoundException('Service not found');
    return { data: service };
  }
}
