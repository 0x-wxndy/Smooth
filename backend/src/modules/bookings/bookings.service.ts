import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { BookingStatus, BookingType } from '@prisma/client';

@Injectable()
export class BookingsService {
  constructor(private prisma: PrismaService) {}

  async listForUser(userId: string) {
    const bookings = await this.prisma.booking.findMany({
      where: {
        OR: [{ requesterId: userId }, { providerId: userId }],
      },
      orderBy: { scheduledAt: 'asc' },
    });
    return { data: bookings };
  }

  async create(requesterId: string, body: Record<string, unknown>) {
    const booking = await this.prisma.booking.create({
      data: {
        requesterId,
        providerId: body.providerId as string,
        bookingType: body.bookingType as BookingType,
        scheduledAt: new Date(body.scheduledAt as string),
        durationMinutes: (body.durationMinutes as number) ?? 60,
        capacity: (body.capacity as number) ?? 1,
        notes: body.notes as string | undefined,
      },
    });
    return { data: booking };
  }

  async updateStatus(id: string, status: string) {
    const booking = await this.prisma.booking.update({
      where: { id },
      data: { status: status as BookingStatus },
    });
    return { data: booking };
  }
}
