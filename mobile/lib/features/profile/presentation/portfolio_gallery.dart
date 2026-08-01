import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class PortfolioItem {
  const PortfolioItem({
    required this.imageUrl,
    required this.title,
    required this.tag,
  });

  final String imageUrl;
  final String title;
  final String tag;
}


List<PortfolioItem> mockPortfolioItems(String userId) {
  const titles = [
    'Brand identity refresh',
    'Mobile app UI kit',
    'Landing page design',
    'Dashboard redesign',
  ];
  const tags = ['Branding', 'UI/UX', 'Web', 'Product'];
  const images = [
    'assets/portfolio/P1.jpg',
    'assets/portfolio/P2.jpg',
    'assets/portfolio/P3.jpg',
    'assets/portfolio/P4.jpg',
  ];

  return List.generate(4, (i) {
    return PortfolioItem(
      imageUrl: images[i],
      title: titles[i],
      tag: tags[i],
    );
  });
}

class PortfolioGallery extends StatelessWidget {
  const PortfolioGallery({super.key, required this.items});

  final List<PortfolioItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.92,
      ),
      itemBuilder: (_, i) => _PortfolioTile(item: items[i]),
    );
  }
}

class _PortfolioTile extends StatelessWidget {
  const _PortfolioTile({required this.item});

  final PortfolioItem item;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            item.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: AppColors.surfaceVariant,
              child: const Icon(Icons.image_outlined, color: AppColors.textMuted),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.75),
                ],
                stops: const [0.5, 1.0],
              ),
            ),
          ),
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                item.tag,
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          Positioned(
            left: 10,
            right: 10,
            bottom: 10,
            child: Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 13,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}