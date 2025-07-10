import 'package:flutter/material.dart';

class FontDemo extends StatelessWidget {
  const FontDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Font Demo - Bucklane',
          style: TextStyle(
            fontFamily: 'Bucklane',
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Font Bucklane Examples:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            // Contoh penggunaan font Bucklane dengan berbagai ukuran
            const Text(
              'Heading Large - Bucklane Font',
              style: TextStyle(
                fontFamily: 'Bucklane',
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 16),
            
            const Text(
              'Medium Text - Bucklane Font',
              style: TextStyle(
                fontFamily: 'Bucklane',
                fontSize: 24,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 16),
            
            const Text(
              'Small Text - Bucklane Font',
              style: TextStyle(
                fontFamily: 'Bucklane',
                fontSize: 18,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 32),
            
            // Perbandingan dengan font default
            const Text(
              'Comparison with Default Font:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            const Text(
              'This text uses Bucklane font',
              style: TextStyle(
                fontFamily: 'Bucklane',
                fontSize: 20,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 8),
            
            const Text(
              'This text uses default font',
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            
            // Instruksi penggunaan
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cara menggunakan font Bucklane:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '1. Pastikan font sudah didefinisikan di pubspec.yaml',
                    style: TextStyle(fontSize: 14),
                  ),
                  const Text(
                    '2. Gunakan fontFamily: \'Bucklane\' dalam TextStyle',
                    style: TextStyle(fontSize: 14),
                  ),
                  const Text(
                    '3. Jalankan flutter pub get setelah menambah font',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Text(\n  "Your text here",\n  style: TextStyle(\n    fontFamily: \'Bucklane\',\n    fontSize: 20,\n  ),\n)',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        color: Colors.lightGreenAccent,
                        fontSize: 12,
                      ),
                    ),
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