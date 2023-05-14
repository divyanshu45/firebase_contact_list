import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crud/utils/functions.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../utils/constants.dart';
import '../widgets/rounded_button.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = FirebaseAuth.instance;

  late TextEditingController nameController;
  late TextEditingController phoneController;

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser;
      if (user == null) {
        Navigator.pushReplacementNamed(context, 'registration_screen');
      }
    } catch (e) {
      print(e);
    }
  }

  void initState() {
    super.initState();
    getCurrentUser();
    nameController = TextEditingController();
    phoneController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {

    final Stream<QuerySnapshot> _contactsStream = FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .collection('contacts')
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.logout_rounded),
              onPressed: ()  async {
                if (GoogleSignIn().currentUser != null) {
                  await GoogleSignIn().signOut();
                }
                try {
                  await GoogleSignIn().disconnect();
                } catch (e) {
                  debugPrint('failed to disconnect on signout');
                }
                _auth.signOut();
                Navigator.of(context).pushReplacementNamed('login_screen');
              }),
        ],
        title: Text('Home'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _contactsStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if(snapshot.data!.docs.isEmpty){
            return Center(child: Text('No contacts found'));
          }
          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
              debugPrint(document.id);
              return Container(
                padding: EdgeInsets.all(4),
                margin: EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Name - ${data['name']}'),
                          SizedBox(height: 6,),
                          Text('Phone - ${data['phone']}'),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: (){
                        nameController.text = data['name'];
                        phoneController.text = data['phone'];
                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context){
                              return Center(
                                child: Wrap(
                                  children: [
                                    Material(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Column(
                                        children: [
                                          SizedBox(height: 10,),
                                          Text(
                                            'Update Contact',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold
                                            ),
                                          ),
                                          SizedBox(height: 10,),
                                          TextField(
                                            keyboardType: TextInputType.text,
                                            controller: nameController,
                                            decoration: textFieldDecoration.copyWith(
                                                hintText: 'Enter Name'
                                            ),
                                          ),
                                          SizedBox(height: 10,),
                                          TextField(
                                            keyboardType: TextInputType.phone,
                                            controller: phoneController,
                                            decoration: textFieldDecoration.copyWith(
                                                hintText: 'Enter Phone'
                                            ),
                                          ),
                                          SizedBox(height: 10,),
                                          RoundedButton(
                                            colour: Colors.blueAccent,
                                            title: 'Update',
                                            onPressed: () async {
                                              try {
                                                if(nameController.text == '' || phoneController.text == ''){
                                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter valid credentials')));
                                                  Navigator.of(context).pop();
                                                }else{
                                                  FirebaseFunctions.updateContact(name: nameController.text, phone: phoneController.text, docId: document.id);
                                                  Navigator.of(context).pop();
                                                }
                                              } catch (e) {
                                                print(e);
                                              }
                                            },
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                        );
                      },
                      icon: Icon(Icons.edit, color: Colors.grey,),
                    ),
                    SizedBox(width: 10,),
                    IconButton(
                        onPressed: (){
                          showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Delete'),
                              content: Text('Are you sure'),
                              actions: [
                                TextButton(
                                  onPressed: (){
                                    CircularProgressIndicator();
                                    FirebaseFunctions.deleteContact(docId: document.id);
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Yes'),
                                ),
                                TextButton(
                                  onPressed: (){
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('No'),
                                )
                              ],
                            )
                          );
                        },
                        icon: Icon(Icons.delete, color: Colors.grey,),
                    ),
                  ],
                ),
              );
              return ListTile(
                title: Text(data['name']),
                subtitle: Text(data['phone']),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          nameController.text = '';
          phoneController.text = '';
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context){
              return Center(
                child: Wrap(
                  children: [
                    Material(
                      borderRadius: BorderRadius.circular(10),
                      child: Column(
                        children: [
                          SizedBox(height: 10,),
                          Text(
                            'Create Contact',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                          SizedBox(height: 10,),
                          TextField(
                            keyboardType: TextInputType.text,
                            controller: nameController,
                            decoration: textFieldDecoration.copyWith(
                                hintText: 'Enter Name'
                            ),
                          ),
                          SizedBox(height: 10,),
                          TextField(
                            keyboardType: TextInputType.phone,
                            controller: phoneController,
                            decoration: textFieldDecoration.copyWith(
                                hintText: 'Enter Phone'
                            ),
                          ),
                          SizedBox(height: 10,),
                          RoundedButton(
                            colour: Colors.blueAccent,
                            title: 'Create',
                            onPressed: () async {
                              try {
                                CircularProgressIndicator();
                                if(nameController.text == '' || phoneController.text == ''){
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter valid credentials')));
                                  Navigator.of(context).pop();
                                }else{
                                  FirebaseFunctions.createContact(name: nameController.text, phone: phoneController.text);
                                  Navigator.of(context).pop();
                                }
                              } catch (e) {
                                print(e);
                              }
                            },
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}