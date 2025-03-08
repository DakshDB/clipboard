import 'package:clipboard/constants/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../controllers/clip_controller.dart';

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key});

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch clips when the widget initializes
    Future.microtask(() => ref.read(clipProvider.notifier).fetchClips());
  }

  @override
  Widget build(BuildContext context) {
    // Get clips from the provider
    final clips = ref.watch(clipProvider);
    
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
                      itemCount: clips.length,
                      itemBuilder: (context, index) {
                        final clip = clips[index];
                        final createdAt = DateFormat('MMM d, y H:mm')
                            .format(clip.createdAt.toDate());
                        
                        return GestureDetector(
                          onLongPress: () {
                            Clipboard.setData(ClipboardData(text: clip.content));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Copied to clipboard'),
                              ),
                            );
                          },
                          child: ListTile(
                            title: Text(
                              clip.content,
                              style: const TextStyle(color: Colors.black),
                            ),
                            subtitle: Text(createdAt),
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
                                            style: TextStyle(
                                              color: oxfordBlue, 
                                              fontWeight: FontWeight.w400
                                            )
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            Navigator.of(context).pop();
                                            await ref.read(clipProvider.notifier)
                                                .deleteClip(clip.id);
                                          },
                                          child: const Text('Yes',
                                            style: TextStyle(
                                              color: oxfordBlue, 
                                              fontWeight: FontWeight.w400
                                            )
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  TextField(
                    controller: _controller,
                    style: const TextStyle(color: oxfordBlue),
                    onSubmitted: (value) async {
                      if (value.isNotEmpty) {
                        await ref.read(clipProvider.notifier).addClip(value);
                        _controller.clear();
                      }
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
          ref.read(clipProvider.notifier).fetchClips();
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
