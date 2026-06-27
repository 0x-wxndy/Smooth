import { Controller, Get, Post, Patch, Body, Param, UseGuards, Req } from '@nestjs/common';
import { BookingsService } from './bookings.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('bookings')
@UseGuards(JwtAuthGuard)
export class BookingsController {
  constructor(private bookingsService: BookingsService) {}

  @Get()
  list(@Req() req: { user: { id: string } }) {
    return this.bookingsService.listForUser(req.user.id);
  }

  @Post()
  create(@Req() req: { user: { id: string } }, @Body() body: Record<string, unknown>) {
    return this.bookingsService.create(req.user.id, body);
  }

  @Patch(':id')
  updateStatus(@Param('id') id: string, @Body('status') status: string) {
    return this.bookingsService.updateStatus(id, status);
  }
}
