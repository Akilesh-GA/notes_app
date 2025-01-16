import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud/services/firestore.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService firestoreService = FirestoreService();
  final TextEditingController textEditingController = TextEditingController();
  final Random random = Random();
  late List<Color> shuffledColors;

  @override
  void initState() {
    super.initState();
    shuffledColors = getColors();
  }

  List<Color> getColors() {
    List<Color> colors = [
      Colors.lightBlueAccent,
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.cyan,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
      Colors.yellow,
      Colors.lightBlue,
      Colors.lightGreen,
      Colors.deepOrange,
      Colors.deepPurpleAccent,
      Colors.lightGreenAccent,
      Colors.orangeAccent,
      Colors.purpleAccent,
      Colors.redAccent,
      Colors.tealAccent,
    ];
    colors.shuffle(random);
    return colors;
  }

  void openNoteBox({String? docID}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: textEditingController,
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (docID == null) {
                firestoreService.addNote(textEditingController.text);
              } else {
                firestoreService.updateNote(
                    docID, textEditingController.text);
              }
              textEditingController.clear();
              Navigator.pop(context);
            },
            child: Text("Add"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Notes",
          style: TextStyle(color: Colors.white), // Set the text color to white
        ),
        backgroundColor: Colors.black, // Set the AppBar color to black
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 80, // Lift the button upwards
            right: 10,
            child: FloatingActionButton(
              onPressed: openNoteBox,
              child: const Icon(Icons.add),
              backgroundColor: Colors.white, // Set the background color to white
              foregroundColor: Colors.black, // Set the icon color to black
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: firestoreService.getNotesStream(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List notesList = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: notesList.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot document = notesList[index];
                    String docID = document.id;
                    Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                    String noteText = data['note'];

                    return ListTile(
                      tileColor: Colors.black, // Change the tile background color to black
                      title: Container(
                        height: 45, // Reduce the height to make the box smaller
                        decoration: BoxDecoration(
                          color: shuffledColors[index % shuffledColors.length],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.all(10), // Adjust padding
                        child: Text(
                          noteText,
                          style: TextStyle(color: Colors.black), // Set text color to black
                        ),
                      ),
                      trailing: Wrap(
                        spacing: 8, // Add some space between icons
                        children: [
                          IconButton(
                            onPressed: () => openNoteBox(docID: docID),
                            icon: const Icon(Icons.settings),
                            color: Colors.white, // Set icon color to white
                          ),
                          IconButton(
                            onPressed: () => firestoreService.deleteNote(docID),
                            icon: const Icon(Icons.delete),
                            color: Colors.white, // Set icon color to white
                          ),
                        ],
                      ),
                    );
                  },
                );
              } else {
                return const Text(
                  "No Notes..",
                  style: TextStyle(color: Colors.white), // Set 'No Notes' text color to white
                );
              }
            },
          ),
          Positioned(
            bottom: 40, // Move the text slightly upwards
            right: 10,
            child: Text(
              "Powered by Firebase",
              style: TextStyle(color: Colors.grey), // Set the text color to grey
            ),
          ),
        ],
      ),
    );
  }
}
