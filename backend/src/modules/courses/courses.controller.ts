import {
  Controller,
  Get,
  Post,
  Param,
  Query,
  Body,
  UseGuards,
  Req,
} from '@nestjs/common';
import { CoursesService } from './courses.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('courses')
export class CoursesController {
  constructor(private coursesService: CoursesService) {}

  @Get()
  findAll(
    @Query('category') category?: string,
    @Query('difficulty') difficulty?: string,
    @Query('isFree') isFree?: string,
    @Query('search') search?: string,
  ) {
    return this.coursesService.findAll({ category, difficulty, isFree, search });
  }

  @Get('recommended')
  recommended() {
    return this.coursesService.getRecommended();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.coursesService.findOne(id);
  }

  @UseGuards(JwtAuthGuard)
  @Post(':id/enroll')
  enroll(@Param('id') id: string, @Req() req: { user: { id: string } }) {
    return this.coursesService.enroll(req.user.id, id);
  }

  @UseGuards(JwtAuthGuard)
  @Post(':id/bookmark')
  toggleBookmark(@Param('id') id: string, @Req() req: { user: { id: string } }) {
    return this.coursesService.toggleBookmark(req.user.id, id);
  }
}
