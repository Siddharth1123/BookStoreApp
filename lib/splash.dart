import 'dart:async';

import 'package:fashion_ecommerce_admin/Login.dart';
import 'package:fashion_ecommerce_admin/admin_home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class splash extends StatefulWidget {
  const splash({super.key});

  @override
  State<splash> createState() => _splashState();
}

class _splashState extends State<splash> {
  final auth = FirebaseAuth.instance;
  Future<void> splashServices() async {
    Timer(Duration(seconds: 2), () {
      if(auth.currentUser!=null){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>admin_home()));
      }
      else{
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Login()));


      }
    });


  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    splashServices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 300,
          height: 300,
          child: Image.asset('assets/54963889.png'),
        ),
      ),
    );
  }
}
