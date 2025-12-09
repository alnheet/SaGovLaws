import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/repositories/settings_repository.dart';

// Events
abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {}

class UpdateTheme extends SettingsEvent {
  final String theme;
  const UpdateTheme(this.theme);

  @override
  List<Object?> get props => [theme];
}

class UpdateFontSize extends SettingsEvent {
  final String fontSize;
  const UpdateFontSize(this.fontSize);

  @override
  List<Object?> get props => [fontSize];
}

class UpdateNotificationsEnabled extends SettingsEvent {
  final bool enabled;
  const UpdateNotificationsEnabled(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class UpdateNotificationHours extends SettingsEvent {
  final List<int> hours;
  const UpdateNotificationHours(this.hours);

  @override
  List<Object?> get props => [hours];
}

class UpdateSubscribedSources extends SettingsEvent {
  final List<String> sources;
  const UpdateSubscribedSources(this.sources);

  @override
  List<Object?> get props => [sources];
}

// State
class SettingsState extends Equatable {
  final String theme;
  final String fontSize;
  final bool notificationsEnabled;
  final List<int> notificationHours;
  final List<String> subscribedSources;

  const SettingsState({
    this.theme = 'system',
    this.fontSize = 'medium',
    this.notificationsEnabled = true,
    this.notificationHours = const [8, 14, 20],
    this.subscribedSources = const ['all'],
  });

  SettingsState copyWith({
    String? theme,
    String? fontSize,
    bool? notificationsEnabled,
    List<int>? notificationHours,
    List<String>? subscribedSources,
  }) {
    return SettingsState(
      theme: theme ?? this.theme,
      fontSize: fontSize ?? this.fontSize,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notificationHours: notificationHours ?? this.notificationHours,
      subscribedSources: subscribedSources ?? this.subscribedSources,
    );
  }

  @override
  List<Object?> get props => [
        theme,
        fontSize,
        notificationsEnabled,
        notificationHours,
        subscribedSources,
      ];
}

// BLoC
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository repository;

  SettingsBloc({required this.repository}) : super(const SettingsState()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateTheme>(_onUpdateTheme);
    on<UpdateFontSize>(_onUpdateFontSize);
    on<UpdateNotificationsEnabled>(_onUpdateNotificationsEnabled);
    on<UpdateNotificationHours>(_onUpdateNotificationHours);
    on<UpdateSubscribedSources>(_onUpdateSubscribedSources);
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    final theme = await repository.getTheme();
    final fontSize = await repository.getFontSize();
    final notificationsEnabled = await repository.getNotificationsEnabled();
    final notificationHours = await repository.getNotificationHours();
    final subscribedSources = await repository.getSubscribedSources();

    emit(SettingsState(
      theme: theme,
      fontSize: fontSize,
      notificationsEnabled: notificationsEnabled,
      notificationHours: notificationHours,
      subscribedSources: subscribedSources,
    ));
  }

  Future<void> _onUpdateTheme(
    UpdateTheme event,
    Emitter<SettingsState> emit,
  ) async {
    await repository.setTheme(event.theme);
    emit(state.copyWith(theme: event.theme));
  }

  Future<void> _onUpdateFontSize(
    UpdateFontSize event,
    Emitter<SettingsState> emit,
  ) async {
    await repository.setFontSize(event.fontSize);
    emit(state.copyWith(fontSize: event.fontSize));
  }

  Future<void> _onUpdateNotificationsEnabled(
    UpdateNotificationsEnabled event,
    Emitter<SettingsState> emit,
  ) async {
    await repository.setNotificationsEnabled(event.enabled);
    emit(state.copyWith(notificationsEnabled: event.enabled));
  }

  Future<void> _onUpdateNotificationHours(
    UpdateNotificationHours event,
    Emitter<SettingsState> emit,
  ) async {
    await repository.setNotificationHours(event.hours);
    emit(state.copyWith(notificationHours: event.hours));
  }

  Future<void> _onUpdateSubscribedSources(
    UpdateSubscribedSources event,
    Emitter<SettingsState> emit,
  ) async {
    await repository.setSubscribedSources(event.sources);
    emit(state.copyWith(subscribedSources: event.sources));
  }
}
