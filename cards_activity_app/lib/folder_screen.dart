import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'cards_screen.dart';

class FolderScreen extends StatefulWidget {
  @override
  _FolderScreenState createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  late Future<List<Map<String, dynamic>>> _folders;

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  void _loadFolders() {
    _folders = DatabaseHelper.instance.getFolders();
  }

  Future<String?> _getFirstCardImage(int folderId) async {
    final cards = await DatabaseHelper.instance.getCards(folderId);
    if (cards.isNotEmpty) {
      return cards[0]['imageUrl'];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Folders')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _folders,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final folders = snapshot.data!;
          return ListView.builder(
            itemCount: folders.length,
            itemBuilder: (context, index) {
              final folder = folders[index];
              return ListTile(
                title: Text(folder['name']),
                subtitle: FutureBuilder<List<Map<String, dynamic>>>(
                  future: DatabaseHelper.instance.getCards(folder['id']),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Text('Loading...');
                    }
                    final cardCount = snapshot.data!.length;
                    return Text('$cardCount cards');
                  },
                ),
                leading: FutureBuilder<String?>(
                  future: _getFirstCardImage(folder['id']),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      return Container(
                        width: 50,
                        height: 50,
                        child: Image.network(
                          snapshot.data!,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.image_not_supported);
                          },
                        ),
                      );
                    } else {
                      return Icon(Icons.image_not_supported);
                    }
                  },
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CardScreen(
                        folderId: folder['id'],
                        folderName: folder['name'],
                      ),
                    ),
                  ).then((_) {
                    setState(() {
                      _loadFolders();
                    });
                  });
                },
              );
            },
          );
        },
      ),
    );
  }
}
