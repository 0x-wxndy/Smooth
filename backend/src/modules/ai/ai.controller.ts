import { Controller, Get, Post, Body, UseGuards, Req } from '@nestjs/common';
import { AiService } from './ai.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('ai')
@UseGuards(JwtAuthGuard)
export class AiController {
  constructor(private aiService: AiService) {}

  @Get('usage')
  usage(@Req() req: { user: { id: string } }) {
    return this.aiService.getUsage(req.user.id);
  }

  @Post('chat')
  chat(@Req() req: { user: { id: string } }, @Body('message') message: string) {
    return this.aiService.chat(req.user.id, message);
  }
}
