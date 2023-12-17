import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:multi_image_picker_view/multi_image_picker_view.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class add_new_cat extends StatefulWidget {
  add_new_cat({Key? key});

  @override
  State<add_new_cat> createState() => _add_new_catState();
}

class _add_new_catState extends State<add_new_cat> {
  final firestore = FirebaseFirestore.instance.collection('categories');

  final name = TextEditingController();

  final controller = MultiImagePickerController(
      maxImages: 1,
      allowedImageTypes: ['png', 'jpg', 'jpeg'],
      withReadStream: true,
      withData: true,
      images: <ImageFile>[] // array of pre/default selected images
      );

  bool isLoading = false;

  Future<void> uploadImage(
      BuildContext context, String categoryName, List<ImageFile> images) async {
    try {
      List<ImageFile> imageList = images.toList();
      if (images.isNotEmpty) {
        ImageFile image = imageList.first;
        String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        String fileName = 'category_$timestamp.jpg';

        Directory tempDir = await getTemporaryDirectory();
        File tempFile = File('${tempDir.path}/$fileName');
        await tempFile.writeAsBytes(image.bytes!);

        FirebaseStorage storage = FirebaseStorage.instance;
        Reference storageReference =
            storage.ref().child('category_images/$fileName');
        UploadTask uploadTask = storageReference.putFile(tempFile);

        TaskSnapshot taskSnapshot = await uploadTask;
        String imageUrl = await taskSnapshot.ref.getDownloadURL();

        await firestore.doc(categoryName).set({
          'image': imageUrl,
          'name': categoryName,
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Data added successfully'),
          duration: Duration(seconds: 3),
        ));
        name.clear();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Please select an image'),
          duration: Duration(seconds: 3),
        ));
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $error'),
        duration: Duration(seconds: 3),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Category'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: InkWell(
                onTap: () async {
                  if(Platform.isAndroid){
                    final androidInfo = await DeviceInfoPlugin().androidInfo;
                    if(androidInfo.version.sdkInt<=32){
                      var status = await Permission.storage.request();
                      print(status);
                      if (status.isGranted) {
                        print("granted");
                        try {
                          // Display the grid view
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return MultiImagePickerView(
                                controller: controller,
                                padding: EdgeInsets.all(10),
                              );
                            },
                          );
                        } catch (e) {
                          print(e.toString());
                        }
                      } else if (status.isDenied) {
                        print('Denieddf');
                        openAppSettings();

                      } else {
                        print('Deniedd');
                      }
                    }
                    else{
                      var status = await Permission.photos.request();
                      print(status);
                      if (status.isGranted) {
                        print("granted");
                        try {
                          // Display the grid view
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return MultiImagePickerView(
                                controller: controller,
                                padding: EdgeInsets.all(10),
                              );
                            },
                          );
                        } catch (e) {
                          print(e.toString());
                        }
                      } else if (status.isDenied) {
                        print('Denieddf');
                        openAppSettings();

                      } else {
                        print('Deniedd');
                      }
                    }

                  }
                },
                child: Container(
                  height: 200,
                  width: 200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add,
                        size: 50,
                      ),
                      Text(
                        'Add Image',
                        style: TextStyle(fontSize: 25),
                      )
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 25,
            ),
            SizedBox(
              width: 300,
              child: TextField(
                controller: name,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Category Name",
                ),
              ),
            ),
            SizedBox(
              width: 300,
              child: ElevatedButton(
                onPressed: () async {
                  setState(() {
                    isLoading = true;
                  });

                  List<ImageFile> imageList = controller.images.toList();

                  await uploadImage(context, name.text.toString(), imageList);
                  setState(() {
                    isLoading = false;
                  });
                },
                child: isLoading ? CircularProgressIndicator() : Text('Add'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
