import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'firebase_options.dart';

const Color paynesGray = Color(0xFF5F6978);
const Color oxfordBlue = Color(0xFF0B192F);
const Color teal = Color(0xFF64FFDA);
const Color platinum = Color(0xFFDEE0E3);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: firebaseOptions);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clipboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: teal,
        scaffoldBackgroundColor: oxfordBlue,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: platinum),
        ),
      ),
      home: const MyHomePage(title: 'Clipboard'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map<String, Map<String, dynamic>> _clips = {}; // Change the value type to Map
  final Map<String, Map<String, dynamic>> _newClips = {}; // Change the type to Map
  final List<String> _deletedClips = [];
  bool _isSaving = false;

  final TextEditingController _controller = TextEditingController();

  Future<void> fetchClips() async {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('clips')
        .where('deleted_at', isNull: true)
        .orderBy('created_at', descending: true)
        .get();
    for (final doc in querySnapshot.docs) {
      _clips[doc.id] = doc.data() as Map<String, dynamic>; // Fetch the entire document data
    }
  }

  Future<void> saveClips() async {
    final CollectionReference clipsCollection = FirebaseFirestore.instance.collection('clips');
    for (final clip in _newClips.entries) {
      await clipsCollection.add(clip.value);
    }
    for (final id in _deletedClips) {
      await clipsCollection.doc(id).update({'deleted_at': Timestamp.now()});
    }
    _newClips.clear();
    _deletedClips.clear();
  }

  @override
  void initState() {
    super.initState();
    fetchClips().then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width * 0.75;
    if (width > 600) {
      width = 600;
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: width,
              height: MediaQuery.of(context).size.height * 0.8,
              // 80% of screen height
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Expanded(
                    child: ListView.builder(
                      itemCount: _clips.length,
                      itemBuilder: (context, index) {
                        final id = _clips.keys.elementAt(index);
                        final clipData = _clips[id]!;
                        String createdAt = 'N/A'; // Default message
                        if (clipData['created_at'] != null) {
                          createdAt = DateFormat('MMM d, y H:mm').format(clipData['created_at'].toDate());
                        }
                        return ListTile(
                          title: Text(
                            clipData['clip'],
                            style: const TextStyle(color: Colors.black),
                          ),
                          subtitle: Text(createdAt),
                          // Display the timestamp or default message
                          trailing: IconButton(
                            color: paynesGray,
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                _deletedClips.add(id);
                                _clips.remove(id);
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  TextField(
                    controller: _controller,
                    style: const TextStyle(color: oxfordBlue),
                    onSubmitted: (value) {
                      setState(() {
                        final newClip = {
                          'clip': value,
                          'created_at': Timestamp.now(),
                          'deleted_at': null
                        }; // Add the created_at field
                        var uuid = const Uuid();
                        String randomId = uuid.v4();
                        _newClips[randomId] = newClip;
                        _clips = {randomId: newClip, ..._clips};
                      });
                      _controller.clear();
                    },
                    decoration: const InputDecoration(
                      labelText: 'Add a new clip',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  _isSaving = true;
                });
                await saveClips();
                setState(() {
                  _isSaving = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: teal,
              ),
              child: _isSaving
                  ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(oxfordBlue),
                    )
                  : const Text('Save', style: TextStyle(color: oxfordBlue)),
            ),
          ],
        ),
      ),
    );
  }
}
