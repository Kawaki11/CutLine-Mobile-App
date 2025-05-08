import 'package:flutter/material.dart';

import '../../../constants.dart';

class BookmarkScreen extends StatelessWidget {
  const BookmarkScreen({super.key});

  final List<Map<String, String>> services = const [
    {'name': 'Haircut', 'price': 'PHP***'},
    {'name': 'Beard', 'price': 'PHP***'},
    {'name': 'Haircut + Beard', 'price': 'PHP***'},
    {'name': 'Perm', 'price': 'PHP***'},
    {'name': 'Hair Color', 'price': 'PHP***'},
    {'name': 'Haircut with Massage', 'price': 'PHP***'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Service Catalogue"),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: ListView.builder(
          itemCount: services.length,
          itemBuilder: (context, index) {
            final service = services[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text(
                  service['name']!,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                trailing: Text(
                  '- ${service['price']}',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                onTap: () {
                  // Example queue action
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${service['name']} selected')),
                  );
                  // You can navigate to queue ticket screen here
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
