import 'package:fashion_ecommerce_admin/Login.dart';
import 'package:fashion_ecommerce_admin/add_new_product.dart';
import 'package:fashion_ecommerce_admin/edit_category_page.dart';
import 'package:fashion_ecommerce_admin/edit_most_popular.dart';
import 'package:fashion_ecommerce_admin/edit_slider_page.dart';
import 'package:fashion_ecommerce_admin/view%20all%20product.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class admin_home extends StatelessWidget {
   admin_home({super.key});

  final auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Home'),
        actions: [IconButton(onPressed: ()async{
          await auth.signOut().then((value) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Login()));
          });

        }, icon: Icon(Icons.logout))],
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            child: Image.asset('assets/1.jpg'),

          ),
          Text('Book Management',style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),),
          Center(
              child: SizedBox(
                  width: 300,
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => edit_category()));
                      },
                      child: Text('Edit categories')))),
          SizedBox(
              width: 300,
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => edit_slider()));
                  },
                  child: Text('Edit slider'))),
          SizedBox(
              width: 300,
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => edit_most_popular()));
                  },
                  child: Text('Edit most popular'))),
          SizedBox(
              width: 300,
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>ViewAllProduct()));

                  }, child: Text('View all product'))),
          SizedBox(
              width: 300,
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => add_new_product()));
                  },
                  child: Text('Add new product'))),
          SizedBox(
              width: 300,
              child:
                  ElevatedButton(onPressed: () {}, child: Text('View order'))),
          SizedBox(
              width: 300,
              child:
                  ElevatedButton(onPressed: () {}, child: Text('View stats'))),
        ],
      ),
    );
  }
}
