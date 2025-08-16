import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _title, _description, _price;
  File? _imageFile;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  void _showProductDialog({Map<String, dynamic>? product}) {
    _title = product?['title'];
    _description = product?['description'];
    _price = product?['price'];
    _imageFile = null;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            product == null ? 'Agregar Producto' : 'Editar Producto',
            style: TextStyle(color: Colors.blue),
          ),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField('Título', _title, (value) => _title = value),
                SizedBox(height: 10),
                _buildTextField(
                  'Descripción',
                  _description,
                  (value) => _description = value,
                ),
                SizedBox(height: 10),
                _buildTextField(
                  'Precio',
                  _price,
                  (value) => _price = value,
                  isNumeric: true,
                ),
                SizedBox(height: 15),
                _buildImagePreview(),
                SizedBox(height: 10),
                _buildImageButton(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar', style: TextStyle(color: Colors.blue)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: () => _saveProduct(product),
              child: Text(product == null ? 'Agregar' : 'Actualizar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(
    String label,
    String? initialValue,
    Function(String?) onSaved, {
    bool isNumeric = false,
  }) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      onSaved: onSaved,
      validator: (value) => value!.isEmpty ? 'Ingrese $label' : null,
    );
  }

  Widget _buildImagePreview() {
    return _imageFile != null
        ? Image.file(_imageFile!, height: 100, fit: BoxFit.cover)
        : Container(
          height: 100,
          color: Colors.grey[300],
          child: Icon(Icons.image, size: 50, color: Colors.blue),
        );
  }

  Widget _buildImageButton() {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
      onPressed: _pickImageFromGallery,
      icon: Icon(Icons.photo, color: Colors.white),
      label: Text('Seleccionar imagen', style: TextStyle(color: Colors.white)),
    );
  }

  void _pickImageFromGallery() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _saveProduct(Map<String, dynamic>? product) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (_imageFile == null && product == null) {
        _showSnackBar('Seleccione una imagen', Colors.orange);
        return;
      }
      String imageUrl = product?['imageUrl'] ?? '';
      if (_imageFile != null) {
        String filePath =
            'product_images/${DateTime.now().millisecondsSinceEpoch}.jpg';
        TaskSnapshot uploadTask = await _storage
            .ref(filePath)
            .putFile(_imageFile!);
        imageUrl = await uploadTask.ref.getDownloadURL();
      }
      final newProduct = {
        'title': _title,
        'description': _description,
        'price': _price,
        'imageUrl': imageUrl,
      };
      if (product == null) {
        await _firestore.collection('products').add(newProduct);
        _showSnackBar('Producto agregado', Colors.green);
      } else {
        await _firestore
            .collection('products')
            .doc(product['id'])
            .update(newProduct);
        _showSnackBar('Producto actualizado', Colors.blue);
      }
      Navigator.pop(context);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Gestión de Productos'),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());
          var data = snapshot.data!.docs;
          return ListView.builder(
            padding: EdgeInsets.all(10),
            itemCount: data.length,
            itemBuilder: (context, index) {
              var product = data[index].data() as Map<String, dynamic>;
              String productId = data[index].id;
              return ListTile(
                leading:
                    product['imageUrl'] != null
                        ? Image.network(product['imageUrl'], width: 50)
                        : Icon(Icons.image, size: 50),
                title: Text(product['title']),
                subtitle: Text('\$${product['price']}'),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed:
                      () =>
                          _firestore
                              .collection('products')
                              .doc(productId)
                              .delete(),
                ),
                onTap:
                    () => _showProductDialog(
                      product: {'id': productId, ...product},
                    ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.yellow,
        onPressed: () => _showProductDialog(),
        child: Icon(Icons.add, color: Colors.blue),
      ),
    );
  }
}
