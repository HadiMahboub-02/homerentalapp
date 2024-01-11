import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const String _baseURL = 'http://192.168.43.40:8080/homerental';
final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

class CalculateTotalCost extends StatefulWidget {
  final int id;
  final int price;
  final String image;

  const CalculateTotalCost({
    required this.id,
    required this.price,
    required this.image,
  });

  @override
  _CalculateTotalCostState createState() => _CalculateTotalCostState();
}

class _CalculateTotalCostState extends State<CalculateTotalCost> {
  TextEditingController arrivalDateController = TextEditingController();
  TextEditingController departureDateController = TextEditingController();
  DateTime arrivalDate = DateTime.now();
  DateTime departureDate = DateTime.now();
  int totalPrice = 0;

  Future<void> _selectDate(BuildContext context, bool isArrivalDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isArrivalDate ? arrivalDate : departureDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isArrivalDate) {
          arrivalDate = picked;
          arrivalDateController.text =
          "${arrivalDate != null ? "${arrivalDate!.year}-${arrivalDate!.month.toString().padLeft(2, '0')}-${arrivalDate!.day.toString().padLeft(2, '0')}" : ''}";
        } else {
          departureDate = picked;
          departureDateController.text =
          "${departureDate != null ? "${departureDate!.year}-${departureDate!.month.toString().padLeft(2, '0')}-${departureDate!.day.toString().padLeft(2, '0')}" : ''}";
        }
      });
    }
  }

  void calculateTotalPrice() {
    if (departureDate.isAfter(arrivalDate)) {
      int numberOfDays = departureDate.difference(arrivalDate).inDays;
      totalPrice = widget.price * numberOfDays;
    } else {
      totalPrice = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Total Cost'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(widget.image),
              SizedBox(height: 18),
              Text('Price Per Day: \$${widget.price}'),
              SizedBox(height: 18),
              ElevatedButton(
                onPressed: () => _selectDate(context, true),
                child: Text('Select Arrival Date'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: arrivalDateController,
                readOnly: true,
                decoration: InputDecoration(labelText: 'Arrival Date'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _selectDate(context, false),
                child: Text('Select Departure Date'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: departureDateController,
                readOnly: true,
                decoration: InputDecoration(labelText: 'Departure Date'),
              ),
              SizedBox(height: 10),
              Text('Total Price: \$$totalPrice'),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    calculateTotalPrice();
                  });
                },
                child: Text('Calculate Price'),
              ),
              ElevatedButton(
                onPressed: () {
                  calculateTotalPrice();
                  saveCategory(
                        (text) {

                      print(text);
                    },
                    widget.id,
                    arrivalDate.toString(),
                    departureDate.toString(),
                    totalPrice,
                    context, // Add the context here
                  );
                },
                child: Text('Confirm Rent'),
              ),

            ],
          ),
        ),
      ),
    );
  }
}

void showAlertDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Renting Status"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: Text("OK"),
          ),
        ],
      );
    },
  );
}

void saveCategory(
    Function(String text) update,
    int id,
    String arrivalDate,
    String departureDate,
    int totalPrice,
    BuildContext context,
    ) async {
  try {
    String? myKey = await _secureStorage.read(key: 'your_key');
    final response = await http.post(
      Uri.parse('$_baseURL/addRent.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: convert.jsonEncode(
        <String, dynamic>{
          'id': id,
          'rentfrom': arrivalDate,
          'rentto': departureDate,
          'totalprice':totalPrice,
          'key': 'your_key',
        },
      ),
    ).timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      update(response.body);
      showAlertDialog(context, response.body);
    } else {
      showAlertDialog(context, "Renting failed");
    }
  } catch (e) {
    showAlertDialog(context, "Connection error");
  }
}
