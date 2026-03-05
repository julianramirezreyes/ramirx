class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'RAMIRX_API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  static const String tenantId = String.fromEnvironment(
    'RAMIRX_TENANT_ID',
    defaultValue: '',
  );

  static const String whatsappUrl = String.fromEnvironment(
    'RAMIRX_WHATSAPP_URL',
    defaultValue: 'https://wa.me/573207228467',
  );

  static const String bookingUrl = String.fromEnvironment(
    'RAMIRX_BOOKING_URL',
    defaultValue: 'https://wa.me/573207228467',
  );

  static const bool enableAdminRegistration = bool.fromEnvironment(
    'RAMIRX_ENABLE_ADMIN_REGISTRATION',
    defaultValue: false,
  );
}
