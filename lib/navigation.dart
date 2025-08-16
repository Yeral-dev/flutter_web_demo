import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'create_user.dart';
import 'login.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> cart = [];
  List<Map<String, dynamic>> products = []; // Lista de productos

  // Variable para almacenar el nombre y la foto del usuario
  String userName =
      "John Doe"; // Esto lo puedes actualizar según el nombre real del usuario
  File? userImage; // Esto lo actualizarás cuando el usuario seleccione su foto

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      ProductList(
        products:
            products, // Enviar la lista de productos a la vista de productos
        onAddToCart: (product) {
          setState(() {
            cart.add(product);
          });
        },
      ),
      CartScreen(cart: cart),
      UserScreen(
        userName: userName,
        userImage: userImage,
      ), // Pasar datos del usuario
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Tienda Flutter')),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Productos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Carrito',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Usuario'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class ProductList extends StatelessWidget {
  final Function(Map<String, dynamic>) onAddToCart;
  final List<Map<String, dynamic>> products;

  ProductList({required this.onAddToCart, required this.products, super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(products[index]['name']),
          subtitle: Text('\$${products[index]['price']}'),
          trailing: IconButton(
            icon: const Icon(Icons.add_shopping_cart),
            onPressed: () => onAddToCart(products[index]),
          ),
        );
      },
    );
  }
}

class CartScreen extends StatelessWidget {
  final List<Map<String, dynamic>> cart;

  const CartScreen({required this.cart, super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: cart.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(cart[index]['name']),
          subtitle: Text('\$${cart[index]['price']}'),
        );
      },
    );
  }
}

class UserScreen extends StatefulWidget {
  final String userName;
  final File? userImage;

  UserScreen({required this.userName, this.userImage, super.key});

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  File? _image;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 50,
              backgroundImage:
                  widget.userImage != null
                      ? FileImage(widget.userImage!)
                      : _image != null
                      ? FileImage(_image!)
                      : NetworkImage('https://via.placeholder.com/150')
                          as ImageProvider,
            ),
          ),
          SizedBox(height: 20),
          Text('Usuario: ${widget.userName}', style: TextStyle(fontSize: 20)),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => PantallaLogin()),
              );
            },
            child: Text('Cerrar sesión'),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateUserScreen()),
              );
            },
            child: Text('Crear Usuario'),
          ),
        ],
      ),
    );
  }
}
