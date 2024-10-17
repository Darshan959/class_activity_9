import 'package:flutter/material.dart';
import 'database_helper.dart';

class CardScreen extends StatefulWidget {
  final int folderId;
  final String folderName;

  CardScreen({required this.folderId, required this.folderName});

  @override
  _CardScreenState createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen> {
  late Future<List<Map<String, dynamic>>> _cards;
  final TextEditingController _cardNameController = TextEditingController();
  final List<String> validCardNames = [
    'Ace',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    'Jack',
    'Queen',
    'King'
  ];

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  void _loadCards() {
    _cards = DatabaseHelper.instance.getCards(widget.folderId);
  }

  Future<int> _getCardCount() async {
    final cards = await DatabaseHelper.instance.getCards(widget.folderId);
    return cards.length;
  }

  void _addCard() async {
    final cardCount = await _getCardCount();
    if (cardCount >= 6) {
      _showLimitDialog("This folder can only hold 6 cards.");
      return;
    }

    String cardName = _cardNameController.text.trim();
    if (!validCardNames.contains(cardName)) {
      _showLimitDialog(
          "Invalid card name. Please enter a valid card (Ace, 2, ..., King).");
      return;
    }

    await DatabaseHelper.instance
        .insertCardWithImageUrl(cardName, widget.folderName, widget.folderId);

    setState(() {
      _loadCards();
    });

    _cardNameController.clear();
  }

  String _getCardImageUrl(String cardName, String suit) {
    String formattedCardName = cardName.toLowerCase().replaceAll(' ', '-');
    String formattedSuit = suit.toLowerCase();
    return 'https://raw.githubusercontent.com/Darshan959/class_activity_9/main/cards_activity_app/img/$formattedCardName-of-$formattedSuit.png';
  }

  void _deleteCard(int cardId) async {
    final cardCount = await _getCardCount();

    if (cardCount <= 3) {
      _showLimitDialog("You need at least 3 cards in this folder.");
      return;
    }

    await DatabaseHelper.instance.deleteCard(cardId);

    setState(() {
      _loadCards();
    });
  }

  void _showLimitDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Notification"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.folderName)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _cardNameController,
              decoration: InputDecoration(
                labelText: 'Enter card name (Ace, 2, ..., King)',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _cards,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final cards = snapshot.data!;
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2),
                  itemCount: cards.length,
                  itemBuilder: (context, index) {
                    final card = cards[index];
                    return Card(
                      child: Column(
                        children: [
                          Image.network(
                            card['imageUrl'],
                            width: 100,
                            height: 100,
                          ),
                          Text(card['name']),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _deleteCard(card['id']),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _addCard,
      ),
    );
  }
}
