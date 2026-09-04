import 'package:flutter_test/flutter_test.dart';

import 'package:love_radar/main.dart';

void main() {
  testWidgets('exibe a tela inicial do LoveRadar', (tester) async {
    await tester.pumpWidget(const LoveRadarApp());

    expect(find.text('Amor sim. Golpe não.'), findsOneWidget);
    expect(find.text('Analisar com IA'), findsOneWidget);
  });
}
