import 'package:clipboard/constants/themes.dart';
import 'package:clipboard/controllers/group_controller.dart';
import 'package:clipboard/widgets/clipboard_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../controllers/clip_controller.dart';

class ClipboardContainer extends ConsumerWidget {
  final double width;
  final TextEditingController _controller = TextEditingController();


  ClipboardContainer({
    super.key,
    required this.width,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
        final clips = ref.watch(clipProvider);

    return Container(
              width: width,
              height: MediaQuery.of(context).size.height * 0.85,
              
              padding: const EdgeInsets.fromLTRB(10, 20, 0, 20),
                    margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.05),
              decoration: BoxDecoration(
                color: platinum,
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
                              style: const TextStyle(color: oxfordBlue),
                            ),
                            subtitle: Text(createdAt, style: const TextStyle(color: paynesGray)),
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
                                              color: paynesGray, 
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
                                              color: teal, 
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
                        await ref.read(clipProvider.notifier).addClip(value, ref);
                        _controller.clear();
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Add a new clip',
                      labelStyle: TextStyle(color: paynesGray),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: paynesGray),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: teal),
                      ),
                    ),
                  ),
                ],
              ),
            );
  }
}
