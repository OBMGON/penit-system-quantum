class ProductionConfig {
  // Configuración de la aplicación
  static const String appName = 'PenitSystem GeoSecure Quantum';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // Configuración de la institución
  static const String institutionName = 'SISTEMA PENITENCIARIO NACIONAL';
  static const String institutionSubtitle = 'República de Guinea Ecuatorial';
  static const String institutionAddress = 'Malabo, Guinea Ecuatorial';

  // Configuración de seguridad
  static const bool enableEncryption = true;
  static const bool enableAuditLog = true;
  static const bool enableBackup = true;

  // Configuración de rendimiento
  static const int maxInmatesPerPage = 50;
  static const int maxSearchResults = 100;
  static const bool enableCaching = true;

  // Configuración de reportes
  static const bool enablePDFExport = true;
  static const bool enableExcelExport = true;
  static const String defaultDateFormat = 'dd/MM/yyyy';

  // Configuración de notificaciones
  static const bool enablePushNotifications = true;
  static const bool enableEmailNotifications = false;

  // Configuración de sincronización
  static const bool enableAutoSync = true;
  static const int syncIntervalMinutes = 30;

  // Configuración de backup
  static const bool enableAutoBackup = true;
  static const int backupIntervalHours = 24;

  // Configuración de logs
  static const bool enableDebugLogs = false;
  static const bool enableErrorLogs = true;
  static const int maxLogEntries = 1000;

  // Configuración de UI
  static const bool enableAnimations = true;
  static const bool enableHapticFeedback = true;
  static const String defaultLanguage = 'es';

  // Configuración de accesibilidad
  static const bool enableLargeText = true;
  static const bool enableHighContrast = true;
  static const bool enableScreenReader = true;

  // Configuración de privacidad
  static const bool enableDataAnonymization = false;
  static const bool enableDataRetention = true;
  static const int dataRetentionDays = 2555; // 7 años

  // Configuración de cumplimiento
  static const bool enableGDPRCompliance = true;
  static const bool enableDataPortability = true;
  static const bool enableDataDeletion = true;

  // Configuración de soporte
  static const String supportEmail = 'soporte@penitsystem.ge';
  static const String supportPhone = '+240 555 012345';
  static const String supportWebsite = 'https://penitsystem.ge';

  // Configuración de licencia
  static const String licenseType = 'GOVERNMENT_ENTERPRISE';
  static const String licenseKey = 'GE-PENIT-2025-001';
  static final DateTime licenseExpiry = DateTime(2030, 12, 31);

  // Configuración de características premium
  static const bool enableAdvancedAnalytics = true;
  static const bool enablePredictiveModeling = true;
  static const bool enableRealTimeMonitoring = true;
  static const bool enableGeofencing = true;
  static const bool enableBiometricAuth = true;

  // Configuración de integración
  static const bool enableAPIIntegration = true;
  static const bool enableThirdPartyIntegrations = false;
  static const String apiVersion = 'v1.0';

  // Configuración de deployment
  static const bool enableStagingEnvironment = false;
  static const bool enableProductionEnvironment = true;
  static const String deploymentRegion = 'GQ';

  // Configuración de monitoreo
  static const bool enablePerformanceMonitoring = true;
  static const bool enableErrorTracking = true;
  static const bool enableUsageAnalytics = true;

  // Configuración de actualizaciones
  static const bool enableAutoUpdates = true;
  static const bool enableBetaUpdates = false;
  static const String updateChannel = 'stable';

  // Configuración de certificados
  static const bool enableSSLCertificates = true;
  static const bool enableCodeSigning = true;
  static const String certificateAuthority = 'DigiCert';

  // Configuración de cumplimiento legal
  static const bool enableLegalCompliance = true;
  static const List<String> complianceStandards = [
    'ISO 27001',
    'GDPR',
    'Local Data Protection Laws',
    'Government Security Standards'
  ];

  // Configuración de auditoría
  static const bool enableSecurityAudit = true;
  static const bool enablePenetrationTesting = true;
  static const int auditFrequencyMonths = 6;

  // Configuración de disaster recovery
  static const bool enableDisasterRecovery = true;
  static const int recoveryTimeObjective = 4; // horas
  static const int recoveryPointObjective = 1; // hora

  // Configuración de escalabilidad
  static const bool enableHorizontalScaling = true;
  static const bool enableLoadBalancing = true;
  static const int maxConcurrentUsers = 1000;

  // Configuración de mantenimiento
  static const bool enableScheduledMaintenance = true;
  static const String maintenanceWindow = '02:00-04:00';
  static const String maintenanceTimezone = 'Africa/Malabo';

  // Configuración de documentación
  static const bool enableUserDocumentation = true;
  static const bool enableAdminDocumentation = true;
  static const bool enableAPIDocumentation = true;

  // Configuración de capacitación
  static const bool enableUserTraining = true;
  static const bool enableAdminTraining = true;
  static const String trainingPortal = 'https://training.penitsystem.ge';

  // Configuración de soporte técnico
  static const bool enable24x7Support = true;
  static const bool enableOnSiteSupport = true;
  static const int responseTimeHours = 2;

  // Configuración de garantía
  static const int warrantyPeriodMonths = 12;
  static const bool enableExtendedWarranty = true;
  static const int extendedWarrantyMonths = 24;
}
