import 'package:flutter/material.dart';

/// PLACEHOLDER DATA for the frontend demo only. Replace with real data
/// from the backend layer when it exists.

class MockEvent {
  const MockEvent({
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
  final String dateShort; // "12 Oct"
  final String dateFull; // "Sat, 12 Oct 2025"
  final String time;
  final String place; // "On Campus"
  final String venue; // "Main Lab, Block A"
  final String tag; // "Workshop"
  final String type; // Explore filter: Events | Workshops
  final String status; // Ongoing | Upcoming | Completed | Draft
  final String description;
  final List<Color> colors;
}

class MockClub {
  const MockClub(this.name, this.members, this.type, this.icon, this.colors);
  final String name;
  final int members;
  final String type; // Technical | Cultural | Social
  final IconData icon;
  final List<Color> colors;
}

class MockVolunteer {
  const MockVolunteer(this.name, this.status, this.colors);
  final String name;
  final String status; // Assigned | Pending
  final List<Color> colors;
}

class MockNotification {
  const MockNotification(
      this.title, this.body, this.time, this.type, this.tint);
  final String title;
  final String body;
  final String time;
  final String type; // Events | Mentions | System
  final Color tint;
}

const _blueDark = [Color(0xFF1E2F52), Color(0xFF0E1830)];
const _bluePurple = [Color(0xFF5B4BC4), Color(0xFF1E2A5E)];
const _teal = [Color(0xFF2F6F8F), Color(0xFF0F2438)];
const _night = [Color(0xFF2B3550), Color(0xFF0B1220)];

const webDev = MockEvent(
  id: 'web-dev',
  title: 'Web Development Workshop',
  club: 'Tech Club',
  dateShort: '12 Oct',
  dateFull: 'Sat, 12 Oct 2025',
  time: '10:00 AM – 1:00 PM',
  place: 'On Campus',
  venue: 'Main Lab, Block A',
  tag: 'Workshop',
  type: 'Workshops',
  status: 'Ongoing',
  description: 'A beginner-friendly workshop to learn modern web '
      'development with hands-on projects.',
  colors: _blueDark,
);

const aiForEveryone = MockEvent(
  id: 'ai-everyone',
  title: 'AI for Everyone',
  club: 'AI Club',
  dateShort: '18 Oct',
  dateFull: 'Sat, 18 Oct 2025',
  time: '4:00 PM – 6:00 PM',
  place: 'Online',
  venue: 'Online (link shared by email)',
  tag: 'Talk',
  type: 'Events',
  status: 'Upcoming',
  description: 'An accessible introduction to AI: what it is, what it can '
      'do, and how to start learning.',
  colors: _teal,
);

const designSprint = MockEvent(
  id: 'design-sprint',
  title: 'Design Sprint',
  club: 'Design Club',
  dateShort: '20 Oct',
  dateFull: 'Mon, 20 Oct 2025',
  time: '9:00 AM – 5:00 PM',
  place: 'On Campus',
  venue: 'Studio 2, Block C',
  tag: 'Workshop',
  type: 'Workshops',
  status: 'Upcoming',
  description: 'Go from problem to prototype in a single day with '
      'your team.',
  colors: _bluePurple,
);

const roboticsBootcamp = MockEvent(
  id: 'robotics',
  title: 'Robotics Bootcamp',
  club: 'Robotics Club',
  dateShort: '25 Oct',
  dateFull: 'Sat, 25 Oct 2025',
  time: '10:00 AM – 4:00 PM',
  place: 'Main Auditorium',
  venue: 'Main Auditorium',
  tag: 'Workshop',
  type: 'Workshops',
  status: 'Upcoming',
  description: 'Build and program a small robot from scratch.',
  colors: _night,
);

const hackVerse = MockEvent(
  id: 'hackverse',
  title: 'HackVerse 2025',
  club: 'Tech Club',
  dateShort: '25 Oct',
  dateFull: 'Sat, 25 Oct 2025',
  time: '9:00 AM – 9:00 PM',
  place: 'Main Auditorium',
  venue: 'Main Auditorium',
  tag: 'Hackathon',
  type: 'Events',
  status: 'Completed',
  description: 'A day-long campus hackathon.',
  colors: _night,
);

const pitchNight = MockEvent(
  id: 'pitch-night',
  title: 'Startup Pitch Night',
  club: 'Entrepreneurship Cell',
  dateShort: '02 Nov',
  dateFull: 'Sun, 2 Nov 2025',
  time: '6:00 PM – 8:00 PM',
  place: 'Seminar Hall',
  venue: 'Seminar Hall',
  tag: 'Event',
  type: 'Events',
  status: 'Draft',
  description: 'Teams pitch their ideas to a panel of mentors.',
  colors: _bluePurple,
);

const openSourceDay = MockEvent(
  id: 'open-source',
  title: 'Open Source Day',
  club: 'Tech Club',
  dateShort: '02 Sep',
  dateFull: '2 Sep 2025',
  time: '10:00 AM – 3:00 PM',
  place: 'On Campus',
  venue: 'Lab 3',
  tag: 'Workshop',
  type: 'Workshops',
  status: 'Completed',
  description: 'Make your first open-source contribution.',
  colors: _blueDark,
);

const featuredEvent = MockEvent(
  id: 'tech-fest',
  title: 'Tech Fest 2025',
  club: 'Tech Club',
  dateShort: '12 Oct',
  dateFull: '12 – 14 Oct 2025',
  time: '9:00 AM – 6:00 PM',
  place: 'On Campus',
  venue: 'Main Campus',
  tag: 'Festival',
  type: 'Events',
  status: 'Upcoming',
  description: 'Bigger Ideas. Brighter Futures. Three days of talks, '
      'workshops and competitions.',
  colors: _bluePurple,
);

const exploreEvents = [webDev, aiForEveryone, designSprint, roboticsBootcamp];
const myUpcomingEvents = [webDev, aiForEveryone, hackVerse];
const myPastEvents = [openSourceDay];
const manageEvents = [webDev, aiForEveryone, hackVerse, pitchNight];

const clubs = [
  MockClub('Coding Club', 120, 'Technical', Icons.code,
      [Color(0xFF6C8CF0), Color(0xFF4A63C4)]),
  MockClub('AI Club', 98, 'Technical', Icons.psychology_outlined,
      [Color(0xFF6F86A8), Color(0xFF3D5273)]),
  MockClub('Robotics Club', 76, 'Technical', Icons.smart_toy_outlined,
      [Color(0xFF9B7BEA), Color(0xFF6B4BC4)]),
  MockClub('Design Club', 64, 'Cultural', Icons.palette_outlined,
      [Color(0xFFC77BE0), Color(0xFF8E4BC4)]),
  MockClub('Music Society', 52, 'Cultural', Icons.music_note_outlined,
      [Color(0xFFEA8AA0), Color(0xFFC44B6B)]),
  MockClub(
      'Social Impact Club',
      40,
      'Social',
      Icons.volunteer_activism_outlined,
      [Color(0xFF6BC4A0), Color(0xFF2E9E6B)]),
];

const volunteers = [
  MockVolunteer('Riya Sen', 'Assigned', [Color(0xFF8E9BE8), Color(0xFF4A63C4)]),
  MockVolunteer(
      'Arjun Mehta', 'Assigned', [Color(0xFF6BC4A0), Color(0xFF2E9E6B)]),
  MockVolunteer('Sneha Das', 'Pending', [Color(0xFFEA8AA0), Color(0xFFC44B6B)]),
  MockVolunteer(
      'Rahul Verma', 'Assigned', [Color(0xFFF0B15A), Color(0xFFC47A1E)]),
  MockVolunteer(
      'Priya Kapoor', 'Pending', [Color(0xFFC77BE0), Color(0xFF8E4BC4)]),
];

const notifications = [
  MockNotification(
      'New registration',
      'Riya Sen registered for Web Dev Workshop',
      '2m ago',
      'Events',
      Color(0xFFF6D9C4)),
  MockNotification('Volunteer update', 'Arjun Mehta marked as available',
      '10m ago', 'Mentions', Color(0xFFCDEBDD)),
  MockNotification('Event reminder', 'HackVerse 2025 is in 2 days', '1h ago',
      'Events', Color(0xFFF7E0A8)),
  MockNotification('System', 'Your event has been published', '', 'System',
      Color(0xFFD5DCF7)),
];

const topEvents = [
  ('Web Development Workshop', 248),
  ('AI for Everyone', 186),
  ('HackVerse 2025', 142),
];
