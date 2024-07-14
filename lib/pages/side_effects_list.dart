import 'package:flutter/material.dart';
import '../models/SideEffects.dart';
import '../widgets/DoctorBottom_navigation.dart';
import 'account.dart';
import '../services/sideEffects_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();

class SideEffectsListPage extends StatefulWidget {
  @override
  _SideEffectsListPageState createState() => _SideEffectsListPageState();
}

Future<String?> _getToken() async {
  try {
    final token = await storage.read(key: 'token');
    return token;
  } catch (e) {
    print('Error retrieving token: $e');
    return null;
  }
}

class _SideEffectsListPageState extends State<SideEffectsListPage> {
  List<SideEffect> sideEffects = [];
  bool showingHistory = false;

  @override
  void initState() {
    super.initState();
    _fetchSideEffects();
  }

  Future<void> _fetchSideEffects() async {
    final token = await _getToken();
    if (token != null) {
      try {
        List<dynamic> fetchedSideEffects;
        if (showingHistory) {
          fetchedSideEffects = await SideEffectsService.fetchSideEffectsHistory(token);
        } else {
          fetchedSideEffects = await SideEffectsService.fetchSideEffects(token);
        }
        List<SideEffect> parsedSideEffects = fetchedSideEffects.map((json) => SideEffect.fromJson(json)).toList();
        setState(() {
          sideEffects = parsedSideEffects;
        });
      } catch (e) {
        print('Failed to load side effects: $e');
      }
    } else {
      print("Token is not detected");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: Text(showingHistory ? 'Side Effects History' : 'Side Effects', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.account_circle, color: Colors.white),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => AccountPage()));
          },
        ),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                Icon(showingHistory ? Icons.arrow_back : Icons.history_rounded, color:Colors.white),
              ],
            ),
            onPressed: () {
              setState(() {
                showingHistory = !showingHistory;
                _fetchSideEffects();
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: () {
              _showAddPatientPopup(context);
            },
          ),
        ],
      ),
      body: sideEffects.isEmpty
          ? Center(
        child: CircularProgressIndicator(),
      )
          : ListView.builder(
        itemCount: sideEffects.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(sideEffects[index].selectedSymptom ?? ''),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Type: ${sideEffects[index].selectedType ?? ''}'),
                Text('Email: ${sideEffects[index].userEmail ?? ''}'),
              ],
            ),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SideEffectDetailPage(
                    sideEffect: sideEffects[index],
                    showingHistory: showingHistory,
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: DoctorBottomNavigation(
        currentIndex: 0,
        onTabTapped: (index) {
          // Handle bottom navigation item tapped, add logic if needed
        },
      ),
    );
  }

  void _showAddPatientPopup(BuildContext context) {
    String patientId = '';
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Patient'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  onChanged: (value) {
                    patientId = value;
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a patient ID';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter patient ID...',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  try {
                    final String? token = await _getToken();
                    await SideEffectsService.associateDoctorWithPatient(token!, int.parse(patientId));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Patient added successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    _fetchSideEffects();
                    Navigator.of(context).pop(); // Pop the dialog after successful addition
                  } catch (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to add patient: $error'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: Text('Add', style: TextStyle(color: Colors.white)),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(color: Colors.white)),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }


}

class SideEffectDetailPage extends StatelessWidget {
  final SideEffect sideEffect;
  final bool showingHistory;

  SideEffectDetailPage({required this.sideEffect, required this.showingHistory});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Side Effect Details',
            style: TextStyle(color: Colors.white, fontSize: 22)),
        backgroundColor: Colors.blue[900],
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView( // Envelopper le contenu dans SingleChildScrollView
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Symptom: ${sideEffect.selectedSymptom}',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                'Type: ${sideEffect.selectedType}',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                'Severity: ${sideEffect.selectedSeverity}',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                'Duration: ${sideEffect.duration}',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                'Additional Notes: ${sideEffect.additionalNotes}',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 16),
              // Display image or placeholder
              sideEffect.imageUrl != null && sideEffect.imageUrl.isNotEmpty
                  ? Image.network(sideEffect.imageUrl)
                  : Text('No image provided',
                  style: TextStyle(fontSize: 18)),
              SizedBox(height: 16),
              if (!showingHistory)
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      _showHandlePopup(context, sideEffect);
                    },
                    child: Text(
                      'Handle',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                    ),
                  ),
                )
              else
                Text(
                  'Handled by: ${sideEffect.doctorId}\n'
                      'Doctor\'s Response: ${sideEffect.doctorResponse}',
                  style: TextStyle(fontSize: 18),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHandlePopup(BuildContext context, SideEffect sideEffect) {
    String doctorResponse = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Handle Side Effect',
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    onChanged: (value) {
                      doctorResponse = value;
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter doctor response...',
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _handleSideEffect(context, sideEffect, doctorResponse);
                          Navigator.of(context).pop();
                        },
                        child: Text('Send', style: TextStyle(color: Colors.white)),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Cancel', style: TextStyle(color: Colors.white)),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleSideEffect(BuildContext context, SideEffect sideEffect, String doctorResponse) async {
    final token = await _getToken();
    if (token != null) {
      try {
        await SideEffectsService.markSideEffectAsDone(token, sideEffect.id, doctorResponse);
        Navigator.pop(context);
      } catch (e) {
        print('Failed to mark side effect as done: $e');
      }
    } else {
      print("Token is not detected");
    }
  }
}

