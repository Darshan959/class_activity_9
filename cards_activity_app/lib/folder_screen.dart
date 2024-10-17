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

  Future<int> _getCardCount(int folderId) async {
    final cards = await DatabaseHelper.instance.getCards(folderId);
    return cards.length;
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
      appBar: AppBar(title: Text('Card Organizer')),
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
              return FutureBuilder<int>(
                future: _getCardCount(folder['id']),
                builder: (context, cardCountSnapshot) {
                  if (!cardCountSnapshot.hasData) {
                    return ListTile(title: Text(folder['name']));
                  }
                  final cardCount = cardCountSnapshot.data!;
                  return FutureBuilder<String?>(
                    future: _getFirstCardImage(folder['id']),
                    builder: (context, imageSnapshot) {
                      return ListTile(
                        leading: imageSnapshot.hasData
                            ? Image.network(imageSnapshot.data!)
                            : Icon(Icons.folder),
                        title: Text(folder['name']),
                        subtitle: Text('$cardCount cards'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CardScreen(
                                  folderId: folder['id'],
                                  folderName: folder['name']),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
