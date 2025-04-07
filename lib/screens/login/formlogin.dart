import 'package:flutter/material.dart';

class Formlogin extends StatefulWidget {
  final String deviceId;
  const Formlogin({super.key, required this.deviceId});

  @override
  State<Formlogin> createState() => _FormloginState();
}

class _FormloginState extends State<Formlogin> {
  final List<String> _questions = [
    'Número de Carnet',
    'Fecha de Nacimiento (DD/MM/AAAA)',
    'Número de Celular',
  ];
  final List<String> _answers = [];
  final TextEditingController _controller = TextEditingController();
  int _currentStep = 0;

  void _nextStep() {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _answers.add(_controller.text.trim());
      _controller.clear();
      _currentStep++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = _currentStep >= _questions.length;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Device ID: ${widget.deviceId}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _answers.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading:
                        const Icon(Icons.check_circle, color: Colors.green),
                    title: Text(_questions[index]),
                    subtitle: Text(_answers[index]),
                  );
                },
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: isCompleted
                  ? const Text(
                      '¡Registro completo!',
                      key: ValueKey('done'),
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    )
                  : Column(
                      key: ValueKey(_currentStep),
                      children: [
                        Text(
                          _questions[_currentStep],
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _controller,
                          onSubmitted: (_) => _nextStep(),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Escribe tu respuesta...',
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _nextStep,
                          child: const Text('Siguiente'),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
