import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:patient_app/pages/EditEducationPage.dart';
import 'package:patient_app/pages/detail_page.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../widgets/DoctorBottom_navigation.dart';
import 'constants.dart';
import '../widgets/bottom_navigation.dart';

class AllEducationCardsPage extends StatefulWidget {
  @override
  _AllEducationCardsPageState createState() => _AllEducationCardsPageState();
}

class _AllEducationCardsPageState extends State<AllEducationCardsPage> {
  final storage = FlutterSecureStorage();
  List<dynamic> educationCards = [];
  List<dynamic> selectedCards = [];
  String userId = '';


  @override
  void initState() {
    super.initState();
    fetchEducationCards();
  }

  Future<void> fetchEducationCards() async {
    try {
      final token = await storage.read(key: 'token');
      final userId = Jwt.parseJwt(token!)['id'];

      final response = await http.get(
        Uri.parse('http://102.219.179.156:8082/education/sender/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          educationCards = json.decode(response.body);
        });
      } else {
        print('Failed to fetch education cards');
      }
    } catch (error) {
      print('Error fetching education cards: $error');
    }
  }

  Future<void> deleteEducationCard(dynamic card) async {
    try {
      final token = await storage.read(key: 'token');
      final response = await http.delete(
        Uri.parse('http://102.219.179.156:8082/education/delete/${card['id']}'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Refresh the list of educational cards after deletion
        fetchEducationCards();
      } else {
        print('Failed to delete education card');
      }
    } catch (error) {
      print('Error deleting education card: $error');
    }
  }

  Future<void> editEducationCard(dynamic card) async {
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => EditEducationPage(cardDetails: card),
      ),
    );
    // Refresh the list of educational cards after modification
    fetchEducationCards();
  }

  void toggleCardSelection(dynamic card) {
    if (selectedCards.contains(card)) {
      setState(() {
        selectedCards.remove(card);
      });
    } else {
      setState(() {
        selectedCards.add(card);
      });
    }
  }


  Future<void> assignCardsToUser(List<dynamic> selectedCards, String userId) async {
    try {
      final token = await storage.read(key: 'token');
      final List<int> cardIds = selectedCards.map((card) => card['id'] as int).toList();

      final response = await http.post(
        Uri.parse('http://102.219.179.156:8082/card-assignments/assign'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'userId': userId,
          'cardIds': cardIds,
        }),
      );

      if (response.statusCode == 200) {
        print('Cartes attribuées avec succès à l\'utilisateur $userId');
        // Effacer les cartes sélectionnées après attribution
        setState(() {
          selectedCards.clear();
        });
        // Rafraîchir la liste des cartes éducatives après attribution
        fetchEducationCards();
      } else {
        print('Error when assigning cards');
      }
    } catch (error) {
      print('Error when assigning cards: $error');
    }
  }



  Widget buildCardWidget(dynamic card) {
    bool isSelected = selectedCards.contains(card);

    return GestureDetector(
      onTap: () {
        // Open detail page on tap
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPage(cardDetails: card),
          ),
        );
      },
      onLongPress: () {
        // Show options dialog on long press
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  color: Colors.white,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      "Options",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "What do you want to do with this educational card ?",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () async {
                            await deleteEducationCard(card);
                            Navigator.of(context).pop(); // Close dialog
                          },
                          child: Text(
                            "DELETE",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Navigate to edit page
                            editEducationCard(card);
                          },
                          child: Text(
                            "To modify",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close dialog
                          },
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );

      },
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                image: NetworkImage(card['iconImage']),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.6),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    card['name'],
                    style: TextStyle(
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Education Info',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          toggleCardSelection(card);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? Colors.blue : Colors.transparent,
                          ),
                          padding: EdgeInsets.all(5),
                          child: isSelected
                              ? Icon(
                            Icons.check,
                            color: Colors.white,
                          )
                              : Icon(
                            Icons.check_circle_outline,
                            color: Colors.white,
                            size: 25.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    bool isAnyCardSelected = selectedCards.isNotEmpty;

    return Scaffold(
      backgroundColor: gradientEndColor,
      appBar: AppBar(
        backgroundColor: gradientStartColor,
        title: Row( // Utilisez un Row pour aligner le texte et l'icône horizontalement
          children: <Widget>[
            Text(
              'Share Cards',
              style: TextStyle(color: Colors.white,fontSize: 24),
            ),
          ],
        ),
        actions: <Widget>[
          if (isAnyCardSelected)
            IconButton(
              icon: Icon(Icons.send),
              onPressed: () {
                // Afficher la boîte de dialogue pour entrer l'ID de l'utilisateur
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Enter user ID"),
                      content: TextField(
                        onChanged: (value) {
                          userId = value;
                        },
                        decoration: InputDecoration(
                          hintText: "User ID",
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: Text("Cancel"),
                          onPressed: () {
                            Navigator.of(context).pop(); // Fermer la boîte de dialogue
                          },
                        ),
                        TextButton(
                          child: Text("Confirm"),
                          onPressed: () {
                            // Gérer l'envoi des cartes sélectionnées avec l'ID de l'utilisateur
                            assignCardsToUser(selectedCards, userId);
                            // Fermer la boîte de dialogue
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              color: Colors.white, // Définir la couleur de l'icône en blanc
            ),
        ],
        iconTheme: IconThemeData(color: Colors.white), // Définir la couleur de l'icône de la barre d'applications en blanc
      ),

      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [gradientStartColor, gradientEndColor],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.3, 0.7],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'All cards created by you',
                    style: TextStyle(
                      fontSize: 35.0,
                      fontWeight: FontWeight.w900,
                      color: titleTextColor,
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    height: 500.0,
                    child: educationCards.length > 1 ? CarouselSlider.builder(
                      itemCount: educationCards.length,
                      options: CarouselOptions(
                        aspectRatio: 16 / 9,
                        enlargeCenterPage: true,
                        autoPlay: true,
                        viewportFraction: 0.8,
                      ),
                      itemBuilder: (context, index, realIndex) {
                        final card = educationCards[index];
                        return buildCardWidget(card);
                      },
                    ) : (educationCards.isNotEmpty ? Center(
                      child: buildCardWidget(educationCards.first),
                    ) : Center(
                      child: CircularProgressIndicator(),
                    )),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: DoctorBottomNavigation(
        currentIndex: 2,
        onTabTapped: (index) {
          // Handle bottom navigation item tapped, add logic if needed
        },
      ),
    );
  }
}