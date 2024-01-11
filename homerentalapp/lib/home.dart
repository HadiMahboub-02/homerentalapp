import 'package:flutter/material.dart';
import 'viewlisting.dart';
import 'AddListingPage.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Navigate to the page for adding a listing
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddCategory()),
                );
              },
              child: Text('Add Listing'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ViewListingPage()),
                );
              },
              child: Text('View Listings'),
            ),
          ],
        ),
      ),
    );
  }
}