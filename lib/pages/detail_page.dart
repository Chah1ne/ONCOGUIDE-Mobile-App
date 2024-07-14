import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class DetailPage extends StatelessWidget {
  final Map<String, dynamic> cardDetails;

  const DetailPage({Key? key, required this.cardDetails}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> images = (cardDetails['images'] as String?)?.split(',') ?? [];

    // Vérifiez si la liste d'images est vide
    if (images.isNotEmpty) {
      final List<Widget> imageWidgets = [];

      for (final imageUrl in images) {
        // Vérifiez si l'URL de l'image est vide ou nulle
        if (imageUrl.trim().isNotEmpty) {
          // Vérifiez si l'URL de l'image commence par "http://" ou "https://"
          if (imageUrl.trim().startsWith('http://') || imageUrl.trim().startsWith('https://')) {
            imageWidgets.add(
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    imageUrl.trim(),
                    width: 150,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          } else {
            // Si l'URL n'est pas valide, arrêtez le traitement des images
            break;
          }
        }
      }

      return Scaffold(
        backgroundColor: Colors.white,
        body: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              backgroundColor: Colors.transparent,
              expandedHeight: 200.0,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Image.network(
                  cardDetails['iconImage'],
                  fit: BoxFit.cover,
                ),
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      cardDetails['name'],
                      style: GoogleFonts.poppins(
                        fontSize: 36.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(
                      'Card Information',
                      style: GoogleFonts.poppins(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    Divider(color: Colors.grey),
                    SizedBox(height: 20),

                    Text(
                      'Description',
                      style: GoogleFonts.poppins(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      cardDetails['description'] ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: 16.0,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 25),
                    Text(
                      'Gallery',
                      style: GoogleFonts.poppins(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      height: 100,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: imageWidgets,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Video',
                      style: GoogleFonts.poppins(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 20),
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: YoutubePlayer(
                        controller: YoutubePlayerController(
                          initialVideoId: YoutubePlayer.convertUrlToId(cardDetails['video']) ?? '',
                          flags: YoutubePlayerFlags(
                            autoPlay: false,
                            mute: false,
                            hideControls: false,
                            controlsVisibleAtStart: true,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Affiche un message ou une indication qu'il n'y a pas d'images à afficher
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Text(
            'Aucune image disponible',
            style: TextStyle(fontSize: 20),
          ),
        ),
      );
    }
  }
}
