import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';



class edit_product extends StatefulWidget {


  @override
  State<edit_product> createState() => _edit_productState();
}

class _edit_productState extends State<edit_product> {
  late CollectionReference firestoreCollection;

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product List'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreCollection.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error.toString()}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No data available.'));
          }

          return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                List sizes = snapshot.data!.docs[index]['size'];
                String size = sizes.join('  ,  ');
                return Column(
                  children: [
                    Container(
                      height: 300,
                      width: 200,
                      color: Colors.red,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(snapshot.data!.docs[index]['id'],style: TextStyle(fontSize: 20),),
                          Text(snapshot.data!.docs[index]['name'],style: TextStyle(fontSize: 20),),
                          Text(snapshot.data!.docs[index]['price'],style: TextStyle(fontSize: 20),),
                        ],
                      ),
                    ),
                    Text('Sizes - ' + size,style: TextStyle(fontSize: 20),),
                    Text(snapshot.data!.docs[index]['description'],style: TextStyle(fontSize: 18),),
                    IconButton(onPressed: (){
                      firestoreCollection.doc(snapshot.data!.docs[index]['id']).delete();
                    }, icon: Icon(Icons.delete))
                  ],
                );
              });
        },
      ),

    );
  }
}
