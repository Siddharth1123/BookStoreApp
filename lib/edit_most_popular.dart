import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_ecommerce_admin/add%20new%20slider.dart';
import 'package:fashion_ecommerce_admin/add_most_popular.dart';
import 'package:flutter/material.dart';

class edit_most_popular extends StatelessWidget {
  edit_most_popular({Key? key}) : super(key: key);

  final CollectionReference firestore =
  FirebaseFirestore.instance.collection('most_popular');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Most Popular Images'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var doc = snapshot.data!.docs[index];
                var imageLinks = List<String>.from(doc['image']);
                var name = doc['name'];
                var id = doc['id'];

                return ListTile(
                  trailing: CircleAvatar(radius: 25,
                    child: IconButton(onPressed: () async{
                      await firestore.doc(doc.id).delete();
                    }, icon: Icon(Icons.delete),),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),
                      ),
                      Text(
                        id,
                        style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),
                      ),
                    ],
                  ),
                  subtitle: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (var imageUrl in imageLinks)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.network(
                              imageUrl,
                              width: 150,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          }

          return Center(child: Text('No data available.'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => add_most_popular()));
        },
      ),
    );
  }
}
