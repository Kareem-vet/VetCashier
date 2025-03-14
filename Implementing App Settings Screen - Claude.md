Now let's continue with implementing the settings screen, which will allow users to customize app settings like language preference, currency symbol, and theme.

Create a new folder at `lib/screens/settings` and then create a new file at `lib/screens/settings/settings_screen.dart`:

```
<div><p>dart</p><div><p><code id="code-lang-dart">import 'package:flutter/material.dart';
import '../../services/settings_service.dart';
import '../../services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() =&gt; _SettingsScreenState();
}

class _SettingsScreenState extends State&lt;SettingsScreen&gt; {
  late SettingsService _settingsService;
  late AuthService _authService;
  bool _isLoading = true;
  
  // Settings values
  String _locale = 'en';
  ThemeMode _themeMode = ThemeMode.light;
  String _currencySymbol = '\$';
  double _taxRate = 0.0;
  int _lowStockThreshold = 5;
  String _invoicePrefix = 'INV';
  bool _autoBackup = false;

  @override
  void initState() {
    super.initState();
    _initSettings();
  }
  
  Future&lt;void&gt; _initSettings() async {
    try {
      _settingsService = await SettingsService.getInstance();
      _authService = AuthService();
      
      setState(() {
        _locale = _settingsService.getLocale();
        _themeMode = _settingsService.getThemeMode();
        _currencySymbol = _settingsService.getCurrencySymbol();
        _taxRate = _settingsService.getTaxRate();
        _lowStockThreshold = _settingsService.getLowStockThreshold();
        _invoicePrefix = _settingsService.getInvoicePrefix();
        _autoBackup = _settingsService.getAutoBackup();
        _isLoading = false;
      });
    } catch (e) {
      print('Error initializing settings: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Account settings
                const Text(
                  'Account',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      ListTile(
                        title: const Text('Profile'),
                        subtitle: Text(_authService.userModel?.username ?? ''),
                        leading: const Icon(Icons.person),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.pushNamed(context, '/profile');
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        title: const Text('Change Password'),
                        leading: const Icon(Icons.lock),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          // Navigate to change password screen
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        title: const Text('Log out'),
                        leading: const Icon(Icons.exit_to_app, color: Colors.red),
                        onTap: () async {
                          await _authService.signOut();
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // App settings
                const Text(
                  'App Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      ListTile(
                        title: const Text('Language'),
                        subtitle: Text(_getLanguageName(_locale)),
                        leading: const Icon(Icons.language),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          _showLanguageSelector();
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        title: const Text('Theme'),
                        subtitle: Text(_getThemeName(_themeMode)),
                        leading: const Icon(Icons.brightness_6),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          _showThemeSelector();
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Business settings
                const Text(
                  'Business Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      ListTile(
                        title: const Text('Currency Symbol'),
                        subtitle: Text(_currencySymbol),
                        leading: const Icon(Icons.attach_money),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          _showCurrencySymbolSelector();
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        title: const Text('Tax Rate'),
                        subtitle: Text('${(_taxRate * 100).toStringAsFixed(1)}%'),
                        leading: const Icon(Icons.percent),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          _showTaxRateDialog();
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        title: const Text('Invoice Prefix'),
                        subtitle: Text(_invoicePrefix),
                        leading: const Icon(Icons.receipt),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          _showInvoicePrefixDialog();
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        title: const Text('Low Stock Threshold'),
                        subtitle: Text('$_lowStockThreshold items'),
                        leading: const Icon(Icons.warning),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          _showLowStockThresholdDialog();
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Data settings
                const Text(
                  'Data',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Auto Backup'),
                        subtitle: const Text('Automatically backup data daily'),
                        value: _autoBackup,
                        onChanged: (value) async {
                          await _settingsService.setAutoBackup(value);
                          setState(() {
                            _autoBackup = value;
                          });
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        title: const Text('Backup Now'),
                        leading: const Icon(Icons.backup),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Backup started...'),
                            ),
                          );
                          // TODO: Implement backup functionality
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        title: const Text('Reset All Settings'),
                        subtitle: const Text('Restore default settings'),
                        leading: const Icon(Icons.settings_backup_restore),
                        onTap: () {
                          _showResetSettingsDialog();
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // About
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      ListTile(
                        title: const Text('About'),
                        subtitle: const Text('Version 1.0.0'),
                        leading: const Icon(Icons.info),
                        onTap: () {
                          // Show about dialog
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
  
  // Helper methods for displaying names
  String _getLanguageName(String locale) {
    switch (locale) {
      case 'en':
        return 'English';
      case 'ar':
        return 'Arabic (العربية)';
      default:
        return 'English';
    }
  }
  
  String _getThemeName(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System Default';
      default:
        return 'Light';
    }
  }
  
  // Dialog methods
  void _showLanguageSelector() {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Select Language'),
          children: [
            _buildLanguageOption('en', 'English'),
            _buildLanguageOption('ar', 'Arabic (العربية)'),
          ],
        );
      },
    );
  }
  
  Widget _buildLanguageOption(String locale, String name) {
    return RadioListTile&lt;String&gt;(
      title: Text(name),
      value: locale,
      groupValue: _locale,
      onChanged: (value) async {
        if (value != null) {
          await _settingsService.setLocale(value);
          setState(() {
            _locale = value;
          });
          Navigator.pop(context);
          
          // Show restart app message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please restart the app for language changes to take effect'),
            ),
          );
        }
      },
    );
  }
  
  void _showThemeSelector() {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Select Theme'),
          children: [
            RadioListTile&lt;ThemeMode&gt;(
              title: const Text('Light'),
              value: ThemeMode.light,
              groupValue: _themeMode,
              onChanged: (ThemeMode? value) async {
                if (value != null) {
                  await _settingsService.setThemeMode(value);
                  setState(() {
                    _themeMode = value;
                  });
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile&lt;ThemeMode&gt;(
              title: const Text('Dark'),
              value: ThemeMode.dark,
              groupValue: _themeMode,
              onChanged: (ThemeMode? value) async {
                if (value != null) {
                  await _settingsService.setThemeMode(value);
                  setState(() {
                    _themeMode = value;
                  });
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile&lt;ThemeMode&gt;(
              title: const Text('System Default'),
              value: ThemeMode.system,
              groupValue: _themeMode,
              onChanged: (ThemeMode? value) async {
                if (value != null) {
                  await _settingsService.setThemeMode(value);
                  setState(() {
                    _themeMode = value;
                  });
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }
  
  void _showCurrencySymbolSelector() {
    final TextEditingController controller = TextEditingController(text: _currencySymbol);
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Currency Symbol'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Symbol',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                String value = controller.text.trim();
                if (value.isNotEmpty) {
                  await _settingsService.setCurrencySymbol(value);
                  setState(() {
                    _currencySymbol = value;
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
  
  void _showTaxRateDialog() {
    final TextEditingController controller = TextEditingController(
      text: (_taxRate * 100).toStringAsFixed(1),
    );
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tax Rate'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Tax Rate (%)',
              border: OutlineInputBorder(),
              suffixText: '%',
            ),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                double? value = double.tryParse(controller.text);
                if (value != null) {
                  double rate = value / 100; // Convert from percentage to decimal
                  await _settingsService.setTaxRate(rate);
                  setState(() {
                    _taxRate = rate;
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
  
  void _showInvoicePrefixDialog() {
    final TextEditingController controller = TextEditingController(text: _invoicePrefix);
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Invoice Prefix'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Prefix',
              border: OutlineInputBorder(),
              helperText: 'Example: INV, VC, etc.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                String value = controller.text.trim();
                if (value.isNotEmpty) {
                  await _settingsService.setInvoicePrefix(value);
                  setState(() {
                    _invoicePrefix = value;
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
  
  void _showLowStockThresholdDialog() {
    final TextEditingController controller = TextEditingController(
      text: _lowStockThreshold.toString(),
    );
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Low Stock Threshold'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Threshold',
              border: OutlineInputBorder(),
              helperText: 'Get alerts when stock falls below this level',
            ),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                int? value = int.tryParse(controller.text);
                if (value != null &amp;&amp; value &gt; 0) {
                  await _settingsService.setLowStockThreshold(value);
                  setState(() {
                    _lowStockThreshold = value;
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
  
  void _showResetSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset Settings'),
          content: const Text('Are you sure you want to reset all settings to default? This cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await _settingsService.resetSettings();
                await _initSettings(); // Reload settings
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Settings reset to default'),
                  ),
                );
              },
              child: const Text('Reset'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
          ],
        );
      },
    );
  }
}</code></p></div></div>
```

