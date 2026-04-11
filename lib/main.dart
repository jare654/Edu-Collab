import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const RegistrationScreen(),
        '/confirm': (context) => const ConfirmationScreen(),
      },
    ));

// SCREEN 1: REGISTRATION 
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});
  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _idCtrl = TextEditingController();
  String? _selectedFaculty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(title: const Text('Student Registration')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Full Name'),
                      validator: (v) => v!.length < 3 ? 'Min 3 chars' : null),
                  TextFormField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email'),
                      validator: (v) => !v!.contains('@') ? 'Invalid Email' : null),
                  TextFormField(controller: _idCtrl, decoration: const InputDecoration(labelText: 'Student Number'),
                      validator: (v) => v!.length != 8 ? 'Must be 8 digits' : null),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Faculty'),
                    items: ['Engineering', 'Science', 'Commerce', 'Law'].map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                    onChanged: (val) => setState(() => _selectedFaculty = val),
                    validator: (v) => v == null ? 'Select Faculty' : null,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.pushNamed(context, '/confirm', arguments: {
                          'name': _nameCtrl.text,
                          'email': _emailCtrl.text,
                          'id': _idCtrl.text,
                          'faculty': _selectedFaculty!,
                        });
                      }
                    },
                    child: const Text('Register'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// SCREEN 2: CONFIRMATION 
class ConfirmationScreen extends StatelessWidget {
  const ConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // FIX: Safely retrieve arguments
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
    
    // Fallback if data is missing
    if (args == null) return const Scaffold(body: Center(child: Text("No Data Found")));

    final name = args['name']!;
    
    return Scaffold(
      appBar: AppBar(title: const Text('Registration Confirmed')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(radius: 40, child: Text(name[0].toUpperCase(), style: const TextStyle(fontSize: 30))),
            const SizedBox(height: 20),
            Card(
              child: ListTile(
                title: Text("Name: $name"),
                subtitle: Text("Email: ${args['email']}\nID: ${args['id']}\nFaculty: ${args['faculty']}"),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _statWidget("Len", name.length.toString()),
                _statWidget("Fac", args['faculty']![0]),
                _statWidget("Init", name[0]),
              ],
            ),
            const Spacer(),
            OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text("Edit Details")),
            ElevatedButton(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Submitted!"))), 
              child: const Text("Confirm & Submit")
            ),
          ],
        ),
      ),
    );
  }

  Widget _statWidget(String label, String value) => Column(children: [Text(label), Text(value, style: const TextStyle(fontWeight: FontWeight.bold))]);
}