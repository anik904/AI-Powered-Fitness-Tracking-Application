import 'package:flutter/material.dart';
import 'profile_section_header.dart';
import 'settings_list_tile.dart';

class SignedInProfileView extends StatefulWidget {
  final VoidCallback onSignOut;

  const SignedInProfileView({super.key, required this.onSignOut});

  @override
  State<SignedInProfileView> createState() => _SignedInProfileViewState();
}

class _SignedInProfileViewState extends State<SignedInProfileView> {
  bool _autoSync = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Profile Card
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(Icons.person, size: 40, color: Theme.of(context).colorScheme.onPrimaryContainer),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'user@example.com',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Signed In',
                          style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // Edit profile action
                  },
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // 2. Data Synchronization
          const ProfileSectionHeader(title: 'Data Synchronization'),
          SettingsListTile(
            icon: Icons.sync,
            title: 'Sync Now',
            subtitle: 'Last sync: Today, 10:30 AM',
            onTap: () {},
          ),
          SwitchListTile(
            secondary: Icon(Icons.autorenew, color: Theme.of(context).colorScheme.primary),
            title: const Text('Automatic Sync', style: TextStyle(fontWeight: FontWeight.w500)),
            value: _autoSync,
            onChanged: (value) {
              setState(() {
                _autoSync = value;
              });
            },
          ),

          const Divider(height: 32),

          // 3. Fitness Goals
          const ProfileSectionHeader(title: 'Fitness Goals'),
          SettingsListTile(
            icon: Icons.fitness_center,
            title: 'Daily Push-up Goal',
            subtitle: '50 Reps',
            onTap: () {},
          ),
          SettingsListTile(
            icon: Icons.accessibility_new,
            title: 'Daily Squat Goal',
            subtitle: '100 Reps',
            onTap: () {},
          ),
          SettingsListTile(
            icon: Icons.sports_gymnastics,
            title: 'Daily Jumping Jack Goal',
            subtitle: '200 Reps',
            onTap: () {},
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.save),
              label: const Text('Update Goals'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 40),
              ),
            ),
          ),

          const Divider(height: 32),

          // 4. Security
          const ProfileSectionHeader(title: 'Security'),
          SettingsListTile(
            icon: Icons.lock_reset,
            title: 'Change Password',
            onTap: () {},
          ),

          const Divider(height: 32),

          // 5. Data Management
          const ProfileSectionHeader(title: 'Data Management'),
          SettingsListTile(
            icon: Icons.cloud_download,
            title: 'Sync Data',
            onTap: () {},
          ),
          SettingsListTile(
            icon: Icons.delete_sweep,
            title: 'Delete All Local Data',
            textColor: Colors.red,
            iconColor: Colors.red,
            onTap: () {},
          ),
          SettingsListTile(
            icon: Icons.delete_forever,
            title: 'Delete Account',
            textColor: Colors.red,
            iconColor: Colors.red,
            onTap: () {},
          ),

          const Divider(height: 32),

          // 6. Information
          const ProfileSectionHeader(title: 'Information'),
          SettingsListTile(
            icon: Icons.privacy_tip,
            title: 'Privacy Policy',
            onTap: () {},
          ),
          SettingsListTile(
            icon: Icons.info_outline,
            title: 'About Application',
            onTap: () {},
          ),
          const ListTile(
            leading: Icon(Icons.new_releases, color: Colors.grey),
            title: Text('App Version', style: TextStyle(fontWeight: FontWeight.w500)),
            trailing: Text('1.0.0', style: TextStyle(color: Colors.grey)),
          ),

          const SizedBox(height: 40),

          // 7. Sign Out
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: ElevatedButton.icon(
              onPressed: widget.onSignOut,
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.1),
                foregroundColor: Colors.red,
                elevation: 0,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
