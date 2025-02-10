import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';
import 'package:zenn_ai_hackathon_2501_frontend/widgets/lottie_animation.dart';

void main() {
  testWidgets('LottieAnimationウィジェットが正しく表示されること', (WidgetTester tester) async {
    const assetPath = 'assets/images/lottie_animation.json';

    await tester.pumpWidget(
      const MaterialApp(
        home: LottieAnimation(
          assetPath: assetPath,
        ),
      ),
    );

    // Lottieウィジェットが表示されていることを確認
    expect(find.byType(Lottie), findsOneWidget);

    // Lottie.assetが間接的に使われていることを確認 (composition != null で確認)
    final lottieWidget = tester.widget<Lottie>(find.byType(Lottie));
    expect(lottieWidget.composition, isNotNull);
  });

  testWidgets('widthとheightが正しく設定されること', (WidgetTester tester) async {
    const assetPath = 'assets/images/lottie_animation.json';
    const width = 200.0;
    const height = 100.0;

    await tester.pumpWidget(
      const MaterialApp(
        home: LottieAnimation(
          assetPath: assetPath,
          width: width,
          height: height,
        ),
      ),
    );

    // Lottieウィジェットのサイズが指定した値になっていることを確認
    final lottieWidget = tester.widget<Lottie>(find.byType(Lottie));
    expect(lottieWidget.width, width);
    expect(lottieWidget.height, height);
  });
}
