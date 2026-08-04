import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/providers/database_provider.dart';
import '../../../shared/providers/subscription_provider.dart';
import '../payment_models.dart';

/// Applies post-payment side effects (enroll, tokens, etc.).
abstract final class PaymentFulfillment {
  static Future<void> apply(
    BuildContext context,
    PaymentCheckoutArgs args,
    PaymentGateway gateway,
  ) async {
    final container = ProviderScope.containerOf(context, listen: false);
    final userId = container.read(authProvider).user?.id;
    if (userId == null) return;

    final db = container.read(databaseProvider);

    switch (args.purpose) {
      case PaymentPurpose.course:
        if (args.itemId != null) {
          await db.enrollCourse(userId, args.itemId!);
          container.invalidate(coursesProvider);
          container.invalidate(courseProvider(args.itemId!));
          container.invalidate(enrolledCoursesProvider);
          container.invalidate(enrollmentCountProvider);
          container.invalidate(teacherEnrollmentStatsProvider);
        }
      case PaymentPurpose.service:
        if (args.itemId != null) {
          await db.awardBookingToProvider(args.itemId!, clientId: userId);
          container.invalidate(bookedServicesProvider);
        }
      case PaymentPurpose.aiTokens:
        if (args.aiTokens != null && args.aiTokens! > 0) {
          await db.creditAiTokens(userId, args.aiTokens!);
          container.invalidate(aiQuotaProvider);
          container.invalidate(gamificationProvider);
        }
      case PaymentPurpose.subscription:
        if (args.subscriptionPlan != null) {
          await container.read(subscriptionProvider.notifier).selectPlan(args.subscriptionPlan!);
          container.invalidate(aiQuotaProvider);
        }
      case PaymentPurpose.hubRoom:
        if (args.itemId != null &&
            args.hubStartAt != null &&
            args.hubEndAt != null &&
            args.hubBilling != null) {
          await db.bookRoom(
            roomId: args.itemId!,
            userId: userId,
            billing: args.hubBilling!,
            startAt: args.hubStartAt!,
            endAt: args.hubEndAt!,
          );
          container.invalidate(roomBookingsProvider);
          container.invalidate(adminStatsProvider);
        }
      case PaymentPurpose.hubPrint:
        if (args.itemId != null) {
          await db.createPrintOrder(
            serviceId: args.itemId!,
            userId: userId,
            quantity: args.printQuantity,
            notes: args.printNotes,
            scheduledAt: args.printScheduledAt,
          );
          container.invalidate(printOrdersProvider);
          container.invalidate(adminStatsProvider);
        }
      case PaymentPurpose.escrow:
        if (args.itemId != null) {
          final deal = await db.getEscrowDeal(args.itemId!);
          await db.fundEscrowDeal(args.itemId!);
          if (deal != null) {
            container.invalidate(dmMessagesProvider(deal.conversationId));
            container.invalidate(dmConversationProvider(deal.conversationId));
          }
          container.invalidate(conversationsProvider);
          container.invalidate(escrowDealProvider(args.itemId!));
          container.invalidate(adminStatsProvider);
        }
    }

    await logPayment(
      context,
      args: args,
      gateway: gateway,
      success: true,
      reference: '${gateway.name.toUpperCase()}-${DateTime.now().millisecondsSinceEpoch % 1000000}',
    );
  }

  static Future<void> logPayment(
    BuildContext context, {
    required PaymentCheckoutArgs args,
    required PaymentGateway gateway,
    required bool success,
    String? reference,
  }) async {
    final container = ProviderScope.containerOf(context, listen: false);
    final user = container.read(authProvider).user;
    await container.read(databaseProvider).insertPaymentLog(
          userId: user?.id,
          userName: user?.displayName,
          purpose: args.purpose.name,
          title: args.title,
          amountCents: args.amountCentimes,
          gateway: gateway.name,
          status: success ? 'success' : 'failed',
          reference: reference,
          itemId: args.itemId,
        );
    container.invalidate(paymentLogsProvider);
  }
}
