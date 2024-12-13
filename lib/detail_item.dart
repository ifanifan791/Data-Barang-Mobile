import 'package:flutter/material.dart';
import 'package:part1/model/barang.dart';
import 'package:part1/db/db_helper.dart';
import 'dart:io';
import 'package:part1/dashboard_screen.dart';
import 'package:part1/model/history_stok.dart';

class ItemDetailPage extends StatefulWidget {
  final int itemId;

  ItemDetailPage({required this.itemId});

  @override
  _ItemDetailPageState createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  late Future<Barang?> _item;

  @override
  void initState() {
    super.initState();
    _item = DatabaseHelper().getItemById(widget.itemId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Detail Item', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Hapus Item'),
                  content: Text('Apakah Anda yakin ingin menghapus item ini?'),
                  actions: [
                    TextButton(
                      child: Text('Batal'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    TextButton(
                      child: Text('Hapus'),
                      onPressed: () async {
                        await DatabaseHelper().deleteItem(widget.itemId);
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ItemListPage()),
                          (route) => false,
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<Barang?>(
        future: _item,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final item = snapshot.data;

          if (item == null) {
            return Center(child: Text('Item tidak ditemukan'));
          }

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Menampilkan gambar item
                  Center(
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                        image: DecorationImage(
                          image: FileImage(File(item.imagePath)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Menampilkan nama item
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            item.description,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Informasi tambahan
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('Kategori: ',
                                  style: TextStyle(fontSize: 16)),
                              Text('${item.category}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  )),
                            ],
                          ),
                          Divider(),
                          Row(
                            children: [
                              Text('Harga: ', style: TextStyle(fontSize: 16)),
                              Text(
                                'Rp ${item.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Divider(),
                          Row(
                            children: [
                              Text('Stok: ', style: TextStyle(fontSize: 16)),
                              Text(
                                '${item.stock}',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: 10),
                              IconButton(
                                icon: Icon(Icons.remove_circle_outline,
                                    color: Colors.redAccent),
                                onPressed: () async {
                                  if (item.stock > 0) {
                                    await DatabaseHelper().updateStock(
                                        widget.itemId, item.stock - 1);
                                    await DatabaseHelper().addHistoryStok(
                                      HistoryStok(
                                        itemId: widget.itemId,
                                        jenis: 'Keluar',
                                        jumlah: 1,
                                        tanggal: DateTime.now(),
                                      ),
                                    );
                                    setState(() {
                                      _item = DatabaseHelper()
                                          .getItemById(widget.itemId);
                                    });
                                  }
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.add_circle_outline,
                                    color: Colors.green),
                                onPressed: () async {
                                  await DatabaseHelper().updateStock(
                                      widget.itemId, item.stock + 1);
                                  await DatabaseHelper().addHistoryStok(
                                    HistoryStok(
                                      itemId: widget.itemId,
                                      jenis: 'Masuk',
                                      jumlah: 1,
                                      tanggal: DateTime.now(),
                                    ),
                                  );
                                  setState(() {
                                    _item = DatabaseHelper()
                                        .getItemById(widget.itemId);
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Menampilkan history stok
                  Text(
                    'Riwayat Stok',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  FutureBuilder<List<HistoryStok>>(
                    future:
                        DatabaseHelper().getHistoryStokByItemId(widget.itemId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      final historyStok = snapshot.data;

                      if (historyStok == null || historyStok.isEmpty) {
                        return Center(child: Text('Tidak ada riwayat'));
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: historyStok.length,
                        itemBuilder: (context, index) {
                          return Card(
                            elevation: 1,
                            child: ListTile(
                              leading: Icon(
                                historyStok[index].jenis == 'Masuk'
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                color: historyStok[index].jenis == 'Masuk'
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              title: Text(
                                historyStok[index].jenis,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                'Jumlah: ${historyStok[index].jumlah} - Tanggal: ${historyStok[index].tanggal.toLocal().toString().split(' ')[0]}',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
