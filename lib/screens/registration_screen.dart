import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/functions.dart';
import '../widgets/rounded_button.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;

  late TextEditingController emailController;
  late TextEditingController passwordController;

  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextField(
                controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: textFieldDecoration.copyWith(
                      hintText: 'Enter your email')),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                controller: passwordController,
                  obscureText: true,
                  decoration: textFieldDecoration.copyWith(
                      hintText: 'Enter your Password')),
              SizedBox(
                height: 24.0,
              ),
              RoundedButton(
                colour: Colors.blueAccent,
                title: 'Register',
                onPressed: () async {
                  try {
                    if(emailController.text != '' || passwordController.text != ''){
                      CircularProgressIndicator();
                      final newUser = await _auth.createUserWithEmailAndPassword(
                          email: emailController.text, password: passwordController.text);
                      if (newUser != null) {
                        final uid = newUser.user?.uid;
                        FirebaseFunctions.uploadUserDetails(email: newUser.user?.email ?? '' ,uid: uid ?? '');
                        Navigator.pushReplacementNamed(context, 'home_screen');
                      }
                    }else{
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter valid credentials')));
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter valid credentials')));
                    print(e);
                  }
                },
              ),
              SizedBox(
                height: 10,
              ),
              TextButton(
                  onPressed: (){
                    Navigator.of(context).pushReplacementNamed('login_screen');
                  },
                  child: Text(
                      'Already have an account? Sign In'
                  )
              ),
              TextButton(
                  onPressed: (){
                    FirebaseFunctions.signInWithGoogle().then((value){
                        if(value != null){
                          final uid = value.user?.uid;
                          FirebaseFunctions.uploadUserDetails(email: value.user?.email ?? '' ,uid: uid ?? '');
                          Navigator.of(context).pushReplacementNamed('home_screen');
                        }else{
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unable to sign in')));
                        }
                      }
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10)
                    ),
                    padding: EdgeInsets.all(6),
                    child: Row(
                      children: [
                        Image.asset('assets/google.png', height: 40, width: 40,),
                        Expanded(
                          child: Text(
                            'Sign In with Google',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade700
                            ),
                          ),
                        )
                      ],
                    ),
                  )
              ),
            ],
          ),
        ),
    );
  }
}