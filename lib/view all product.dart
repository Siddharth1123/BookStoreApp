import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewAllProduct extends StatefulWidget {
  const ViewAllProduct({Key? key}) : super(key: key);

  @override
  State<ViewAllProduct> createState() => _ViewAllProductState();
}

class _ViewAllProductState extends State<ViewAllProduct> {
  late TextEditingController _searchController;
  List<QueryDocumentSnapshot> allProducts = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Products'),
        actions: [
          IconButton(
            onPressed: () {
              _searchController.clear();
              updateFilteredProducts('');
            },
            icon: Icon(Icons.clear),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by product name or ID',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                updateFilteredProducts(value);
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('products').snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No products available.'));
                }

                allProducts = snapshot.data!.docs;

                // Use the filtered products to populate the UI
                List<QueryDocumentSnapshot> filteredProducts =
                    getFilteredProducts(_searchController.text);

                return ListView.builder(
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    var product =
                        filteredProducts[index].data() as Map<String, dynamic>;
                    var name = product['name'];
                    var id = product['id'];
                    var images = List<String>.from(product['image']);
                    var price = product['price'];
                    var cat = product['category'];
                    List size = product['size'];

                    return Card(
                      elevation: 10,
                      child: ListTile(
                        trailing: IconButton(
                          onPressed: () async {
                            // Handle delete action
                            await deleteProduct(filteredProducts[index].id);
                            // Refresh the UI after deletion
                            updateFilteredProducts(_searchController.text);
                          },
                          icon: Icon(Icons.delete),
                        ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('ID: $id',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Text('Name: $name',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Price: $price', style:
                                TextStyle(fontWeight: FontWeight.bold)),
                                Text('Category: $cat', style:
                                    TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Center(child: Text('Sizes: ${size.join(', ')}' ,style:
                                TextStyle(fontWeight: FontWeight.bold))),
                          ],
                        ),
                        subtitle: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: BouncingScrollPhysics(),
                          child: Row(
                            children: images.map((imageUrl) {
                              return Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Image.network(
                                  imageUrl,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void updateFilteredProducts(String searchText) {
    setState(() {
      // Trigger the rebuild with the filtered products
    });
  }

  List<QueryDocumentSnapshot> getFilteredProducts(String searchText) {
    // Filter the products based on the search text
    return allProducts.where((doc) {
      var productName =
          (doc.data() as Map<String, dynamic>)['name'].toString().toLowerCase();
      var productId =
          (doc.data() as Map<String, dynamic>)['id'].toString().toLowerCase();
      return productName.contains(searchText.toLowerCase()) ||
          productId.contains(searchText.toLowerCase());
    }).toList();
  }

  Future<void> deleteProduct(String documentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(documentId)
          .delete();
    } catch (e) {
      print('Error deleting product: $e');
      // Handle the error as needed
    }
  }
}
