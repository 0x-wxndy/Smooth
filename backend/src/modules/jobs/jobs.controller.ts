import { Controller, Get, Param, Query } from '@nestjs/common';
import { JobsService } from './jobs.service';

@Controller('jobs')
export class JobsController {
  constructor(private jobsService: JobsService) {}

  @Get()
  findAll(
    @Query('remote') remote?: string,
    @Query('type') type?: string,
    @Query('category') category?: string,
  ) {
    return this.jobsService.findAll({ remote, type, category });
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.jobsService.findOne(id);
  }
}
