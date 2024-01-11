import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'housedetails.dart';

const String _baseURL = 'http://192.168.43.40:8080/homerental';
List<House> _houses = [];
List<Location> _locations=[];



void updateProducts(Function callback) async {
  try {
    final url = Uri.parse('$_baseURL/getListing.php');
    final response = await http.get(url).timeout(const Duration(seconds: 10));

    _houses.clear();
    _locations.clear();
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      for (var row in jsonResponse) {
        print('Row: $row');

        try {
          House p = House(
            int.parse(row['id']),
            row['location'],
            int.parse(row['rooms']),
            int.parse(row['priceperday']),
            row['image'],
          );
          Location l = Location(
            row['location'],
          );
          _houses.add(p);
          if (!_locations.any((location) => l._location.toLowerCase() == location.getName().toLowerCase())) {
            _locations.add(l);
          }

        } catch (e) {
          print('Error adding house: $e');
        }
      }
      print(_locations);


      // Call the callback to update the UI
      callback();
    }
  } catch (e, stackTrace) {
    print('Error: $e\n$stackTrace');
  }
}

class ViewListingPage extends StatefulWidget {
  const ViewListingPage({Key? key}) : super(key: key);

  @override
  State<ViewListingPage> createState() => _ViewListingPageState();
}

class _ViewListingPageState extends State<ViewListingPage> {
  String? _selectedLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Listings'),
        actions: [
          IconButton(
            onPressed: () {
              // Pass the setState method as a callback
              updateProducts(() {
                setState(() {});
              });
            },
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [

          Align(
            alignment: Alignment.center,
            child:

            DropdownButton(
              hint: Text('Please choose a location'),
              value: _selectedLocation,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedLocation = newValue;
                });
              },
              items: [

                DropdownMenuItem<String>(
                  child: Text('Please choose a location'),
                  value: null,
                ),
                // Add locations
                ..._locations.map((Location location) => DropdownMenuItem<String>(
                  child: Text(location.getName()),
                  value: location.getName(),
                )).toList(),
              ],
            ),


          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
                childAspectRatio: 0.7,
              ),
              itemCount: _houses.length,
              itemBuilder: (context, index) {
                final house = _houses[index];

                return HouseCard(
                  id:house._id,
                  image: house._image,
                  price: house._pricePerDay,
                  numberOfRooms: house._rooms,
                  location: house._location,
                  selected: _selectedLocation?.toLowerCase() == house._location.toLowerCase(),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}


class House {
  int _id;
  String _location;
  int _rooms;
  int _pricePerDay;
  String _image;

  House(this._id, this._location, this._rooms, this._pricePerDay, this._image);

  @override
  String toString() {
    return 'ID: $_id Location: $_location Rooms: $_rooms PricePerDay: $_pricePerDay';
  }
}

class Location{
  String _location;

  Location(this._location);

  @override
  String toString() {
    return 'Location: $_location' ;
  }
  String getName(){
    return _location;
  }
}

class HouseCard extends StatelessWidget {
  final int id;
  final String image;
  final int price;
  final int numberOfRooms;
  final String location;
  final bool selected;

  HouseCard({
    required this.id,
    required this.image,
    required this.price,
    required this.numberOfRooms,
    required this.location,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HouseDetailsPage(
              id:id,
              image: image,
              price: price,
              numberOfRooms: numberOfRooms,
              location: location,
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.all(8.0),
        color: selected ? Colors.green : null,
        child: Column(
          children: [
            Expanded(
              child: Image.network(image),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RentPerDay: \$$price',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Rooms: $numberOfRooms',
                    style: TextStyle(fontSize: 10),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Location: $location',
                    style: TextStyle(fontSize: 10),
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
