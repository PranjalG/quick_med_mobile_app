/// In-app alert shown on the Alerts screen.
///
/// Later: populate from Firebase Cloud Messaging (daily offers, order updates).
class AppAlert {
  final String id;
  final String title;
  final String body;
  final DateTime? createdAt;
  final AppAlertCategory category;
  final bool read;

  const AppAlert({
    required this.id,
    required this.title,
    required this.body,
    this.createdAt,
    this.category = AppAlertCategory.offer,
    this.read = false,
  });

  AppAlert copyWith({bool? read}) => AppAlert(
        id: id,
        title: title,
        body: body,
        createdAt: createdAt,
        category: category,
        read: read ?? this.read,
      );
}

enum AppAlertCategory {
  offer,
  order,
  general,
}

extension AppAlertCategoryX on AppAlertCategory {
  String get label => switch (this) {
        AppAlertCategory.offer => 'Offers',
        AppAlertCategory.order => 'Orders',
        AppAlertCategory.general => 'Updates',
      };
}
