import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crud/utils/functions.dart';
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../widgets/rounded_button.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

final _auth = FirebaseAuth.instance;

class _LoginScreenState extends State<LoginScreen> {

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
                    hintText: 'Enter your email',
                  )),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                controller: passwordController,
                  keyboardType: TextInputType.text,
                  obscureText: true,
                  decoration: textFieldDecoration.copyWith(
                      hintText: 'Enter your password')),
              SizedBox(
                height: 24.0,
              ),
              RoundedButton(
                  colour: Colors.lightBlueAccent,
                  title: 'Log In',
                  onPressed: () async {
                    try {
                      if(emailController.text != '' || passwordController.text != ''){
                        await _auth.signInWithEmailAndPassword(
                            email: emailController.text , password: passwordController.text );
                        Navigator.pushReplacementNamed(context, 'home_screen');
                      }else{
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter valid credentials')));
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter valid credentials')));
                      print(e);
                    }
                  }),
              TextButton(
                onPressed: (){
                  Navigator.of(context).pushReplacementNamed('registration_screen');
                },
                child: Text(
                  'Don\'t have an account? Sign Up'
                )
              ),
              TextButton(
                  onPressed: (){
                    FirebaseFunctions.signInWithGoogle().then((value){
                      if(value != null){
                        var docRef = FirebaseFirestore.instance.collection('users').doc(value.user?.uid);
                        docRef.get().then((doc){
                        if (!doc.exists) {
                          final uid = value.user?.uid;
                          FirebaseFunctions.uploadUserDetails(email: value.user?.email ?? '' ,uid: uid ?? '');
                        }
                        Navigator.of(context).pushReplacementNamed('home_screen');
                      });
                      }else{
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unable to sign in')));
                      }
                    });
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