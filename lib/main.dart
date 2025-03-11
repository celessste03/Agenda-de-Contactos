import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agenda de Contactos',
      theme: ThemeData(
        primaryColor: Color(0xFF61C6C5),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: Color(0xFFB6D8D7),
        ),
        scaffoldBackgroundColor: Color(0xFFF0F5F4),
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
          bodyMedium: TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ),
      home: ContactListScreen(),
    );
  }
}

class Contact {
  String name;
  String phone;
  String email;
  String alias;
  bool isFavorite;

  Contact(
      {required this.name,
      required this.phone,
      required this.email,
      required this.alias,
      this.isFavorite = false});
}

class ContactListScreen extends StatefulWidget {
  @override
  _ContactListScreenState createState() => _ContactListScreenState();
}

class _ContactListScreenState extends State<ContactListScreen> {
  final List<Contact> contacts = [];

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _aliasController = TextEditingController();

  void _addContact() {
    if (_phoneController.text.length != 11) {
      _showAlert('El número de teléfono debe tener 11 dígitos.');
      return;
    }

    if (!_emailController.text.contains('@')) {
      _showAlert('El correo debe contener un signo de @.');
      return;
    }

    final formattedPhone = _phoneController.text.substring(0, 4) +
        '-' +
        _phoneController.text.substring(4);

    final newContact = Contact(
      name: _nameController.text,
      phone: formattedPhone,
      email: _emailController.text,
      alias: _aliasController.text,
    );

    setState(() {
      contacts.add(newContact);
      _sortContacts();
    });

    _nameController.clear();
    _phoneController.clear();
    _emailController.clear();
    _aliasController.clear();
  }

  void _editContact(int index) {
    final contact = contacts[index];
    _nameController.text = contact.name;
    _phoneController.text = contact.phone.replaceAll('-', '');
    _emailController.text = contact.email;
    _aliasController.text = contact.alias;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar Contacto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(_nameController, 'Nombre'),
            SizedBox(height: 8),
            _buildTextField(_phoneController, 'Teléfono', isPhone: true),
            SizedBox(height: 8),
            _buildTextField(_emailController, 'Correo'),
            SizedBox(height: 8),
            _buildTextField(_aliasController, 'Alias'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (_phoneController.text.length != 11) {
                _showAlert('El número de teléfono debe tener 11 dígitos.');
                return;
              }

              if (!_emailController.text.contains('@')) {
                _showAlert('El correo debe contener un signo de @.');
                return;
              }

              setState(() {
                contact.name = _nameController.text;
                contact.phone = _phoneController.text.substring(0, 4) +
                    '-' +
                    _phoneController.text.substring(4);
                contact.email = _emailController.text;
                contact.alias = _aliasController.text;
                _sortContacts();
              });
              Navigator.of(context).pop();
              _clearFields();
            },
            child: Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _deleteContactWithConfirmation(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿Seguro que quieres eliminar este contacto?'),
        content: Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                contacts.removeAt(index);
              });
              Navigator.of(context).pop();
            },
            child: Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _toggleFavorite(int index) {
    setState(() {
      contacts[index].isFavorite = !contacts[index].isFavorite;
      _sortContacts();
    });
  }

  void _sortContacts() {
    contacts.sort((a, b) {
      if (a.isFavorite && !b.isFavorite) {
        return -1;
      } else if (!a.isFavorite && b.isFavorite) {
        return 1;
      } else {
        return 0;
      }
    });
  }

  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _clearFields() {
    _nameController.clear();
    _phoneController.clear();
    _emailController.clear();
    _aliasController.clear();
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isPhone = false}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: isPhone ? TextInputType.number : TextInputType.text,
      maxLength: isPhone ? 11 : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person),
            SizedBox(width: 8),
            Text('Agenda Telefónica'),
          ],
        ),
        backgroundColor: Color(0xFF61C6C5),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildTextField(_nameController, 'Nombre'),
                SizedBox(height: 10),
                _buildTextField(_phoneController, 'Teléfono', isPhone: true),
                SizedBox(height: 10),
                _buildTextField(_emailController, 'Correo'),
                SizedBox(height: 10),
                _buildTextField(_aliasController, 'Alias'),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _addContact,
                  child: Text('Añadir Contacto'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF61C6C5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                  child: ListTile(
                    title: Text(contact.name,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        '${contact.alias}\n${contact.phone}\n${contact.email}',
                        style: TextStyle(color: Colors.black54)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(contact.isFavorite
                              ? Icons.star
                              : Icons.star_border),
                          onPressed: () => _toggleFavorite(index),
                          color: Colors.amber,
                        ),
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _editContact(index),
                          color: Colors.blue,
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () =>
                              _deleteContactWithConfirmation(index),
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
