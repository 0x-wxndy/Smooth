import { Controller, Get, Param, Query } from '@nestjs/common';
import { MarketplaceService } from './marketplace.service';

@Controller('services')
export class MarketplaceController {
  constructor(private marketplaceService: MarketplaceService) {}

  @Get()
  findAll(@Query('category') category?: string) {
    return this.marketplaceService.findAll(category);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.marketplaceService.findOne(id);
  }
}
