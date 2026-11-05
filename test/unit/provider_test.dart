import 'package:flutter_test/flutter_test.dart';
import 'package:idea_vault/data/api.dart';
import 'package:idea_vault/data/models.dart';
import 'package:idea_vault/data/repository.dart';
import 'package:idea_vault/providers/idea_provider.dart';

IdeaProvider make({bool fail = false}) =>
    IdeaProvider(IdeaRepository(MockIdeaApi(delay: Duration.zero, fail: fail)));

void main() {
  test('loads at least 10 sample ideas', () async {
    final p = make();
    await p.load();
    expect(p.ideas.length, greaterThanOrEqualTo(10));
    expect(p.error, isNull);
  });

  test('search and category filtering', () async {
    final p = make();
    await p.load();
    p.setQuery('crop');
    expect(p.explore.length, 1);
    p.setQuery('');
    p.setCategory('Healthcare');
    expect(p.explore.every((i) => i.category == 'Healthcare'), isTrue);
  });

  test('bookmark toggles', () async {
    final p = make();
    await p.load();
    p.toggleSave('1');
    expect(p.saved.contains('1'), isTrue);
    p.toggleSave('1');
    expect(p.saved.contains('1'), isFalse);
  });

  test('vote only counts once', () async {
    final p = make();
    await p.load();
    final before = p.byId('2')!.votes;
    expect(await p.vote('2'), isTrue);
    expect(await p.vote('2'), isFalse);
    expect(p.byId('2')!.votes, before + 1);
  });

  test('comments and submissions', () async {
    final p = make();
    await p.load();
    await p.addComment('1', 'Nice!');
    expect(p.byId('1')!.comments.first.text, 'Nice!');
    final n = p.ideas.length;
    await p.submit(Idea(
        id: '', title: 'T', problem: 'p', solution: 's', description: 'd',
        category: 'Education', author: 'Me', impact: 'i', stage: 'Concept', tags: ['Dart']));
    expect(p.ideas.length, n + 1);
  });

  test('API failure sets error state', () async {
    final p = make(fail: true);
    await p.load();
    expect(p.error, isNotNull);
    expect(p.ideas, isEmpty);
  });

  test('Idea JSON round trip', () {
    final i = seedIdeas().first;
    final j = Idea.fromJson(i.toJson());
    expect(j.title, i.title);
    expect(j.tags, i.tags);
  });
}
