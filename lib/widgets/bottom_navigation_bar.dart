import 'package:clipboard/controllers/page_controller.dart';
import 'package:flutter/material.dart';
import 'package:clipboard/constants/themes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomBottomNavigationBar extends ConsumerWidget {
  const CustomBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(pageControllerProvider);
    
    return BottomAppBar(
      color: oxfordBlue,
      child: Container(
        height: 60.0,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () => ref.read(pageControllerProvider.notifier).setPage(0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.group, color: currentIndex == 0 ? teal : platinum),
                  Text('Groups',
                    style: TextStyle(
                      color: currentIndex == 0 ? teal : platinum,
                      fontSize: 12.0,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => ref.read(pageControllerProvider.notifier).setPage(1),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.home, color: currentIndex == 1 ? teal : platinum),
                  Text('Home',
                    style: TextStyle(
                      color: currentIndex == 1 ? teal : platinum,
                      fontSize: 12.0,
                    ),
                  ),
                ],
              ),
            ),
            // GestureDetector(
            //   onTap: () => ref.read(pageControllerProvider.notifier).setPage(2),
            //   child: Column(
            //     mainAxisSize: MainAxisSize.min,
            //     children: [
            //       Icon(Icons.person, color: currentIndex == 2 ? teal : platinum),
            //       Text('Profile',
            //         style: TextStyle(
            //           color: currentIndex == 2 ? teal : platinum,
            //           fontSize: 12.0,
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}