import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:multi_image_picker_view/multi_image_picker_view.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class add_most_popular extends StatefulWidget {
  const add_most_popular({super.key});

  @override
  State<add_most_popular> createState() => _add_most_popularState();
}

class _add_most_popularState extends State<add_most_popular> {
  final firestore = FirebaseFirestore.instance.collection('most_popular');
  final name = TextEditingController();
  final price = TextEditingController();
  final size = TextEditingController();
  final desc = TextEditingController();
  final id = TextEditingController();
  final controller = MultiImagePickerController(
      maxImages: 15,
      allowedImageTypes: ['png', 'jpg', 'jpeg'],
      withReadStream: true,
      withData: true,
      images: <ImageFile>[] // array of pre/default selected images
  );
  List imageLinks = [];
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  Future<void> uploadImages(Iterable<ImageFile> images) async {
    try {

      List<String> selectedImageUrls = [];
      for (ImageFile image in images) {
        if (image.bytes != null) {
          // Generate a unique filename based on the current timestamp
          String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
          String fileName = 'image_$timestamp.jpg';

          // Write the byte data to a temporary file
          Directory tempDir = await getTemporaryDirectory();
          File tempFile = File('${tempDir.path}/$fileName');
          await tempFile.writeAsBytes(image.bytes!);

          // Upload the image to Firebase Storage
          final Reference storageReference =
          FirebaseStorage.instance.ref().child(
            'most_popular_image/${id.text.toString()}/$fileName',
          );

          final UploadTask uploadTask = storageReference.putFile(tempFile);

          // Wait for the upload to complete
          await uploadTask.then((TaskSnapshot snapshot) async {
            final imageUrl = await snapshot.ref.getDownloadURL();
            selectedImageUrls.add(imageUrl);
          }).catchError((onError) {
            print('Error uploading image: $onError');
          });
        } else {
          print('Empty byres');
        }
      }
      // Now you have the list of image URLs in selectedImageUrls
      setState(() {
        imageLinks = selectedImageUrls;
      });
    } catch (e) {
      print('Error in uploadImages: $e');

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
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
                          'Add Images',
                          style: TextStyle(fontSize: 25),
                        )
                      ],
                    ),
                  ),
                )),
            Padding(
              padding: const EdgeInsets.all(10),
              child: SizedBox(
                  width: 380,
                  child: TextField(
                    controller: name,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), hintText: 'Name'),
                  )),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: SizedBox(
                  width: 380,
                  child: TextField(
                    controller: price,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), hintText: 'Price'),
                  )),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: SizedBox(
                  width: 380,
                  child: TextField(
                    controller: size,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), hintText: 'Size'),
                  )),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: SizedBox(
                  width: 380,
                  child: TextField(
                    controller: desc,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), hintText: 'Description'),
                  )),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: SizedBox(
                  width: 380,
                  child: TextField(
                    controller: id,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), hintText: 'Barcode No.'),
                  )),
            ),
            SizedBox(
                width: 300,
                child: ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        isLoading=true;
                      });
                      List sizeList = size.text.toString().split(',');
                      await uploadImages(controller.images);


                      await firestore.doc(id.text.toString()).set({
                      'name': name.text.toString(),
                      'id': id.text.toString(),
                      'description': desc.text.toString(),
                      'image': FieldValue.arrayUnion(imageLinks),
                      'size': sizeList,
                      'price': price.text.toString()
                      }).then((value) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Data added successfully'),
                          duration: Duration(seconds: 3),
                        ));
                        name.clear();
                        price.clear();
                        size.clear();
                        desc.clear();
                        id.clear();
                        Navigator.pop(context);
                      });
                      setState(() {
                        isLoading=false;
                      });
                    },
                    child: isLoading?CircularProgressIndicator():Text('Add')))
          ],
        ),
      ),
    );
  }
}
