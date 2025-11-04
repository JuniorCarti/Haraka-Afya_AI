import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  // Check if device supports biometric authentication
  Future<bool> isDeviceSupported() async {
    try {
      final bool isSupported = await _localAuth.isDeviceSupported();
      print('Device biometric support: $isSupported');
      return isSupported;
    } catch (e) {
      print('Error checking device support: $e');
      return false;
    }
  }

  // Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      final List<BiometricType> availableBiometrics = 
          await _localAuth.getAvailableBiometrics();
      print('Available biometric types: $availableBiometrics');
      return availableBiometrics;
    } catch (e) {
      print('Error getting available biometrics: $e');
      return [];
    }
  }

  // Check if biometrics are enrolled and available
  Future<bool> hasEnrolledBiometrics() async {
    try {
      final bool isSupported = await isDeviceSupported();
      if (!isSupported) {
        print('Device does not support biometrics');
        return false;
      }

      final List<BiometricType> availableBiometrics = 
          await getAvailableBiometrics();
      
      // Check if any biometric methods are actually enrolled
      final bool hasEnrolled = availableBiometrics.isNotEmpty;
      
      print('Has enrolled biometrics: $hasEnrolled');
      print('Available biometric methods: $availableBiometrics');
      
      return hasEnrolled;
    } catch (e) {
      print('Error checking enrolled biometrics: $e');
      return false;
    }
  }

  // Check overall biometric availability
  Future<bool> isBiometricAvailable() async {
    try {
      final bool isSupported = await isDeviceSupported();
      if (!isSupported) return false;

      final bool hasEnrolled = await hasEnrolledBiometrics();
      return hasEnrolled;
    } catch (e) {
      print('Error checking biometric availability: $e');
      return false;
    }
  }

  // Authenticate user with biometrics (IMPROVED)
  Future<bool> authenticate() async {
    try {
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Authenticate to secure your health data',
        options: const AuthenticationOptions(
          biometricOnly: false, // Changed to false to allow device credentials
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );

      print('Authentication result: $didAuthenticate');
      return didAuthenticate;
    } catch (e) {
      print('Authentication error: $e');
      return false;
    }
  }

  // Get biometric type name for display (IMPROVED)
  String getBiometricTypeName(List<BiometricType> types) {
    if (types.isEmpty) {
      return 'Biometric';
    }
    
    if (types.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (types.contains(BiometricType.fingerprint)) {
      return 'Fingerprint';
    } else if (types.contains(BiometricType.iris)) {
      return 'Iris Scanner';
    } else if (types.contains(BiometricType.strong)) {
      return 'Strong Biometric';
    } else if (types.contains(BiometricType.weak)) {
      return 'Weak Biometric';
    } else {
      return 'Biometric';
    }
  }

  // Get detailed biometric info for debugging
  Future<Map<String, dynamic>> getBiometricInfo() async {
    try {
      final bool isSupported = await isDeviceSupported();
      final List<BiometricType> availableBiometrics = 
          await getAvailableBiometrics();
      final bool hasEnrolled = await hasEnrolledBiometrics();
      
      return {
        'isSupported': isSupported,
        'availableBiometrics': availableBiometrics,
        'hasEnrolledBiometrics': hasEnrolled,
        'biometricTypeName': getBiometricTypeName(availableBiometrics),
      };
    } catch (e) {
      print('Error getting biometric info: $e');
      return {
        'isSupported': false,
        'availableBiometrics': [],
        'hasEnrolledBiometrics': false,
        'biometricTypeName': 'Biometric',
        'error': e.toString(),
      };
    }
  }
}