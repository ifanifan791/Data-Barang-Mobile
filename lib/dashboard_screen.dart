import 'package:flutter/material.dart';
import 'package:part1/model/barang.dart';
import 'package:part1/db/db_helper.dart';
import 'dart:io';
import 'package:part1/add_item.dart';
import 'package:part1/detail_item.dart';
import 'package:part1/add_category.dart';
import 'package:part1/all_histori.dart';

class ItemListPage extends StatefulWidget {
  @override
  _ItemListPageState createState() => _ItemListPageState();
}

class _ItemListPageState extends State<ItemListPage> {
  late Future<List<Barang>> _items;

  @override
  void initState() {
    super.initState();
    _items = DatabaseHelper().getItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Barang'),
      ),
      body: FutureBuilder<List<Barang>>(
        future: _items,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final items = snapshot.data ?? [];
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                leading:
                    Image.file(File(item.imagePath), width: 50, height: 50),
                title: Text(item.name),
                subtitle: Text('${item.category} - Rp ${item.price}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ItemDetailPage(itemId: item.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          // Tombol History
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        HistoryPage()), // Navigasi ke HistoryPage
              );
            },
            child: Icon(Icons.history),
            heroTag: null,
          ),
          SizedBox(height: 10), // Spasi antara tombol
          // Tombol Kategori
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddCategoryPage()),
              );
            },
            child: Icon(Icons.category),
            heroTag: null,
          ),
          SizedBox(height: 10), // Spasi antara tombol
          // Tombol Add Item
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddItemPage()),
              );
            },
            child: Icon(Icons.add),
            heroTag: null,
          ),
        ],
      ),
    );
  }
}
