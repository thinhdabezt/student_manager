import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';
  String _role = 'student';

  void _register() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final auth = Provider.of<AuthProvider>(context, listen: false);
      await auth.register(_username, _password, role: _role);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đăng ký thành công!')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng ký tài khoản')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Tên đăng nhập'),
                validator: (v) => v == null || v.isEmpty ? 'Nhập tên đăng nhập' : null,
                onSaved: (v) => _username = v!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Mật khẩu'),
                obscureText: true,
                validator: (v) => v == null || v.length < 4 ? 'Ít nhất 4 ký tự' : null,
                onSaved: (v) => _password = v!,
              ),
              DropdownButtonFormField<String>(
                value: _role,
                items: const [
                  DropdownMenuItem(value: 'student', child: Text('Student')),
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                ],
                onChanged: (value) => setState(() => _role = value!),
                decoration: const InputDecoration(labelText: 'Vai trò'),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _register,
                icon: const Icon(Icons.app_registration),
                label: const Text('Đăng ký'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
