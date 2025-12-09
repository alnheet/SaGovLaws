import 'package:equatable/equatable.dart';

/// User Entity
class AppUser extends Equatable {
  final String uid;
  final String? email;
  final String? displayName;
  final bool notificationEnabled;
  final List<int> notificationHours;
  final List<String> subscribedSources;
  final String theme;
  final String fontSize;
  final List<String> fcmTokens;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AppUser({
    required this.uid,
    this.email,
    this.displayName,
    this.notificationEnabled = true,
    this.notificationHours = const [8, 14, 20],
    this.subscribedSources = const ['all'],
    this.theme = 'system',
    this.fontSize = 'medium',
    this.fcmTokens = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        uid,
        email,
        displayName,
        notificationEnabled,
        notificationHours,
        subscribedSources,
        theme,
        fontSize,
        fcmTokens,
        createdAt,
        updatedAt,
      ];

  AppUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    bool? notificationEnabled,
    List<int>? notificationHours,
    List<String>? subscribedSources,
    String? theme,
    String? fontSize,
    List<String>? fcmTokens,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      notificationHours: notificationHours ?? this.notificationHours,
      subscribedSources: subscribedSources ?? this.subscribedSources,
      theme: theme ?? this.theme,
      fontSize: fontSize ?? this.fontSize,
      fcmTokens: fcmTokens ?? this.fcmTokens,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
