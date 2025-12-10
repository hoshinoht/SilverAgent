// Profile Screen - User profile and settings
// Displays user information, family loop settings, and healthcare preferences

import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notifyOnBooking = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header with user info
            _buildHeader(theme),

            // Settings sections
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildPersonalInfoSection(theme),
                    const SizedBox(height: 16),
                    _buildFamilyLoopSection(theme),
                    const SizedBox(height: 16),
                    _buildHealthcareSection(theme),
                    const SizedBox(height: 24),
                    // App info
                    Text(
                      'SilverAgent v1.0 · Made with ❤️ for seniors',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: Colors.black45,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(height: 16),
          // User info
          Row(
            children: [
              // Avatar
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.person, size: 40, color: Colors.white),
              ),
              const SizedBox(width: 16),
              // Name and phone
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ah Ma',
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '+65 9123 4567',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection(ThemeData theme) {
    return _buildSection(
      theme: theme,
      title: 'Personal Information',
      children: [
        _buildInfoTile(
          icon: Icons.person,
          label: 'Full Name',
          value: 'Tan Ah Ma',
          theme: theme,
        ),
        const Divider(height: 1),
        _buildInfoTile(
          icon: Icons.phone,
          label: 'Phone',
          value: '+65 9123 4567',
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildFamilyLoopSection(ThemeData theme) {
    return _buildSection(
      theme: theme,
      title: 'Family Loop',
      children: [
        ListTile(
          leading: Icon(Icons.people, color: theme.colorScheme.primary),
          title: Text('Caregiver Contact', style: theme.textTheme.bodyLarge),
          subtitle: Text(
            'John Tan (Son)',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // Navigate to caregiver details
          },
        ),
        const Divider(height: 1),
        SwitchListTile(
          secondary: Icon(
            Icons.notifications,
            color: theme.colorScheme.primary,
          ),
          title: Text('Notify on booking', style: theme.textTheme.bodyLarge),
          value: _notifyOnBooking,
          onChanged: (value) {
            setState(() {
              _notifyOnBooking = value;
            });
          },
          activeTrackColor: theme.colorScheme.primary,
        ),
      ],
    );
  }

  Widget _buildHealthcareSection(ThemeData theme) {
    return _buildSection(
      theme: theme,
      title: 'Healthcare Preferences',
      children: [
        _buildInfoTile(
          icon: Icons.favorite,
          label: 'Preferred Polyclinic',
          value: 'Bedok',
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildSection({
    required ThemeData theme,
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.black54,
              ),
            ),
          ),
          // Section content
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(label, style: theme.textTheme.bodyLarge),
      trailing: Text(
        value,
        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
      ),
    );
  }
}
