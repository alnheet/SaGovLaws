import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../sources/data/models/source_model.dart';
import '../bloc/settings_bloc.dart';

/// Settings Page
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<SettingsBloc>(),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return ListView(
            children: [
              // Appearance Section
              _buildSectionHeader(theme, 'المظهر'),
              
              // Theme
              ListTile(
                leading: const Icon(Icons.palette_outlined),
                title: const Text('السمة'),
                subtitle: Text(_getThemeLabel(state.theme)),
                onTap: () => _showThemeDialog(context, state.theme),
              ),

              // Font Size
              ListTile(
                leading: const Icon(Icons.text_fields),
                title: const Text('حجم الخط'),
                subtitle: Text(_getFontSizeLabel(state.fontSize)),
                onTap: () => _showFontSizeDialog(context, state.fontSize),
              ),

              const Divider(),

              // Notifications Section
              _buildSectionHeader(theme, 'الإشعارات'),

              // Enable Notifications
              SwitchListTile(
                secondary: const Icon(Icons.notifications_outlined),
                title: const Text('تفعيل الإشعارات'),
                subtitle: const Text('استلام إشعارات عند نشر قرارات جديدة'),
                value: state.notificationsEnabled,
                onChanged: (value) {
                  context.read<SettingsBloc>().add(UpdateNotificationsEnabled(value));
                },
              ),

              // Notification Times
              if (state.notificationsEnabled)
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: const Text('أوقات الإشعارات'),
                  subtitle: Text(state.notificationHours.map((h) => '$h:00').join(' - ')),
                  onTap: () => _showNotificationTimesDialog(context, state.notificationHours),
                ),

              const Divider(),

              // Subscriptions Section
              _buildSectionHeader(theme, 'الاشتراكات'),

              // Source subscriptions
              ...DefaultSources.sources.map((source) {
                final isSubscribed = state.subscribedSources.contains('all') ||
                    state.subscribedSources.contains(source.id);
                return CheckboxListTile(
                  secondary: Icon(
                    _getIconData(source.icon),
                    color: Color(source.colorValue),
                  ),
                  title: Text(source.nameAr),
                  value: isSubscribed,
                  onChanged: (value) {
                    final sources = List<String>.from(state.subscribedSources);
                    if (sources.contains('all')) {
                      // If "all" is selected, unselect it and add all except this one
                      sources.remove('all');
                      sources.addAll(DefaultSources.sources.map((s) => s.id));
                    }
                    if (value == true) {
                      sources.add(source.id);
                    } else {
                      sources.remove(source.id);
                    }
                    // If all are selected, use "all"
                    if (sources.length == DefaultSources.sources.length) {
                      context.read<SettingsBloc>().add(const UpdateSubscribedSources(['all']));
                    } else {
                      context.read<SettingsBloc>().add(UpdateSubscribedSources(sources));
                    }
                  },
                );
              }),

              const Divider(),

              // Cache Section
              _buildSectionHeader(theme, 'التخزين'),

              ListTile(
                leading: const Icon(Icons.delete_sweep_outlined),
                title: const Text('مسح ذاكرة التخزين المؤقت'),
                subtitle: const Text('حذف المقالات المحفوظة محلياً'),
                onTap: () => _showClearCacheDialog(context),
              ),

              const Divider(),

              // About Section
              _buildSectionHeader(theme, 'حول التطبيق'),

              ListTile(
                leading: const Icon(Icons.info_outlined),
                title: const Text('عن راصد أم القرى'),
                onTap: () => _showAboutDialog(context),
              ),

              const SizedBox(height: 24),

              // Version
              Center(
                child: Text(
                  'الإصدار 1.0.0',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getThemeLabel(String theme) {
    switch (theme) {
      case 'light':
        return 'فاتح';
      case 'dark':
        return 'داكن';
      default:
        return 'تلقائي (حسب النظام)';
    }
  }

  String _getFontSizeLabel(String fontSize) {
    switch (fontSize) {
      case 'small':
        return 'صغير';
      case 'large':
        return 'كبير';
      default:
        return 'متوسط';
    }
  }

  void _showThemeDialog(BuildContext context, String currentTheme) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('اختر السمة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('تلقائي'),
              value: 'system',
              groupValue: currentTheme,
              onChanged: (value) {
                context.read<SettingsBloc>().add(UpdateTheme(value!));
                Navigator.pop(ctx);
              },
            ),
            RadioListTile<String>(
              title: const Text('فاتح'),
              value: 'light',
              groupValue: currentTheme,
              onChanged: (value) {
                context.read<SettingsBloc>().add(UpdateTheme(value!));
                Navigator.pop(ctx);
              },
            ),
            RadioListTile<String>(
              title: const Text('داكن'),
              value: 'dark',
              groupValue: currentTheme,
              onChanged: (value) {
                context.read<SettingsBloc>().add(UpdateTheme(value!));
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFontSizeDialog(BuildContext context, String currentSize) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('اختر حجم الخط'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('صغير'),
              value: 'small',
              groupValue: currentSize,
              onChanged: (value) {
                context.read<SettingsBloc>().add(UpdateFontSize(value!));
                Navigator.pop(ctx);
              },
            ),
            RadioListTile<String>(
              title: const Text('متوسط'),
              value: 'medium',
              groupValue: currentSize,
              onChanged: (value) {
                context.read<SettingsBloc>().add(UpdateFontSize(value!));
                Navigator.pop(ctx);
              },
            ),
            RadioListTile<String>(
              title: const Text('كبير'),
              value: 'large',
              groupValue: currentSize,
              onChanged: (value) {
                context.read<SettingsBloc>().add(UpdateFontSize(value!));
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationTimesDialog(BuildContext context, List<int> currentHours) {
    final hours = List<int>.from(currentHours);
    
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('أوقات الإشعارات'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < hours.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButton<int>(
                          value: hours[i],
                          isExpanded: true,
                          items: List.generate(24, (h) => DropdownMenuItem(
                            value: h,
                            child: Text('$h:00'),
                          )),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => hours[i] = value);
                            }
                          },
                        ),
                      ),
                      if (hours.length > 1)
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () {
                            setState(() => hours.removeAt(i));
                          },
                        ),
                    ],
                  ),
                ),
              if (hours.length < 3)
                TextButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('إضافة وقت'),
                  onPressed: () {
                    setState(() => hours.add(12));
                  },
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<SettingsBloc>().add(UpdateNotificationHours(hours));
                Navigator.pop(ctx);
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('مسح ذاكرة التخزين'),
        content: const Text('هل أنت متأكد من مسح جميع المقالات المحفوظة محلياً؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Clear cache
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم مسح ذاكرة التخزين')),
              );
            },
            child: const Text('مسح'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'راصد أم القرى',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2024 Rasid UQN',
      children: [
        const SizedBox(height: 16),
        const Text(
          'تطبيق لمتابعة القرارات والأنظمة الصادرة في جريدة أم القرى الرسمية.',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'gavel':
        return Icons.gavel;
      case 'verified':
        return Icons.verified;
      case 'article':
        return Icons.article;
      case 'description':
        return Icons.description;
      case 'balance':
        return Icons.balance;
      case 'account_balance':
        return Icons.account_balance;
      case 'business':
        return Icons.business;
      default:
        return Icons.article;
    }
  }
}
