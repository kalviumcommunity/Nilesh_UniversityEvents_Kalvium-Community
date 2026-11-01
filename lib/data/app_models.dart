import 'package:flutter/material.dart';

class CampusEvent {
  const CampusEvent({
    required this.id,
    required this.title,
    required this.club,
    required this.dateShort,
    required this.dateFull,
    required this.time,
    required this.place,
    required this.venue,
    required this.tag,
    required this.type,
    required this.status,
    required this.description,
    required this.colors,
  });

  final String id;
  final String title;
  final String club;
  final String dateShort;
  final String dateFull;
  final String time;
  final String place;
  final String venue;
  final String tag;
  final String type;
  final String status;
  final String description;
  final List<Color> colors;
}

class CampusClub {
  const CampusClub(
    this.name,
    this.members,
    this.type,
    this.icon,
    this.colors, {
    this.id = '',
  });

  final String id;
  final String name;
  final int members;
  final String type;
  final IconData icon;
  final List<Color> colors;
}

class UserNotification {
  const UserNotification(
    this.title,
    this.body,
    this.time,
    this.type,
    this.tint,
  );

  final String title;
  final String body;
  final String time;
  final String type;
  final Color tint;
}
