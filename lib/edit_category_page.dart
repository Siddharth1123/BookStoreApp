import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_ecommerce_admin/add_new_cat.dart';
import 'package:flutter/material.dart';

class edit_category extends StatelessWidget {
  edit_category({Key? key});

  final firestore = FirebaseFirestore.instance.collection('categories');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StreamBuilder(
              stream: firestore.snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Some Error'),
                  );
                }

                return Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CircleAvatar(
                              radius: 35,
                              backgroundImage: NetworkImage(
                                  snapshot.data!.docs[index]['image']),
                            ),
                            Text(
                              snapshot.data!.docs[index]['name'],
                              style: TextStyle(fontSize: 25),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    _showEditOptionsDialog(
                                        context, snapshot.data!.docs[index]);
                                  },
                                  icon: Icon(Icons.edit),
                                ),
                                IconButton(
                                  onPressed: () {
                                    firestore
                                        .doc(snapshot.data!.docs[index]['name'])
                                        .delete();
                                  },
                                  icon: Icon(Icons.delete),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => add_new_cat()),
                );
              },
              child: Text(
                '+ Add New Category',
                style: TextStyle(fontSize: 20),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showEditOptionsDialog(
      BuildContext context, QueryDocumentSnapshot categoryData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Edit Name'),
                onTap: () {
                  Navigator.pop(context); // Close the dialog
                  _showEditNameDialog(context, categoryData);
                },
              ),
              // ListTile(
              //   title: Text('Edit Image'),
              //   onTap: () {
              //     Navigator.pop(context); // Close the dialog
              //     _showEditImageDialog(context, categoryData);
              //   },
              // ),
            ],
          ),
        );
      },
    );
  }

  void _showEditNameDialog(
      BuildContext context, QueryDocumentSnapshot categoryData) {
    TextEditingController newNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Name'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: newNameController,
                decoration: InputDecoration(labelText: 'New Name'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                  _updateNameInFirestore(
                      context, categoryData, newNameController.text);
                },
                child: Text('Update'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditImageDialog(
      BuildContext context, QueryDocumentSnapshot categoryData) {
    // Implement the logic to edit the image
    // You can use a file picker or any other widget to get the new image from the user
    // Once the image is updated, you can update it in Firestore
    print('Editing Image: ${categoryData['image']}');
  }

  void _updateNameInFirestore(BuildContext context,
      QueryDocumentSnapshot categoryData, String newName) {
    // Update the document ID (name) and 'name' field in Firestore
    firestore.doc(categoryData['name']).get().then((DocumentSnapshot doc) {
      // Get the data from the old document
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      // Add the new document with the new name and updated 'name' field
      firestore.doc(newName).set(data).then((_) {
        print('New document added successfully');

        // Update the 'name' field in the new document
        firestore.doc(newName).update({'name': newName}).then((_) {
          print('Name field updated successfully');

          // Delete the old document
          firestore.doc(categoryData['name']).delete().then((_) {
            print('Old document deleted successfully');
          }).catchError((error) {
            print('Failed to delete old document: $error');
          });
        }).catchError((error) {
          print('Failed to update name field: $error');
        });
      }).catchError((error) {
        print('Failed to add new document: $error');
        // Handle the error as needed
      });
    }).catchError((error) {
      print('Failed to get old document: $error');
      // Handle the error as needed
    });
  }
}
