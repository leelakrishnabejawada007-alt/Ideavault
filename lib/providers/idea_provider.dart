import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models.dart';
import '../data/repository.dart';

enum SortMode { trending, latest, mostVoted }

List<Idea> filterIdeas(Iterable<Idea> src, String q, String? cat) {
  final s = q.trim().toLowerCase();
  return src.where((i) {
    if (cat != null && i.category != cat) return false;
    if (s.isEmpty) return true;
    return i.title.toLowerCase().contains(s) ||
        i.description.toLowerCase().contains(s) ||
        i.author.toLowerCase().contains(s) ||
        i.tags.any((t) => t.toLowerCase().contains(s));
  }).toList();
}

class IdeaProvider extends ChangeNotifier {
  IdeaProvider(this.repo, {SharedPreferences? prefs}) : _prefs = prefs;
  final IdeaRepository repo;
  final SharedPreferences? _prefs;
  final AppUser user = demoUser;

  List<Idea> ideas = [];
  bool loading = false;
  String? error;
  String query = '';
  String? category;
  SortMode sort = SortMode.trending;
  final Set<String> saved = {};
  final Set<String> voted = {};
  final List<String> viewed = [];

  bool get isMock => repo.isMock;

  Future<void> init() async {
    saved.addAll(_prefs?.getStringList('saved') ?? []);
    voted.addAll(_prefs?.getStringList('voted') ?? []);
    await load();
  }

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      ideas = await repo.ideas();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Idea? byId(String id) => ideas.where((i) => i.id == id).firstOrNull;
  int _trend(Idea i) => i.votes + i.comments.length * 3;

  List<Idea> sorted(List<Idea> l, SortMode m) {
    final c = List.of(l);
    switch (m) {
      case SortMode.trending:
        c.sort((a, b) => _trend(b).compareTo(_trend(a)));
        break;
      case SortMode.latest:
        c.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortMode.mostVoted:
        c.sort((a, b) => b.votes.compareTo(a.votes));
        break;
    }
    return c;
  }

  List<Idea> get explore => sorted(filterIdeas(ideas, query, category), sort);
  List<Idea> get trending => sorted(ideas, SortMode.trending);
  List<Idea> get latest => sorted(ideas, SortMode.latest);
  List<Idea> get savedIdeas => ideas.where((i) => saved.contains(i.id)).toList();
  List<Idea> get myIdeas => ideas.where((i) => i.author == user.name).toList();
  List<Idea> get viewedIdeas => viewed.map(byId).whereType<Idea>().toList();
  int get votesReceived => myIdeas.fold(0, (s, i) => s + i.votes);
  int get totalVotes => ideas.fold(0, (s, i) => s + i.votes);
  int get innovators => ideas.map((i) => i.author).toSet().length;
  int countIn(String cat) => ideas.where((i) => i.category == cat).length;

  void setQuery(String q) {
    query = q;
    notifyListeners();
  }

  void setCategory(String? c) {
    category = c;
    notifyListeners();
  }

  void setSort(SortMode m) {
    sort = m;
    notifyListeners();
  }

  void toggleSave(String id) {
    saved.contains(id) ? saved.remove(id) : saved.add(id);
    _prefs?.setStringList('saved', saved.toList());
    notifyListeners();
  }

  void markViewed(String id) {
    viewed.remove(id);
    viewed.insert(0, id);
    if (viewed.length > 4) viewed.removeLast();
    notifyListeners();
  }

  /// Returns false if already voted. Throws ApiException on failure.
  Future<bool> vote(String id) async {
    if (voted.contains(id)) return false;
    final idea = byId(id);
    if (idea == null) return false;
    idea.votes = await repo.vote(id);
    voted.add(id);
    _prefs?.setStringList('voted', voted.toList());
    notifyListeners();
    return true;
  }

  Future<void> addComment(String id, String text) async {
    final c = await repo.comment(id, text, user.name);
    byId(id)?.comments.insert(0, c);
    notifyListeners();
  }

  Future<Idea> submit(Idea draft) async {
    final created = await repo.submit(draft);
    ideas.insert(0, created);
    notifyListeners();
    return created;
  }
}
