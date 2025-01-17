import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'login_screen.dart';

// Product Page
class ProductPage extends StatelessWidget {
  final List<Map<String, String>> products = [
    {'name': 'Laptop', 'price': '\$1000'},
    {'name': 'Phone', 'price': '\$500'},
    {'name': 'Headphones', 'price': '\$200'},
    {'name': 'Smart Watch', 'price': '\$150'},
    {'name': 'TV', 'price': '\$750'},
    {'name': 'Mouse', 'price': '\$250'},
    {'name': 'Bluetooth', 'price': '\$550'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF8174A0),
      appBar: AppBar(
        backgroundColor: Color(0xFF536493),
        title: Text('Products'),
        actions: [
          IconButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              icon: Icon(Icons.logout))
        ],
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              leading: Icon(Icons.shopping_bag),
              title: Text(products[index]['name']!),
              subtitle: Text(products[index]['price']!),
            ),
          );
        },
      ),
    );
  }
}
