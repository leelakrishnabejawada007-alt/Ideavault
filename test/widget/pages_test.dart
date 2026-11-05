import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idea_vault/app.dart';
import 'package:idea_vault/core/core.dart';
import 'package:idea_vault/data/api.dart';
import 'package:idea_vault/data/repository.dart';
import 'package:idea_vault/features/explore_page.dart';
import 'package:idea_vault/features/submit_idea_page.dart';
import 'package:provider/provider.dart';

IdeaProvider make() =>
    IdeaProvider(IdeaRepository(MockIdeaApi(delay: Duration.zero)));

Widget host(IdeaProvider p, Widget child) => ChangeNotifierProvider.value(
    value: p, child: MaterialApp(theme: buildTheme(), home: Scaffold(body: child)));

void big(WidgetTester t) {
  t.view.physicalSize = const Size(1400, 1000);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
}

void main() {
  testWidgets('landing page shows hero headline', (t) async {
    big(t);
    final p = make();
    await t.runAsync(p.load);
    await t.pumpWidget(IdeaVaultApp(provider: p));
    await t.pump(const Duration(seconds: 2));
    expect(find.text('Every Great Innovation Starts With an Idea.'), findsOneWidget);
    expect(find.text('Explore Ideas'), findsOneWidget);
  });

  testWidgets('explore live search filters cards', (t) async {
    big(t);
    final p = make();
    await t.runAsync(p.load);
    await t.pumpWidget(host(p, const ExplorePage()));
    await t.pump(const Duration(milliseconds: 300));
    await t.enterText(find.byType(TextField), 'crop');
    await t.pump(const Duration(milliseconds: 300));
    expect(find.byType(IdeaCard), findsOneWidget);
  });

  testWidgets('submit form validates required fields', (t) async {
    big(t);
    final p = make();
    await t.pumpWidget(host(p, const SubmitIdeaPage()));
    await t.ensureVisible(find.text('Submit Idea'));
    await t.tap(find.text('Submit Idea'));
    await t.pump(const Duration(milliseconds: 300));
    expect(find.text('Idea title is required'), findsOneWidget);
    expect(find.text('Please choose a category'), findsOneWidget);
    expect(p.ideas.length, 0);
  });
}
