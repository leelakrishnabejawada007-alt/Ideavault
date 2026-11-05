import 'api.dart';
import 'models.dart';

class IdeaRepository {
  IdeaRepository(this._api);
  final IdeaApi _api;
  bool get isMock => _api.isMock;
  Future<List<Idea>> ideas() => _api.getIdeas();
  Future<Idea> idea(String id) => _api.getIdea(id);
  Future<Idea> submit(Idea i) => _api.postIdea(i);
  Future<List<String>> categories() => _api.getCategories();
  Future<int> vote(String id) => _api.vote(id);
  Future<Comment> comment(String id, String text, String author) =>
      _api.addComment(id, text, author);
  Future<AppUser> user(String id) => _api.getUser(id);
}
