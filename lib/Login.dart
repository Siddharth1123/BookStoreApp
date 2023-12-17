import 'package:fashion_ecommerce_admin/admin_home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  final auth = FirebaseAuth.instance;

  final email = TextEditingController();
  final pass = TextEditingController();
  bool isLoading=false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
              child: Text(
            'Admin Login',
            style: TextStyle(fontSize: 35),
          )),
          SizedBox(
            width: 300,
            child: TextField(
              controller: email,
              decoration: InputDecoration(
                  hintText: 'Email',
                  border: OutlineInputBorder()),
            ),
          ),
          SizedBox(height: 10,),
          SizedBox(
            width: 300,
            child: TextField(
              controller: pass,
              decoration: InputDecoration(
                  hintText: 'Password',
                  border: OutlineInputBorder()),
            ),
          ),
          SizedBox(height: 15,),
          SizedBox(width:300,child: ElevatedButton(onPressed: () async{
            setState(() {
              isLoading=true;

            });
           await auth.signInWithEmailAndPassword(email: email.text.toString(), password: pass.text.toString()).then((value) {
             Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>admin_home()));
           }).onError((error, stackTrace){
             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error Occured!!')));
           });
           setState(() {
             isLoading
             =false;
           });

          }, child:isLoading?CircularProgressIndicator(): Text('Login')))
        ],
      ),
    );
  }
}
