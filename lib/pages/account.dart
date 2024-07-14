import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:patient_app/pages/signin.dart';
import 'package:url_launcher/url_launcher.dart';

import 'add_new_treatment_cards.dart';
import 'editProfilePage.dart';

class AccountPage extends StatelessWidget {
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<String?> _getToken() async {
    try {
      final token = await _storage.read(key: 'token');
      return token;
    } catch (e) {
      print('Error retrieving token: $e');
      return null;
    }
  }

  Future<void> _logout(BuildContext context) async {
    await _storage.delete(key: 'token');
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => SignInPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Account',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue[900],
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<String?>(
        future: _getToken(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error fetching user ID',
                  style: TextStyle(color: Colors.red, fontSize: 16.0),
                ),
              );
            } else if (snapshot.data != null) {
              String userId = Jwt.parseJwt(snapshot.data!)['id'].toString();
              return _buildAccountPage(context, userId);
            }
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildAccountPage(BuildContext context, String userId) {
    return ListView(
      padding: EdgeInsets.all(16.0),
      children: [
        _buildSectionTitle('Account Information'),
        SizedBox(height: 10),
        Center(
          child: Text(
            'Your User ID:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
          ),
        ),
        Center(
          child: Text(
            userId,
            style: TextStyle(fontSize: 20.0),
          ),
        ),
        SizedBox(height: 20),
        _buildClickableItem('Edit Profile', Icons.person, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EditProfilePage()),
          );
        }),
        _buildClickableItem('My Treatments List', Icons.list_alt, () {
          // Add your logic for My Treatments List here
        }),
        _buildNotificationSwitch(),
        SizedBox(height: 20),
        _buildSectionTitle('More'),
        _buildClickableItemWithLinkIcon('About Us', Icons.info, 'https://www.example.com/about', () {
          // Add your logic for About Us here
        }),
        _buildClickableItemWithLinkIcon('Privacy Policy', Icons.privacy_tip, 'https://www.example.com/privacy', () {
          // Add your logic for Privacy Policy here
        }),
        _buildClickableItemWithLinkIcon('Terms and Conditions', Icons.library_books, 'https://www.example.com/terms', () {
          // Add your logic for Terms and Conditions here
        }),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => _logout(context),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, backgroundColor: Colors.red,
          ),
          child: Text('Logout'),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => AddNewTreatmentCards()));
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, backgroundColor: Colors.blue[900],
          ),
          child: Text('Add New Treatment'),
        ),
        SizedBox(height: 20),
        Text('Made By',style: TextStyle(color: Colors.grey, fontSize: 16.0,)),
        SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLinkedInProfile('Chahine Tsouri', 'https://www.linkedin.com/in/tsouri-chahine'),
            Text(
              '   &   ',
              style: TextStyle(
                color: Colors.grey[700],
                fontStyle: FontStyle.italic,
                fontSize: 17.0,
              ),
            ),
            _buildLinkedInProfile('Borhen Mezghani', 'https://www.linkedin.com/in/borhenmzgh/'),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.bold,
          fontSize: 16.0,
        ),
      ),
    );
  }

  Widget _buildClickableItem(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      title: Text(title),
      leading: Icon(icon),
      onTap: onTap,
    );
  }

  Widget _buildClickableItemWithLinkIcon(String title, IconData icon, String url, VoidCallback onTap) {
    return ListTile(
      title: Row(
        children: [
          Icon(icon),
          SizedBox(width: 4),
          Text(title),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildNotificationSwitch() {
    bool notificationValue = true;

    return ListTile(
      title: Text('Notifications'),
      trailing: Switch(
        value: notificationValue,
        onChanged: (value) {
          // Add your logic for handling notifications switch here
        },
      ),
    );
  }

  Widget _buildLinkedInProfile(String name, String url) {
    return GestureDetector(
      onTap: () => _launchLinkedInProfile(url),
      child: Row(
        children: [
          Icon(Icons.link),
          SizedBox(width: 5),
          Text(
            name,
            style: TextStyle(
              color: Colors.blue,
              fontStyle: FontStyle.italic,
              fontSize: 15.0,
            ),
          ),
        ],
      ),
    );
  }

  void _launchLinkedInProfile(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
