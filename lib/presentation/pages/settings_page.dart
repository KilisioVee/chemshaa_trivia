import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
    required this.phoneNumber,
    required this.joinedOn,
    this.onContactUs,
    this.onFollowUpdates,
    this.onDeleteAccount,
    this.onLogout,
  });

  final String phoneNumber;
  final DateTime joinedOn;
  final VoidCallback? onContactUs;
  final VoidCallback? onFollowUpdates;
  final VoidCallback? onDeleteAccount;
  final VoidCallback? onLogout;

  static const Color _background = Color(0xFFFFDC24);
  static const Color _danger = Color(0xFFE04B32);
  static const Color _mutedText = Color(0xFF77682E);

  String get _joinedOnLabel {
    final hour = joinedOn.hour % 12 == 0 ? 12 : joinedOn.hour % 12;
    final minute = joinedOn.minute.toString().padLeft(2, '0');
    final period = joinedOn.hour >= 12 ? 'PM' : 'AM';
    return '${joinedOn.month}/${joinedOn.day}/${joinedOn.year} $hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Padding(
          padding:  EdgeInsets.fromLTRB(5.w, 2.h, 5.w, 2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.maybePop(context),
                icon: const Icon(Icons.arrow_back_rounded),
                iconSize: 35,
                color: Colors.black,
                padding: EdgeInsets.zero,
                tooltip: 'Back',
              ),
              SizedBox(height: 2.h),
              Text(
                'More',
                style: TextStyle(
                  fontSize: 24.sp,
                  height: 1,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                  letterSpacing: -1.8,
                ),
              ),
              SizedBox(height: 2.h),
              _InfoItem(
                icon: Icons.phone_android_rounded,
                title: 'Phone Number',
                subtitle: phoneNumber,
              ),
              SizedBox(height: 2.h),
              _InfoItem(
                icon: Icons.calendar_month_outlined,
                title: 'Joined On',
                subtitle: _joinedOnLabel,
              ),
              SizedBox(height: 2.h),
              _MoreAction(
                icon: Icons.mail_outline_rounded,
                label: 'Contact Us',
                onTap: onContactUs,
              ),
              SizedBox(height: 2.h),
              _MoreAction(
                icon: Icons.lightbulb_outline_rounded,
                label: 'Follow Our Updates On',
                trailing: const Text(
                  '𝕏',
                  style: TextStyle(fontSize: 30, color: Colors.black),
                ),
                onTap: onFollowUpdates,
              ),
              SizedBox(height: 2.h),
              _MoreAction(
                icon: Icons.delete_outline_rounded,
                label: 'Delete Account',
                color: _danger,
                onTap: onDeleteAccount,
              ),
              SizedBox(height: 4.h),
              _MoreAction(
                icon: Icons.logout_rounded,
                label: 'Log Out',
                color: _danger,
                onTap: onLogout,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:  EdgeInsets.only(top: 1.h),
          child: Icon(icon, size: 30, color: Colors.black),
        ),
         SizedBox(width: 5.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:  TextStyle(
                  fontSize: 18.sp,
                  height: 1.12,
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                ),
              ),
               SizedBox(height: 1.h),
              Text(
                subtitle,
                style:  TextStyle(
                  fontSize: 16.sp,
                  height: 1,
                  color: SettingsPage._mutedText,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MoreAction extends StatelessWidget {
  const _MoreAction({
    required this.icon,
    required this.label,
    this.color = Colors.black,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Icon(icon, size: 35, color: color),
               SizedBox(width: 5.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 18.sp,
                  height: 1.12,
                  color: color,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(width: 2.w),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}