Now, let's create a simple profile screen that will allow users to update their personal information.

Create a new file at `lib/screens/settings/profile_screen.dart`:

```
<div><p>dart</p><div><p><code id="code-lang-dart">import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() =&gt; _ProfileScreenState();
}

class _ProfileScreenState extends State&lt;ProfileScreen&gt; {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey&lt;FormState&gt;();
  
  // Controllers for the text fields
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
  
  void _loadUserData() {
    final user = _authService.userModel;
    if (user != null) {
      _usernameController.text = user.username;
      _phoneController.text = user.phoneNumber ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Profile picture (placeholder)
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[200],
                    child: const Icon(
                      Icons.person,
                      size: 80,
                      color: Colors.grey,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Email (non-editable)
            TextFormField(
              initialValue: _authService.user?.email ?? '',
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              readOnly: true,
              enabled: false,
            ),
            const SizedBox(height: 16),
            
            // Username
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a username';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Phone number
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 32),
            
            // Save button
            ElevatedButton(
              onPressed: _isLoading ? null : _saveProfile,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation&lt;Color&gt;(Colors.white),
                      ),
                    )
                  : const Text('Save Profile'),
            ),
          ],
        ),
      ),
    );
  }
  
  Future&lt;void&gt; _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      String? result = await _authService.updateProfile(
        _usernameController.text.trim(),
        _phoneController.text.isNotEmpty ? _phoneController.text.trim() : null,
      );
      
      if (result != null) {
        // Error occurred
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $result')),
        );
      } else {
        // Success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}</code></p></div></div>
```

