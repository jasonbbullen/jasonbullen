import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ActivePage { selector, game }

class NavigatorStateNotifier extends StateNotifier<ActivePage> {
  NavigatorStateNotifier() : super(ActivePage.selector);

  void setActivePage(ActivePage ap) {
    state = ap;
  }
}

final navigatorStateProvider =
    StateNotifierProvider<NavigatorStateNotifier, ActivePage>((ref) {
  return NavigatorStateNotifier();
});
