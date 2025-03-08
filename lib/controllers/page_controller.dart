import 'package:flutter_riverpod/flutter_riverpod.dart';

final pageControllerProvider = StateNotifierProvider<PageController, int>((ref) {
  return PageController();
});

class PageController extends StateNotifier<int> {
  PageController() : super(1); // Start with Home (index 1) selected

  void setPage(int index) {
    state = index;
  }
}