Now, let's update the `main.dart` file to include the settings and profile screens:

```
<div><p>dart</p><div><p><code id="code-lang-dart">// Add these imports at the top of your main.dart file
import 'screens/settings/settings_screen.dart';
import 'screens/settings/profile_screen.dart';

// Then update the routes section to include settings and profile
routes: {
  '/login': (context) =&gt; const LoginScreen(),
  '/register': (context) =&gt; const RegisterScreen(),
  '/admin-dashboard': (context) =&gt; const AdminDashboard(),
  '/user-dashboard': (context) =&gt; const UserDashboard(),
  '/inventory': (context) {
    // Get store ID from current user
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return FutureBuilder&lt;DocumentSnapshot&gt;(
        future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          if (snapshot.hasData &amp;&amp; snapshot.data!.exists) {
            final userData = snapshot.data!.data() as Map&lt;String, dynamic&gt;;
            final storeId = userData['storeId'] ?? '';
            
            if (storeId.isEmpty) {
              return const Scaffold(
                body: Center(child: Text('No store assigned to this user')),
              );
            }
            
            return InventoryScreen(storeId: storeId);
          }
          
          return const Scaffold(
            body: Center(child: Text('Unable to load user data')),
          );
        },
      );
    }
    
    return const LoginScreen();
  },
  '/voice-sales': (context) {
    // Get store ID from current user
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return FutureBuilder&lt;DocumentSnapshot&gt;(
        future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          if (snapshot.hasData &amp;&amp; snapshot.data!.exists) {
            final userData = snapshot.data!.data() as Map&lt;String, dynamic&gt;;
            final storeId = userData['storeId'] ?? '';
            
            if (storeId.isEmpty) {
              return const Scaffold(
                body: Center(child: Text('No store assigned to this user')),
              );
            }
            
            return VoiceSalesScreen(storeId: storeId);
          }
          
          return const Scaffold(
            body: Center(child: Text('Unable to load user data')),
          );
        },
      );
    }
    
    return const LoginScreen();
  },
  '/reports': (context) {
    // Get store ID from current user
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return FutureBuilder&lt;DocumentSnapshot&gt;(
        future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          if (snapshot.hasData &amp;&amp; snapshot.data!.exists) {
            final userData = snapshot.data!.data() as Map&lt;String, dynamic&gt;;
            final storeId = userData['storeId'] ?? '';
            
            if (storeId.isEmpty) {
              return const Scaffold(
                body: Center(child: Text('No store assigned to this user')),
              );
            }
            
            return ReportsScreen(storeId: storeId);
          }
          
          return const Scaffold(
            body: Center(child: Text('Unable to load user data')),
          );
        },
      );
    }
    
    return const LoginScreen();
  },
  '/settings': (context) =&gt; const SettingsScreen(),
  '/profile': (context) =&gt; const ProfileScreen(),
  // Add more routes as we create screens
  // '/user-management': (context) =&gt; const UserManagementScreen(),
},</code></p></div></div>
```

With these additions, we've created:

1.  A comprehensive settings screen that allows users to customize their experience
2.  A profile screen for updating personal information
3.  Routes to navigate to these screens

Next, we could continue by implementing the user management screen, which would allow store owners and admins to manage users. Would you like to proceed with that?