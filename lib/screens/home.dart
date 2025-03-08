import 'package:clipboard/constants/themes.dart';
import 'package:clipboard/controllers/group_controller.dart';
import 'package:clipboard/controllers/page_controller.dart';
import 'package:clipboard/widgets/bottom_navigation_bar.dart';
import 'package:clipboard/widgets/clipboard_widget.dart';
import 'package:clipboard/widgets/groups_widget.dart';
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
  @override
  void initState() {
    super.initState();
    // Fetch clips when the widget initializes
    Future.microtask(() => ref.read(clipProvider.notifier).fetchClips(ref));
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(pageControllerProvider);
    var width = MediaQuery.of(context).size.width * 0.75;
    if (width > 600) {
      width = 600;
    }

    return Scaffold(
        appBar: AppBar(
          title: Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 0), 
          child: Consumer(builder: (context, ref, child) {
            final selectedGroup = ref.watch(selectedGroupProvider);
            return Text(selectedGroup?.name ?? 'Clipboard',
                style:
                    const TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontWeight: FontWeight.bold,
                      fontSize: 24.0,
                    ));
          })),
          backgroundColor: Colors.transparent,
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (currentIndex == 0)
                GroupsContainer(width: width)
              else if (currentIndex == 1)
                ClipboardContainer(width: width)
              // else if (currentIndex == 2)
              //   const Text('Profile'),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: SizedBox(
          width: width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              FloatingActionButton(
                onPressed: () {
                  if (currentIndex == 0) {
                    ref.read(pageControllerProvider.notifier).setPage(1);
                  } else if (currentIndex == 1) {
                    ref.read(pageControllerProvider.notifier).setPage(0);
                  }
                },
                elevation: 10.0,
                foregroundColor: platinum,
                backgroundColor: oxfordBlue,
                splashColor: Colors.transparent,
                child: currentIndex == 0
                    ? const Icon(Icons.content_paste)
                    : const Icon(Icons.group),
              ),
              FloatingActionButton(
                onPressed: () {
                  ref.read(selectedGroupProvider.notifier).state = null;
                  ref.read(clipProvider.notifier).fetchClips(ref);
                  ref.read(pageControllerProvider.notifier).setPage(1);
                },
                elevation: 10.0,
                foregroundColor: platinum,
                backgroundColor: oxfordBlue,
                splashColor: Colors.transparent,
                child: const Icon(Icons.density_medium),
              ),
              
              FloatingActionButton(
                onPressed: () {
                  if (currentIndex == 0) {
                    ref.read(groupProvider.notifier).fetchGroups();
                  }
                  if (currentIndex == 1) {
                    ref.read(clipProvider.notifier).fetchClips(ref);
                  }
                },
                elevation: 10.0,
                foregroundColor: platinum,
                backgroundColor: oxfordBlue,
                splashColor: Colors.transparent,
                child: const Icon(Icons.refresh),
              ),
            ],
          ),
        ));
  }
}
