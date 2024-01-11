import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

const String _baseURL = 'http://192.168.43.40:8080/homerental';

final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

class AddCategory extends StatefulWidget {
  const AddCategory({Key? key}) : super(key: key);

  @override
  State<AddCategory> createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  TextEditingController _controllerId = TextEditingController();
  TextEditingController _controllerLocation = TextEditingController();
  TextEditingController _controllerRooms = TextEditingController();
  TextEditingController _controllerPricePerDay = TextEditingController();
  TextEditingController _controllerImage = TextEditingController();
  bool _loading = false;

  void update(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Listing')),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              const SizedBox(height: 10),
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _controllerId,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter ID',
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _controllerLocation,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter Location',
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _controllerRooms,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter Rooms',
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _controllerPricePerDay,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter Price Per Day',
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _controllerImage,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter Image Text',
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _loading = true;
                  });
                  saveListing(
                    update,
                    _controllerId.text.toString(),
                    _controllerLocation.text.toString(),
                    int.parse(_controllerRooms.text.toString()),
                    int.parse(_controllerPricePerDay.text.toString()),
                    _controllerImage.text,
                  );
                },
                child: const Text('Submit'),
              ),
              const SizedBox(height: 10),
              Visibility(
                visible: _loading,
                child: const CircularProgressIndicator(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void saveListing(
    Function(String text) update,
    String id,
    String location,
    int rooms,
    int pricePerDay,
    String imageText,
    ) async {
  try {
    String? myKey = await _secureStorage.read(key: 'your_key');

    final response = await http.post(
      Uri.parse('$_baseURL/addListing.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: convert.jsonEncode({
        'id': id,
        'location': location,
        'rooms': rooms,
        'priceperday': pricePerDay,
        'imagetext': imageText,
        'key': 'your_key',
      }),
    ).timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      update(response.body);
    }
  } catch (e) {
    update("Connection error");
  }
}
