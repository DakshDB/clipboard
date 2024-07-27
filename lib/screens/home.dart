import 'package:clipboard/constants/themes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map<String, Map<String, dynamic>> _clips = {}; // Change the value type to Map
  final Map<String, Map<String, dynamic>> _newClips = {}; // Change the type to Map
  final List<String> _deletedClips = [];

  final TextEditingController _controller = TextEditingController();

  Future<void> fetchClips() async {
    _clips.clear();
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('clips')
        .where('deleted_at', isNull: true)
        .orderBy('created_at', descending: true)
        .get();
    for (final doc in querySnapshot.docs) {
      _clips[doc.id] = doc.data() as Map<String, dynamic>; // Fetch the entire document data
    }

    // Sort the clips by created_at field
    _clips = Map<String, Map<String, dynamic>>.fromEntries(
      _clips.entries.toList()
        ..sort((a, b) => (b.value['created_at'] as Timestamp).compareTo(a.value['created_at'] as Timestamp)),
    );
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
                        return GestureDetector(
                          onLongPress: () {
                            Clipboard.setData(ClipboardData(text: clipData['clip']));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Copied to clipboard'),
                              ),
                            );
                          },
                          child: ListTile(
                              title: Text(
                                clipData['clip'],
                                style: const TextStyle(color: Colors.black),
                              ),
                              subtitle: Text(createdAt),
                              // Display the timestamp or default message
                              trailing: IconButton(
                                color: paynesGray,
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                  // Open the dialog to confirm deletion
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text('Delete this clip?'),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('No',
                                                style: TextStyle(color: oxfordBlue, fontWeight: FontWeight.w400)),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              setState(() {
                                                _deletedClips.add(id);
                                                _clips.remove(id);
                                              });
                                              Navigator.of(context).pop();
                                              await saveClips();
                                            },
                                            child: const Text('Yes',
                                                style: TextStyle(color: oxfordBlue, fontWeight: FontWeight.w400)),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              )),
                        );
                      },
                    ),
                  ),
                  TextField(
                    controller: _controller,
                    style: const TextStyle(color: oxfordBlue),
                    onSubmitted: (value) async {
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
                      await saveClips();
                    },
                    decoration: const InputDecoration(
                      labelText: 'Add a new clip',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          fetchClips().then((_) => setState(() {}));
        },
        elevation: 10.0,
        foregroundColor: platinum,
        backgroundColor: oxfordBlue,
        splashColor: Colors.transparent,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
