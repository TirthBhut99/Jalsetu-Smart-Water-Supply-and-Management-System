// Core constants for the Jalsetu application

class AppConstants {
  AppConstants._();

  static const String appName = 'Jalsetu';
  static const String appTagline = 'Smart Water Supply & Management';

  // Admin emails for role assignment
  static const List<String> adminEmails = [
    'admin@jalsetu.com',
    'waterdept@gmail.com',
  ];

  // Firestore collection names
  static const String usersCollection = 'users';
  static const String areasCollection = 'areas';
  static const String schedulesCollection = 'schedules';
  static const String complaintsCollection = 'complaints';
  static const String alertsCollection = 'alerts';

  // Complaint priority keywords
  static const List<String> highPriorityKeywords = [
    'no water',
    'leak',
    'contamination',
    'burst',
    'sewage',
    'flooding',
  ];

  // Pagination
  static const int complaintsPageSize = 15;
  static const int alertsPageSize = 20;
}
