import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();
  int _selectedIconId = 0;
  bool _isLoading = false;
  String? _error;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final auth = Provider.of<AuthService>(context, listen: false);
      await auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        displayName: _displayNameController.text.trim(),
        iconId: _selectedIconId,
      );
      if (mounted) Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('新規登録')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'メールアドレス'),
                validator: (value) => value == null || value.isEmpty ? '入力必須' : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'パスワード'),
                obscureText: true,
                validator: (value) => value != null && value.length < 6 ? '6文字以上必須' : null,
              ),
              TextFormField(
                controller: _displayNameController,
                decoration: const InputDecoration(labelText: '表示名'),
                validator: (value) => value == null || value.isEmpty ? '入力必須' : null,
              ),
              const SizedBox(height: 16),
              const Text('アイコン選択', style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButton<int>(
                value: _selectedIconId,
                isExpanded: true,
                items: List.generate(10, (i) => DropdownMenuItem(
                  value: i,
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: AssetImage('assets/icons/icon_$i.png'),
                        radius: 16,
                      ),
                      const SizedBox(width: 8),
                      Text('アイコン $i'),
                    ],
                  ),
                )),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedIconId = val);
                },
              ),
              const SizedBox(height: 24),
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ElevatedButton(
                onPressed: _isLoading ? null : _register,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('登録'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
