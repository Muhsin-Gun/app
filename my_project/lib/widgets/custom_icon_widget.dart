import 'package:flutter/material.dart';

class CustomIconWidget extends StatelessWidget {
  final String iconName;
  final Color? color;
  final double? size;
  final VoidCallback? onTap;

  const CustomIconWidget({
    super.key,
    required this.iconName,
    this.color,
    this.size,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final IconData iconData = _getIconData(iconName);
    
    Widget iconWidget = Icon(
      iconData,
      color: color ?? Theme.of(context).iconTheme.color,
      size: size ?? Theme.of(context).iconTheme.size,
    );

    if (onTap != null) {
      iconWidget = GestureDetector(
        onTap: onTap,
        child: iconWidget,
      );
    }

    return iconWidget;
  }

  IconData _getIconData(String iconName) {
    switch (iconName.toLowerCase()) {
      // Navigation
      case 'home':
        return Icons.home;
      case 'dashboard':
        return Icons.dashboard;
      case 'menu':
        return Icons.menu;
      case 'back':
      case 'arrow_back':
        return Icons.arrow_back;
      case 'arrow_forward':
        return Icons.arrow_forward;
      case 'close':
        return Icons.close;
      case 'keyboard_arrow_down':
        return Icons.keyboard_arrow_down;
      case 'keyboard_arrow_up':
        return Icons.keyboard_arrow_up;
      case 'keyboard_arrow_left':
        return Icons.keyboard_arrow_left;
      case 'keyboard_arrow_right':
        return Icons.keyboard_arrow_right;

      // Authentication
      case 'login':
        return Icons.login;
      case 'logout':
        return Icons.logout;
      case 'person':
      case 'user':
        return Icons.person;
      case 'email':
        return Icons.email;
      case 'lock':
        return Icons.lock;
      case 'visibility':
        return Icons.visibility;
      case 'visibility_off':
        return Icons.visibility_off;
      case 'fingerprint':
        return Icons.fingerprint;

      // Actions
      case 'add':
        return Icons.add;
      case 'edit':
        return Icons.edit;
      case 'delete':
        return Icons.delete;
      case 'save':
        return Icons.save;
      case 'cancel':
        return Icons.cancel;
      case 'check':
        return Icons.check;
      case 'done':
        return Icons.done;
      case 'refresh':
        return Icons.refresh;
      case 'search':
        return Icons.search;
      case 'filter':
      case 'tune':
        return Icons.tune;
      case 'sort':
        return Icons.sort;
      case 'more_vert':
        return Icons.more_vert;
      case 'more_horiz':
        return Icons.more_horiz;

      // Content
      case 'image':
        return Icons.image;
      case 'camera':
      case 'camera_alt':
        return Icons.camera_alt;
      case 'photo_library':
        return Icons.photo_library;
      case 'upload':
        return Icons.upload;
      case 'download':
        return Icons.download;
      case 'attach_file':
        return Icons.attach_file;
      case 'file_copy':
        return Icons.file_copy;

      // Communication
      case 'message':
      case 'chat':
        return Icons.message;
      case 'chat_bubble':
        return Icons.chat_bubble;
      case 'chat_bubble_outline':
        return Icons.chat_bubble_outline;
      case 'send':
        return Icons.send;
      case 'call':
        return Icons.call;
      case 'phone':
        return Icons.phone;
      case 'notifications':
        return Icons.notifications;
      case 'notifications_outlined':
        return Icons.notifications_outlined;
      case 'notifications_off':
        return Icons.notifications_off;

      // Business
      case 'business':
        return Icons.business;
      case 'work':
        return Icons.work;
      case 'assignment':
        return Icons.assignment;
      case 'task':
      case 'task_alt':
        return Icons.task_alt;
      case 'calendar':
      case 'calendar_today':
        return Icons.calendar_today;
      case 'schedule':
        return Icons.schedule;
      case 'access_time':
        return Icons.access_time;
      case 'timer':
        return Icons.timer;

      // Services
      case 'cleaning_services':
        return Icons.cleaning_services;
      case 'plumbing':
        return Icons.plumbing;
      case 'electrical_services':
        return Icons.electrical_services;
      case 'carpenter':
        return Icons.carpenter;
      case 'format_paint':
        return Icons.format_paint;
      case 'yard':
        return Icons.yard;
      case 'handyman':
        return Icons.handyman;
      case 'build':
        return Icons.build;
      case 'construction':
        return Icons.construction;

      // Status
      case 'pending':
      case 'hourglass_empty':
        return Icons.hourglass_empty;
      case 'assigned':
      case 'assignment_ind':
        return Icons.assignment_ind;
      case 'active':
      case 'play_circle':
        return Icons.play_circle;
      case 'completed':
      case 'check_circle':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      case 'error':
        return Icons.error;
      case 'warning':
        return Icons.warning;
      case 'info':
        return Icons.info;

      // Rating & Reviews
      case 'star':
        return Icons.star;
      case 'star_border':
        return Icons.star_border;
      case 'star_half':
        return Icons.star_half;
      case 'thumb_up':
        return Icons.thumb_up;
      case 'thumb_down':
        return Icons.thumb_down;
      case 'favorite':
        return Icons.favorite;
      case 'favorite_border':
        return Icons.favorite_border;
      case 'bookmark':
        return Icons.bookmark;
      case 'bookmark_border':
        return Icons.bookmark_border;

      // Location
      case 'location_on':
        return Icons.location_on;
      case 'location_off':
        return Icons.location_off;
      case 'my_location':
        return Icons.my_location;
      case 'place':
        return Icons.place;
      case 'map':
        return Icons.map;
      case 'directions':
        return Icons.directions;

      // Money & Payment
      case 'payment':
        return Icons.payment;
      case 'credit_card':
        return Icons.credit_card;
      case 'money':
        return Icons.attach_money;
      case 'wallet':
      case 'account_balance_wallet':
        return Icons.account_balance_wallet;
      case 'receipt':
        return Icons.receipt;

      // Settings
      case 'settings':
        return Icons.settings;
      case 'account_circle':
        return Icons.account_circle;
      case 'profile':
      case 'person_outline':
        return Icons.person_outline;
      case 'help':
        return Icons.help;
      case 'help_outline':
        return Icons.help_outline;
      case 'info_outline':
        return Icons.info_outline;
      case 'privacy_tip':
        return Icons.privacy_tip;
      case 'security':
        return Icons.security;

      // Social
      case 'share':
        return Icons.share;
      case 'group':
        return Icons.group;
      case 'people':
        return Icons.people;
      case 'public':
        return Icons.public;
      case 'language':
        return Icons.language;

      // Apple (for Apple Sign In)
      case 'apple':
        return Icons.apple;

      // Default
      default:
        return Icons.help_outline;
    }
  }
}
