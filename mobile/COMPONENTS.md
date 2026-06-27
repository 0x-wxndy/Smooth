# Component Library

Reusable UI primitives in `lib/shared/widgets/`. All follow Material 3 + Smooth brand tokens from `lib/core/theme/`.

## Components

| Widget | File | Usage |
|--------|------|-------|
| `SmoothButton` | `smooth_button.dart` | Primary actions; variants: primary, secondary, outline, ghost |
| `SmoothCard` | `smooth_components.dart` | Tappable card container with border radius 16 |
| `SmoothSearchField` | `smooth_components.dart` | Search input with icon |
| `SmoothChipFilter` | `smooth_components.dart` | Horizontal filter chips |
| `CoinBadge` | `smooth_components.dart` | Gamification coin display |
| `LevelBadge` | `smooth_components.dart` | User level pill |
| `SectionHeader` | `smooth_components.dart` | Section title + optional action |
| `EmptyState` | `smooth_components.dart` | Placeholder for empty lists |
| `CourseCard` | `cards.dart` | Full & compact course list item |
| `ServiceCard` | `cards.dart` | Marketplace service row |
| `JobCard` | `cards.dart` | Job posting row |

## Design Tokens

```dart
AppColors.primary      // #2563EB
AppColors.secondary    // #7C3AED
AppColors.background   // #F8FAFC
AppColors.surface      // #FFFFFF
AppColors.textPrimary  // #0F172A
```

Typography: **Inter** via `google_fonts`.

Spacing scale: 8, 12, 16, 20, 24, 32.

Border radius: 12 (inputs/buttons), 16 (cards), 20 (badges).

## Example

```dart
SmoothButton(
  label: 'Enroll — Free',
  onPressed: () {},
)

CourseCard(
  course: course,
  onTap: () => context.push('/courses/${course.id}'),
)
```
