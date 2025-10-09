import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:haraka_afya_ai/widgets/LegalDocumentsScreen.dart';
import 'package:haraka_afya_ai/widgets/legal_documents.dart';
import 'package:haraka_afya_ai/features/profile_page.dart';
import 'package:haraka_afya_ai/services/biometric_service.dart';
import 'package:haraka_afya_ai/services/auto_lock_service.dart';
import 'package:haraka_afya_ai/services/data_sharing_service.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  final BiometricService _biometricService = BiometricService();
  final AutoLockService _autoLockService = AutoLockService();
  final DataSharingService _dataSharingService = DataSharingService();
  
  // Biometric variables
  bool _isBiometricEnabled = false;
  bool _isBiometricAvailable = false;
  String _biometricType = 'Biometric';
  bool _isBiometricLoading = true;
  
  // Auto-lock variables
  bool _isAutoLockEnabled = false;
  int _autoLockTimeout = 5;
  bool _isAutoLockLoading = true;
  
  // Data sharing variables
  bool _isDataSharingEnabled = false;
  bool _isAnonymizationEnabled = true;
  Set<String> _selectedDataTypes = {};
  bool _isDataSharingLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeSettings();
  }

  Future<void> _initializeSettings() async {
    await _checkBiometricAvailability();
    await _loadBiometricSetting();
    await _loadAutoLockSettings();
    await _loadDataSharingSettings();
  }

  // Biometric Methods
  Future<void> _checkBiometricAvailability() async {
    try {
      final isAvailable = await _biometricService.isDeviceSupported();
      final hasEnrolled = await _biometricService.hasEnrolledBiometrics();
      final availableTypes = await _biometricService.getAvailableBiometrics();
      
      setState(() {
        _isBiometricAvailable = isAvailable && hasEnrolled;
        _biometricType = _biometricService.getBiometricTypeName(availableTypes);
        _isBiometricLoading = false;
      });
    } catch (e) {
      print('Error checking biometric availability: $e');
      setState(() {
        _isBiometricAvailable = false;
        _isBiometricLoading = false;
      });
    }
  }

  Future<void> _loadBiometricSetting() async {
    // In a real app, load from secure storage
    setState(() {
      _isBiometricEnabled = false;
    });
  }

  Future<void> _toggleBiometricAuth(bool value) async {
    if (value) {
      final bool didAuthenticate = await _biometricService.authenticate();
      
      if (didAuthenticate) {
        setState(() {
          _isBiometricEnabled = true;
        });
        _showSuccessSnackBar('$_biometricType authentication enabled');
      } else {
        _showErrorSnackBar('Authentication failed. $_biometricType not enabled.');
        setState(() {
          _isBiometricEnabled = false;
        });
      }
    } else {
      setState(() {
        _isBiometricEnabled = false;
      });
      _showSuccessSnackBar('$_biometricType authentication disabled');
    }
  }

  // Auto-lock Methods
  Future<void> _loadAutoLockSettings() async {
    try {
      final isEnabled = await _autoLockService.isAutoLockEnabled();
      final timeout = await _autoLockService.getAutoLockTimeout();
      
      setState(() {
        _isAutoLockEnabled = isEnabled;
        _autoLockTimeout = timeout;
        _isAutoLockLoading = false;
      });
    } catch (e) {
      print('Error loading auto-lock settings: $e');
      setState(() {
        _isAutoLockEnabled = false;
        _autoLockTimeout = 5;
        _isAutoLockLoading = false;
      });
    }
  }

  Future<void> _toggleAutoLock(bool value) async {
    try {
      await _autoLockService.setAutoLockEnabled(value);
      setState(() {
        _isAutoLockEnabled = value;
      });
      
      if (value) {
        _showSuccessSnackBar('Auto-lock enabled (${_autoLockService.getFormattedTimeout(_autoLockTimeout)})');
      } else {
        _showSuccessSnackBar('Auto-lock disabled');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to update auto-lock settings');
      print('Error toggling auto-lock: $e');
    }
  }

  void _showAutoLockTimeoutDialog() {
    final options = _autoLockService.getTimeoutOptions();
    final currentSelection = _autoLockService.getFormattedTimeout(_autoLockTimeout);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Auto-lock Timeout'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: options.length,
            itemBuilder: (context, index) {
              final option = options[index];
              return RadioListTile(
                title: Text(option),
                value: option,
                groupValue: currentSelection,
                onChanged: (value) {
                  _updateAutoLockTimeout(value as String);
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _updateAutoLockTimeout(String displayString) async {
    try {
      final timeout = _autoLockService.getTimeoutFromString(displayString);
      await _autoLockService.setAutoLockTimeout(timeout);
      
      setState(() {
        _autoLockTimeout = timeout;
      });
      
      _showSuccessSnackBar('Auto-lock timeout set to $displayString');
    } catch (e) {
      _showErrorSnackBar('Failed to update timeout');
      print('Error updating auto-lock timeout: $e');
    }
  }

  // Data Sharing Methods
  Future<void> _loadDataSharingSettings() async {
    try {
      final isEnabled = await _dataSharingService.isDataSharingEnabled();
      final isAnonymized = await _dataSharingService.isAnonymizationEnabled();
      final selectedTypes = await _dataSharingService.getSelectedDataTypes();
      
      setState(() {
        _isDataSharingEnabled = isEnabled;
        _isAnonymizationEnabled = isAnonymized;
        _selectedDataTypes = selectedTypes;
        _isDataSharingLoading = false;
      });
    } catch (e) {
      print('Error loading data sharing settings: $e');
      setState(() {
        _isDataSharingEnabled = false;
        _isAnonymizationEnabled = true;
        _selectedDataTypes = Set.from(_dataSharingService.getDataTypeKeys());
        _isDataSharingLoading = false;
      });
    }
  }

  Future<void> _toggleDataSharing(bool value) async {
    try {
      if (value) {
        // Show confirmation dialog when enabling data sharing
        final confirmed = await _showDataSharingConfirmationDialog();
        if (!confirmed) {
          return;
        }
      }

      await _dataSharingService.setDataSharingEnabled(value);
      setState(() {
        _isDataSharingEnabled = value;
      });
      
      if (value) {
        _showSuccessSnackBar('Data sharing enabled for research');
      } else {
        _showSuccessSnackBar('Data sharing disabled');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to update data sharing settings');
      print('Error toggling data sharing: $e');
    }
  }

  Future<bool> _showDataSharingConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enable Data Sharing?'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('By enabling data sharing, you agree to:'),
            SizedBox(height: 8),
            Text('• Share anonymized health data for medical research'),
            Text('• Contribute to improving healthcare outcomes'),
            Text('• Help train AI models to better serve patients'),
            SizedBox(height: 12),
            Text('Your data will be anonymized and used only for approved research purposes.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A249),
            ),
            child: const Text('Enable Sharing'),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showDataTypesDialog() {
    final dataTypeKeys = _dataSharingService.getDataTypeKeys();
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Select Data to Share'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Choose which data types you want to share for research:'),
                const SizedBox(height: 16),
                ...dataTypeKeys.map((key) => CheckboxListTile(
                  title: Text(_dataSharingService.getDataTypeName(key)),
                  value: _selectedDataTypes.contains(key),
                  onChanged: (value) {
                    setDialogState(() {
                      if (value == true) {
                        _selectedDataTypes.add(key);
                      } else {
                        _selectedDataTypes.remove(key);
                      }
                    });
                  },
                )).toList(),
                const SizedBox(height: 8),
                CheckboxListTile(
                  title: const Text('Anonymize all data'),
                  subtitle: const Text('Remove personal identifiers before sharing'),
                  value: _isAnonymizationEnabled,
                  onChanged: (value) {
                    setDialogState(() {
                      _isAnonymizationEnabled = value ?? true;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _saveDataSharingPreferences();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A249),
              ),
              child: const Text('Save Preferences'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveDataSharingPreferences() async {
    try {
      await _dataSharingService.setSelectedDataTypes(_selectedDataTypes);
      await _dataSharingService.setAnonymizationEnabled(_isAnonymizationEnabled);
      
      _showSuccessSnackBar('Data sharing preferences updated');
    } catch (e) {
      _showErrorSnackBar('Failed to save preferences');
      print('Error saving data sharing preferences: $e');
    }
  }

  String _getSelectedDataTypesSummary() {
    if (_selectedDataTypes.isEmpty) return 'No data selected';
    if (_selectedDataTypes.length == _dataSharingService.getDataTypeKeys().length) {
      return 'All data types';
    }
    return '${_selectedDataTypes.length} data type${_selectedDataTypes.length > 1 ? 's' : ''}';
  }

  // Utility Methods
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfilePage()),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F7F8),
        appBar: AppBar(
          backgroundColor: const Color(0xFFE6F6EC),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),
          title: Row(
            children: const [
              CircleAvatar(
                radius: 14,
                backgroundColor: Color(0xFFE7F6EB),
                child: Icon(Icons.shield, size: 18, color: Color(0xFF16A249)),
              ),
              SizedBox(width: 8),
              Text(
                'Privacy & Security',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSecurityStatusRow(),
              const SizedBox(height: 24),
              
              // Authentication Section
              const Text('Authentication', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildSwitchTile(
                Icons.phone_iphone, 
                'Two-Factor Authentication', 
                'Add extra security with SMS verification', 
                false,
                onChanged: (value) {},
              ),
              _buildBiometricTile(),
              _buildAutoLockTile(),
              
              const SizedBox(height: 24),
              
              // Privacy Controls Section
              const Text('Privacy Controls', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildDataSharingTile(),
              _buildSwitchTile(
                Icons.location_on, 
                'Location Tracking', 
                'Find nearby healthcare facilities', 
                false,
                onChanged: (value) {},
              ),
              _buildSwitchTile(
                Icons.notifications, 
                'Push Notifications', 
                'Medication reminders and health tips', 
                true,
                onChanged: (value) {},
              ),
              
              const SizedBox(height: 24),
              _buildSupportCard(context),
              const SizedBox(height: 24),
              
              // Legal Section
              const Text('Legal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildLegalTile('Privacy Policy', LegalDocuments.privacyPolicy),
              _buildLegalTile('Terms of Service', LegalDocuments.termsOfService),
              _buildLegalTile('Data Protection Notice', LegalDocuments.dataProtectionNotice),
              _buildLegalTile('Cookie Policy', LegalDocuments.cookiePolicy),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Biometric Tile
  Widget _buildBiometricTile() {
    if (_isBiometricLoading) {
      return _buildLoadingTile('Biometric Authentication', 'Checking availability...');
    }

    if (!_isBiometricAvailable) {
      return _buildUnavailableTile(
        '$_biometricType Authentication',
        '$_biometricType not available on this device',
      );
    }

    return _buildSwitchTile(
      Icons.fingerprint,
      '$_biometricType Authentication',
      'Use $_biometricType to secure your app',
      _isBiometricEnabled,
      onChanged: _toggleBiometricAuth,
    );
  }

  // Auto-lock Tile
  Widget _buildAutoLockTile() {
    if (_isAutoLockLoading) {
      return _buildLoadingTile('Auto-Lock', 'Loading settings...');
    }

    return Column(
      children: [
        _buildSwitchTile(
          Icons.lock_outline,
          'Auto-Lock',
          'Lock app when inactive',
          _isAutoLockEnabled,
          onChanged: _toggleAutoLock,
        ),
        if (_isAutoLockEnabled) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 32.0),
            child: Row(
              children: [
                const Icon(Icons.schedule, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Timeout: ${_autoLockService.getFormattedTimeout(_autoLockTimeout)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _showAutoLockTimeoutDialog,
                  child: const Text(
                    'Change',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // Data Sharing Tile
  Widget _buildDataSharingTile() {
    if (_isDataSharingLoading) {
      return _buildLoadingTile('Data Sharing', 'Loading settings...');
    }

    return Column(
      children: [
        _buildSwitchTile(
          Icons.visibility,
          'Data Sharing',
          'Share anonymized health data for research',
          _isDataSharingEnabled,
          onChanged: _toggleDataSharing,
        ),
        if (_isDataSharingEnabled) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.data_usage, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      'Sharing: ${_getSelectedDataTypesSummary()}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _showDataTypesDialog,
                      child: const Text(
                        'Customize',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.security, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      _isAnonymizationEnabled ? 'Data anonymized' : 'Data not anonymized',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // Reusable Widgets
  Widget _buildLoadingTile(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(Icons.settings, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      ),
    );
  }

  Widget _buildUnavailableTile(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(Icons.fingerprint, size: 20, color: Colors.grey[400]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[400])),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          CupertinoSwitch(
            value: false,
            onChanged: null,
            activeTrackColor: Colors.grey[400],
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    IconData icon,
    String title,
    String subtitle,
    bool enabled, {
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          CupertinoSwitch(
            value: enabled,
            onChanged: onChanged,
            activeTrackColor: const Color(0xFF16A249),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalTile(String title, String content) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _navigateToDocumentScreen(context, title, content),
    );
  }

  Widget _buildSecurityStatusRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE7F6EB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: const [
                Icon(Icons.shield, color: Color(0xFF16A249), size: 28),
                SizedBox(height: 6),
                Text('Protected', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF16A249)))
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE9F0FC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: const [
                Icon(Icons.lock, color: Color(0xFF3B82F6), size: 28),
                SizedBox(height: 6),
                Text('Encrypted', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3B82F6)))
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSupportCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F4EA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.email, color: Color(0xFF16A249)),
              SizedBox(width: 8),
              Text('Need Help?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Contact our support team for any privacy or security concerns.',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => _launchEmailSupport(context),
            icon: const Icon(Icons.mail),
            label: const Text('Email Support'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A249),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToDocumentScreen(BuildContext context, String title, String content) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LegalDocumentsScreen(
          documentType: title,
          content: content,
        ),
      ),
    );
  }

  void _launchEmailSupport(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening email support...')),
    );
  }
}