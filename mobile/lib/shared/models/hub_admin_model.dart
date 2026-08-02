import '../../core/utils/money.dart';

class HubRoom {
  const HubRoom({
    required this.id,
    required this.name,
    required this.description,
    required this.capacity,
    required this.priceHourCents,
    required this.priceDayCents,
    this.available = true,
    this.amenities = const [],
  });

  final String id;
  final String name;
  final String description;
  final int capacity;
  final int priceHourCents;
  final int priceDayCents;
  final bool available;
  final List<String> amenities;

  String get priceHourLabel => '${Money.format(priceHourCents)} / h';
  String get priceDayLabel => '${Money.format(priceDayCents)} / day';
}

class RoomBooking {
  const RoomBooking({
    required this.id,
    required this.roomId,
    required this.userId,
    required this.startAt,
    required this.endAt,
    required this.billing,
    required this.totalCents,
    required this.status,
    required this.createdAt,
    this.roomName,
    this.userName,
  });

  final String id;
  final String roomId;
  final String userId;
  final String startAt;
  final String endAt;
  final String billing; // hour | day
  final int totalCents;
  final String status;
  final String createdAt;
  final String? roomName;
  final String? userName;
}

class PrintServiceItem {
  const PrintServiceItem({
    required this.id,
    required this.title,
    required this.description,
    required this.priceCents,
    this.unit = 'unit',
    this.active = true,
  });

  final String id;
  final String title;
  final String description;
  final int priceCents;
  final String unit;
  final bool active;

  String get priceLabel => Money.format(priceCents);
}

class PrintOrder {
  const PrintOrder({
    required this.id,
    required this.serviceId,
    required this.userId,
    required this.quantity,
    required this.totalCents,
    required this.status,
    required this.createdAt,
    this.notes,
    this.serviceTitle,
    this.userName,
  });

  final String id;
  final String serviceId;
  final String userId;
  final int quantity;
  final String? notes;
  final int totalCents;
  final String status;
  final String createdAt;
  final String? serviceTitle;
  final String? userName;
}

class UserReport {
  const UserReport({
    required this.id,
    required this.reporterId,
    required this.reportedUserId,
    required this.reason,
    required this.status,
    required this.createdAt,
    this.details,
    this.reporterName,
    this.reportedName,
  });

  final String id;
  final String reporterId;
  final String reportedUserId;
  final String reason;
  final String? details;
  final String status;
  final String createdAt;
  final String? reporterName;
  final String? reportedName;
}

class ContactMessage {
  const ContactMessage({
    required this.id,
    required this.name,
    required this.email,
    required this.subject,
    required this.body,
    required this.status,
    required this.createdAt,
    this.userId,
  });

  final String id;
  final String? userId;
  final String name;
  final String email;
  final String subject;
  final String body;
  final String status;
  final String createdAt;
}

class ServiceBookingRecord {
  const ServiceBookingRecord({
    required this.id,
    required this.serviceId,
    required this.clientId,
    required this.providerId,
    required this.totalCents,
    required this.status,
    required this.createdAt,
    this.serviceTitle,
    this.clientName,
    this.providerName,
  });

  final String id;
  final String serviceId;
  final String clientId;
  final String providerId;
  final int totalCents;
  final String status;
  final String createdAt;
  final String? serviceTitle;
  final String? clientName;
  final String? providerName;
}

class AdminStats {
  const AdminStats({
    this.learners = 0,
    this.teachers = 0,
    this.clients = 0,
    this.courses = 0,
    this.services = 0,
    this.serviceBookings = 0,
    this.roomBookings = 0,
    this.printOrders = 0,
    this.openReports = 0,
    this.newMessages = 0,
    this.jobs = 0,
  });

  final int learners;
  final int teachers;
  final int clients;
  final int courses;
  final int services;
  final int serviceBookings;
  final int roomBookings;
  final int printOrders;
  final int openReports;
  final int newMessages;
  final int jobs;

  int get totalUsers => learners + teachers + clients;
}

class PaymentLogRecord {
  const PaymentLogRecord({
    required this.id,
    required this.purpose,
    required this.title,
    required this.amountCents,
    required this.gateway,
    required this.status,
    required this.createdAt,
    this.userId,
    this.userName,
    this.reference,
    this.itemId,
  });

  final String id;
  final String? userId;
  final String? userName;
  final String purpose;
  final String title;
  final int amountCents;
  final String gateway;
  final String status;
  final String? reference;
  final String? itemId;
  final String createdAt;

  String get amountLabel => Money.format(amountCents);
  bool get isSuccess => status == 'success';
}

class AdminActivityLog {
  const AdminActivityLog({
    required this.id,
    required this.action,
    required this.createdAt,
    this.actorId,
    this.actorName,
    this.targetType,
    this.targetId,
    this.details,
  });

  final String id;
  final String? actorId;
  final String? actorName;
  final String action;
  final String? targetType;
  final String? targetId;
  final String? details;
  final String createdAt;
}
