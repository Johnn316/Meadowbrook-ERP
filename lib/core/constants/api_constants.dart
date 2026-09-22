class ApiConstants {
  // Base URL - replace with your actual PHP API server
  static const String baseUrl = 'https://yourdomain.com/api';

  // Auth Endpoints
  static const String login = '$baseUrl/auth/login.php';
  static const String logout = '$baseUrl/auth/logout.php';
  static const String refreshToken = '$baseUrl/auth/refresh.php';

  // CRM - Contacts
  static const String contacts = '$baseUrl/crm/contacts.php';
  static const String contactCreate = '$baseUrl/crm/contacts/create.php';
  static const String contactUpdate = '$baseUrl/crm/contacts/update.php';
  static const String contactDelete = '$baseUrl/crm/contacts/delete.php';

  // CRM - Leads
  static const String leads = '$baseUrl/crm/leads.php';
  static const String leadCreate = '$baseUrl/crm/leads/create.php';
  static const String leadUpdate = '$baseUrl/crm/leads/update.php';
  static const String leadDelete = '$baseUrl/crm/leads/delete.php';

  // CRM - Invoices
  static const String invoices = '$baseUrl/crm/invoices.php';
  static const String invoiceCreate = '$baseUrl/crm/invoices/create.php';
  static const String invoiceUpdate = '$baseUrl/crm/invoices/update.php';
  static const String invoiceDelete = '$baseUrl/crm/invoices/delete.php';

  // Farm - Crops
  static const String crops = '$baseUrl/farm/crops.php';
  static const String cropCreate = '$baseUrl/farm/crops/create.php';
  static const String cropUpdate = '$baseUrl/farm/crops/update.php';
  static const String cropDelete = '$baseUrl/farm/crops/delete.php';

  // Farm - Livestock
  static const String livestock = '$baseUrl/farm/livestock.php';
  static const String livestockCreate = '$baseUrl/farm/livestock/create.php';
  static const String livestockUpdate = '$baseUrl/farm/livestock/update.php';
  static const String livestockDelete = '$baseUrl/farm/livestock/delete.php';

  // Farm - Equipment
  static const String equipment = '$baseUrl/farm/equipment.php';
  static const String equipmentCreate = '$baseUrl/farm/equipment/create.php';
  static const String equipmentUpdate = '$baseUrl/farm/equipment/update.php';
  static const String equipmentDelete = '$baseUrl/farm/equipment/delete.php';

  // Sync
  static const String syncPush = '$baseUrl/sync/push.php';
  static const String syncPull = '$baseUrl/sync/pull.php';
  static const String syncStatus = '$baseUrl/sync/status.php';

  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Map<String, String> authHeaders(String token) => {
    ...defaultHeaders,
    'Authorization': 'Bearer $token',
  };
}