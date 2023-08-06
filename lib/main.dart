import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _loginStatus = '';
  String _errorMessage = '';

  Future<void> _login() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor, complete todos los campos.';
      });
      return;
    } else {
      setState(() {
        _errorMessage = '';
      });
    }

    // Verificar la conexión a internet usando connectivity_plus
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      _showNoInternetDialog();
      return;
    }

    final String apiUrl = 'http://192.168.1.19:8000/auth/login/';
    final Map<String, String> data = {
      'username': _usernameController.text,
      'password': _passwordController.text,
      'client_id': 'nE2hSHy0z4h5aifZJdJFwxUjrVGgbffKYboNaF7C',
      'client_secret': 'pbkdf2_sha256\$600000\$Xdgs6cjpfrSn55pNF2WMWE\$l7mDp8I6l1TnbtCCMONaDeEHoanfb4MYQzRTKS8kqxo=',
    };

    final http.Response response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData.containsKey('access_token')) {
        setState(() {
          _loginStatus = 'Login Exitoso';
        });
      } else {
        setState(() {
          _loginStatus = 'Error de Login';
        });
      }
    } else {
      setState(() {
        _loginStatus = 'Error de Login';
      });
    }
  }

  // Método para mostrar el diálogo de falta de conexión
  void _showNoInternetDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Sin conexión'),
          content: Text('No se detecta una conexión a internet.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login App'),
      ),
      body: Center(
        child: Container(
          width: 300,
          child: Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(labelText: 'Username'),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                SizedBox(height: 10),
                Text(
                  _errorMessage,
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _login,
                  child: Text('Login'),
                ),
                SizedBox(height: 20),
                Text(
                  _loginStatus,
                  style: TextStyle(
                    color: _loginStatus == 'Login Exitoso' ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
