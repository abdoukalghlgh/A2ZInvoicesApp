import 'package:flutter/material.dart';
import 'main_menu_screen.dart';

/// بيانات الدخول (مطابقة لنسخة سطح المكتب). يمكن تغييرها لاحقًا بسهولة هنا.
const String _validUsername = 'admin';
const String _validPassword = 'tam12123';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _showError = false;
  bool _obscure = true;

  void _tryLogin() {
    if (_userCtrl.text.trim() == _validUsername && _passCtrl.text == _validPassword) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainMenuScreen()),
      );
    } else {
      setState(() => _showError = true);
      _passCtrl.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF193A5F);
    return Scaffold(
      backgroundColor: navy,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: const BoxDecoration(shape: BoxShape.circle, border: Border.fromBorderSide(BorderSide(color: navy, width: 2.5))),
                        alignment: Alignment.center,
                        child: const Text('ن', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: navy)),
                      ),
                      const SizedBox(height: 12),
                      const Text('برنامج مبيعات النور', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: navy)),
                      const SizedBox(height: 4),
                      const Text('تحرير الفواتير وإدارة الزبائن والمخزون', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _userCtrl,
                        textAlign: TextAlign.right,
                        decoration: const InputDecoration(labelText: 'اسم المستخدم', prefixIcon: Icon(Icons.person_outline)),
                        onSubmitted: (_) => _tryLogin(),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _passCtrl,
                        textAlign: TextAlign.right,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          labelText: 'كلمة المرور',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                        ),
                        onSubmitted: (_) => _tryLogin(),
                      ),
                      if (_showError) ...[
                        const SizedBox(height: 10),
                        const Text('اسم المستخدم أو كلمة المرور غير صحيحة.', style: TextStyle(color: Colors.red, fontSize: 12)),
                      ],
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: navy, foregroundColor: Colors.white),
                          onPressed: _tryLogin,
                          child: const Text('دخول', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
