import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SettingsScreen extends StatefulWidget {
  final String initialApiUrl;
  final String initialApiKey;
  final Function(String apiUrl, String apiKey) onSaved;

  const SettingsScreen({
    super.key,
    required this.initialApiUrl,
    required this.initialApiKey,
    required this.onSaved,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _urlController;
  late TextEditingController _keyController;
  bool _isTestingConnection = false;
  String? _testConnectionResult;
  bool _testSuccess = false;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: widget.initialApiUrl);
    _keyController = TextEditingController(text: widget.initialApiKey);
  }

  @override
  void dispose() {
    _urlController.dispose();
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      setState(() {
        _testConnectionResult = 'Please enter a URL first.';
        _testSuccess = false;
      });
      return;
    }

    setState(() {
      _isTestingConnection = true;
      _testConnectionResult = null;
    });

    try {
      // Send a dummy POST request to see if the URL is reachable
      // We send it to check connection, catching timeouts and response codes
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (_keyController.text.isNotEmpty) 'Authorization': 'Bearer ${_keyController.text.trim()}',
        },
        body: '{}',
      ).timeout(const Duration(seconds: 8));

      // Any HTTP response (even 404 or 400) means the server is reachable and active.
      // (a POST with empty JSON '{}' will likely return 400 or 422 if it expects fields,
      // which is normal and means the connection was made).
      setState(() {
        _testSuccess = true;
        _testConnectionResult = 'Connected successfully!\nServer returned HTTP ${response.statusCode}';
      });
    } catch (e) {
      setState(() {
        _testSuccess = false;
        _testConnectionResult = 'Connection failed:\n$e';
      });
    } finally {
      setState(() {
        _isTestingConnection = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const brandGreen = Color(0xFF006A4E);
    const deepGreen = Color(0xFF002C1B);
    const brandGold = Color(0xFFB59049);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Demo Settings',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: deepGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Branding Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: brandGreen.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: brandGreen.withOpacity(0.15)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.cloud_queue_rounded, color: brandGreen, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Cloud Run Integration',
                          style: TextStyle(
                            color: deepGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Configure the agent service URL deployed on Google Cloud Run to interface with live models.',
                          style: TextStyle(
                            color: Colors.grey[650],
                            fontSize: 11,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Cloud Run API Endpoint URL
            const Text(
              'CLOUD RUN SERVICE ENDPOINT URL',
              style: TextStyle(
                color: deepGreen,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _urlController,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                hintText: 'https://lloyds-agent-xxxx-xx.a.run.app/api/chat',
                prefixIcon: const Icon(Icons.link_rounded, color: brandGreen),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: brandGreen, width: 2),
                ),
              ),
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),

            // API Key / Auth Token
            const Text(
              'AUTHORIZATION API KEY / BEARER TOKEN (OPTIONAL)',
              style: TextStyle(
                color: deepGreen,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _keyController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Enter API token if service requires authentication',
                prefixIcon: const Icon(Icons.vpn_key_rounded, color: brandGold),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: brandGreen, width: 2),
                ),
              ),
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),

            // Connection Tester
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _isTestingConnection ? null : _testConnection,
                  icon: _isTestingConnection
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: brandGreen),
                        )
                      : const Icon(Icons.wifi_tethering_rounded, size: 16),
                  label: const Text('Test Connection'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: brandGreen,
                    side: const BorderSide(color: brandGreen),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            
            if (_testConnectionResult != null) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _testSuccess ? Colors.green[50] : Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _testSuccess ? Colors.green[300]! : Colors.red[300]!,
                    width: 0.8,
                  ),
                ),
                child: Text(
                  _testConnectionResult!,
                  style: TextStyle(
                    color: _testSuccess ? Colors.green[800] : Colors.red[900],
                    fontSize: 12,
                    fontFamily: 'Courier',
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Save Buttons
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  widget.onSaved(
                    _urlController.text.trim(),
                    _keyController.text.trim(),
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Settings updated successfully!'),
                      backgroundColor: brandGreen,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Save Settings',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
