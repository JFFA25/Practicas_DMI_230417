import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:toktik/presentation/providers/discover_provider.dart';
import 'package:toktik/presentation/providers/likes_provider.dart';
import 'package:toktik/presentation/providers/theme_provider.dart';
import 'package:toktik/presentation/screens/discover/discover_screen.dart';
import 'package:toktik/presentation/widgets/shared/video_scrollable_view.dart';

void main() {
  testWidgets('Discover screen shows a loader before videos are loaded', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => DiscoverProvider()),
          ChangeNotifierProvider(create: (_) => LikesProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: const MaterialApp(home: DiscoverScreen()),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets(
    'Video feed pages vertically and supports desktop drag devices',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [ChangeNotifierProvider(create: (_) => LikesProvider())],
          child: MaterialApp(
            home: VideoScrollableView(
              videos: const [],
              loadComments: (_) async => const [],
            ),
          ),
        ),
      );

      final pageView = tester.widget<PageView>(find.byType(PageView));
      expect(pageView.scrollDirection, Axis.vertical);
      expect(pageView.childrenDelegate.estimatedChildCount, 0);

      final behavior = ScrollConfiguration.of(
        tester.element(find.byType(PageView)),
      );
      expect(
        behavior.dragDevices,
        containsAll({
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.trackpad,
          PointerDeviceKind.stylus,
        }),
      );
    },
  );
}
