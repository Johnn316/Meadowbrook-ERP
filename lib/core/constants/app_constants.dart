class AppConstants {
  // App Info
  static const String appName = 'Meadowbrook ERP';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Smart Farming & Business Management';

  // Modules
  static const String moduleCRM = 'CRM';
  static const String moduleFarm = 'Farm';
  static const String moduleFinance = 'Finance';
  static const String moduleEquipment = 'Equipment';

  // CRM
  static const List<String> leadStatuses = [
    'New',
    'Contacted',
    'Qualified',
    'Proposal',
    'Won',
    'Lost',
  ];

  static const List<String> contactTypes = [
    'Farmer',
    'Supplier',
    'Buyer',
    'Partner',
    'Other',
  ];

  // Farm - Kenya specific
  static const List<String> kenyanCrops = [
    'Maize',
    'Tea',
    'Coffee',
    'Wheat',
    'Rice',
    'Sugarcane',
    'Beans',
    'Potatoes',
    'Tomatoes',
    'Avocado',
    'Soybeans',
    'Sorghum',
  ];

  static const List<String> kenyanLivestock = [
    'Cattle',
    'Sheep',
    'Goats',
    'Pigs',
    'Chickens',
    'Ducks',
    'Rabbits',
    'Camels',
  ];

  // All 47 official Kenya counties (alphabetical)
  static const List<String> kenyanCounties = [
    'Baringo',
    'Bomet',
    'Bungoma',
    'Busia',
    'Elgeyo Marakwet',
    'Embu',
    'Garissa',
    'Homa Bay',
    'Isiolo',
    'Kajiado',
    'Kakamega',
    'Kericho',
    'Kiambu',
    'Kilifi',
    'Kirinyaga',
    'Kisii',
    'Kisumu',
    'Kitui',
    'Kwale',
    'Laikipia',
    'Lamu',
    'Machakos',
    'Makueni',
    'Mandera',
    'Marsabit',
    'Meru',
    'Migori',
    'Mombasa',
    "Murang'a",
    'Nairobi',
    'Nakuru',
    'Nandi',
    'Narok',
    'Nyandarua',
    'Nyamira',
    'Nyeri',
    'Samburu',
    'Siaya',
    'Taita Taveta',
    'Tana River',
    'Tharaka Nithi',
    'Trans Nzoia',
    'Turkana',
    'Uasin Gishu',
    'Vihiga',
    'Wajir',
    'West Pokot',
  ];

  // Currency
  static const String currency = 'KES';
  static const String currencySymbol = 'Ksh';

  // Sync
  static const int syncIntervalMinutes = 15;
  static const int apiTimeoutSeconds = 30;

  // Pagination
  static const int pageSize = 20;

  // Local Storage Keys
  static const String keyUserId = 'user_id';
  static const String keyUserName = 'user_name';
  static const String keyAuthToken = 'auth_token';
  static const String keyLastSync = 'last_sync';
  static const String keyThemeMode = 'theme_mode';
}