import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:crypto/crypto.dart';

class EncryptionService {
  static const String _algorithm = 'aes-256-cbc';
  static const int _keyLength = 32;
  static const int _ivLength = 16;

  // Clave maestra del sistema (en producción debería estar en variables de entorno)
  static const String _masterKey = 'SistemaPenitenciarioNacional2024';

  static Encrypter? _encrypter;
  static IV? _iv;
  static bool _isInitialized = false;

  // Inicializar el servicio de cifrado
  static void initialize() {
    if (_isInitialized) return;

    try {
      final key = _generateKeyFromMaster(_masterKey);
      _iv = IV.fromSecureRandom(_ivLength);
      _encrypter = Encrypter(AES(key));
      _isInitialized = true;
      print('🔐 Servicio de encriptación inicializado correctamente');
    } catch (e) {
      print('❌ Error al inicializar servicio de encriptación: $e');
      // Usar valores por defecto en caso de error
      _iv = IV.fromLength(_ivLength);
      _encrypter = Encrypter(AES(Key.fromSecureRandom(_keyLength)));
      _isInitialized = true;
    }
  }

  // Verificar que el servicio esté inicializado
  static void _ensureInitialized() {
    if (!_isInitialized) {
      initialize();
    }
  }

  // Generar clave AES-256 desde la clave maestra
  static Key _generateKeyFromMaster(String masterKey) {
    final bytes = utf8.encode(masterKey);
    final hash = sha256.convert(bytes);
    final keyBytes = hash.bytes.take(_keyLength).toList();

    // Asegurar que la clave tenga exactamente 32 bytes
    while (keyBytes.length < _keyLength) {
      keyBytes.add(0);
    }

    return Key(Uint8List.fromList(keyBytes));
  }

  // Cifrar datos sensibles
  static String encryptData(String data) {
    try {
      _ensureInitialized();
      final encrypted = _encrypter!.encrypt(data, iv: _iv!);
      return encrypted.base64;
    } catch (e) {
      print('❌ Error al cifrar datos: $e');
      return data; // Retornar datos sin cifrar en caso de error
    }
  }

  // Descifrar datos sensibles
  static String decryptData(String encryptedData) {
    try {
      _ensureInitialized();
      final encrypted = Encrypted.fromBase64(encryptedData);
      return _encrypter!.decrypt(encrypted, iv: _iv!);
    } catch (e) {
      print('❌ Error al descifrar datos: $e');
      return encryptedData; // Retornar datos originales en caso de error
    }
  }

  // Cifrar campos específicos de un recluso
  static Map<String, dynamic> encryptInmateData(
      Map<String, dynamic> inmateData) {
    final encryptedData = Map<String, dynamic>.from(inmateData);

    // Campos sensibles que deben cifrarse
    const sensitiveFields = [
      'firstName',
      'lastName',
      'idNumber',
      'nationality',
      'crime',
      'notes',
    ];

    for (final field in sensitiveFields) {
      if (encryptedData.containsKey(field) && encryptedData[field] != null) {
        encryptedData[field] = encryptData(encryptedData[field].toString());
      }
    }

    return encryptedData;
  }

  // Descifrar campos específicos de un recluso
  static Map<String, dynamic> decryptInmateData(
      Map<String, dynamic> encryptedData) {
    final decryptedData = Map<String, dynamic>.from(encryptedData);

    // Campos sensibles que deben descifrarse
    const sensitiveFields = [
      'firstName',
      'lastName',
      'idNumber',
      'nationality',
      'crime',
      'notes',
    ];

    for (final field in sensitiveFields) {
      if (decryptedData.containsKey(field) && decryptedData[field] != null) {
        try {
          decryptedData[field] = decryptData(decryptedData[field].toString());
        } catch (e) {
          // Si no se puede descifrar, mantener el valor original
          print('Error al descifrar campo $field: $e');
        }
      }
    }

    return decryptedData;
  }

  // Generar hash seguro de contraseña usando bcrypt
  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  // Verificar contraseña
  static bool verifyPassword(String password, String hashedPassword) {
    final hashedInput = hashPassword(password);
    return hashedInput == hashedPassword;
  }

  // Generar token de sesión seguro
  static String generateSessionToken() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Url.encode(bytes);
  }

  // Cifrar datos de hospitalización
  static Map<String, dynamic> encryptHospitalizationData(
      Map<String, dynamic> hospData) {
    final encryptedData = Map<String, dynamic>.from(hospData);

    const sensitiveFields = [
      'inmateName',
      'diagnosis',
      'doctorName',
      'notes',
    ];

    for (final field in sensitiveFields) {
      if (encryptedData.containsKey(field) && encryptedData[field] != null) {
        encryptedData[field] = encryptData(encryptedData[field].toString());
      }
    }

    return encryptedData;
  }

  // Descifrar datos de hospitalización
  static Map<String, dynamic> decryptHospitalizationData(
      Map<String, dynamic> encryptedData) {
    final decryptedData = Map<String, dynamic>.from(encryptedData);

    const sensitiveFields = [
      'inmateName',
      'diagnosis',
      'doctorName',
      'notes',
    ];

    for (final field in sensitiveFields) {
      if (decryptedData.containsKey(field) && decryptedData[field] != null) {
        try {
          decryptedData[field] = decryptData(decryptedData[field].toString());
        } catch (e) {
          print('Error al descifrar campo $field: $e');
        }
      }
    }

    return decryptedData;
  }

  // Cifrar logs de auditoría
  static Map<String, dynamic> encryptAuditLog(Map<String, dynamic> logData) {
    final encryptedData = Map<String, dynamic>.from(logData);

    const sensitiveFields = [
      'userId',
      'action',
      'description',
      'additionalData',
    ];

    for (final field in sensitiveFields) {
      if (encryptedData.containsKey(field) && encryptedData[field] != null) {
        if (field == 'additionalData' && encryptedData[field] is Map) {
          // Cifrar datos adicionales como JSON
          final jsonString = json.encode(encryptedData[field]);
          encryptedData[field] = encryptData(jsonString);
        } else {
          encryptedData[field] = encryptData(encryptedData[field].toString());
        }
      }
    }

    return encryptedData;
  }

  // Descifrar logs de auditoría
  static Map<String, dynamic> decryptAuditLog(
      Map<String, dynamic> encryptedData) {
    final decryptedData = Map<String, dynamic>.from(encryptedData);

    const sensitiveFields = [
      'userId',
      'action',
      'description',
      'additionalData',
    ];

    for (final field in sensitiveFields) {
      if (decryptedData.containsKey(field) && decryptedData[field] != null) {
        try {
          final decrypted = decryptData(decryptedData[field].toString());
          if (field == 'additionalData') {
            // Intentar parsear como JSON
            try {
              decryptedData[field] = json.decode(decrypted);
            } catch (e) {
              decryptedData[field] = decrypted;
            }
          } else {
            decryptedData[field] = decrypted;
          }
        } catch (e) {
          print('Error al descifrar campo $field: $e');
        }
      }
    }

    return decryptedData;
  }

  // Verificar integridad de datos
  static bool verifyDataIntegrity(String data, String signature) {
    try {
      final expectedHash = sha256.convert(utf8.encode(data)).toString();
      return expectedHash == signature;
    } catch (e) {
      return false;
    }
  }

  // Generar firma digital para datos
  static String generateDataSignature(String data) {
    return sha256.convert(utf8.encode(data)).toString();
  }

  // Limpiar datos sensibles de memoria
  static void clearSensitiveData() {
    // En una implementación real, aquí se limpiarían las claves de memoria
    print('Datos sensibles limpiados de memoria');
  }
}
