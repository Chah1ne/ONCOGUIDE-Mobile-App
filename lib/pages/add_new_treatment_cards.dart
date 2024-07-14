import 'package:flutter/material.dart';
import '../widgets/bottom_navigation.dart';
import 'add_new_treatment.dart';

class AddNewTreatmentCards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Add New Treatment', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            CardRow(),
            SizedBox(height: 16.0),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: 3,
        onTabTapped: (index) {
          // Handle bottom navigation item tapped, add logic if needed
        },
      ),

    );
  }
}

class CardRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CardItem(imageUrl: 'assets/chemio.png'),
      ],
    );
  }
}

class CardItem extends StatelessWidget {
  final String imageUrl;

  CardItem({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddNewTreatmentPage(),
          ),
        );
      },
      child: Card(
        child: SizedBox(
          width: 120.0,
          height: 120.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                imageUrl,
                width: double.infinity,
                height: 80.0,
                fit: BoxFit.cover,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chemotherapy',
                      style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4.0),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
