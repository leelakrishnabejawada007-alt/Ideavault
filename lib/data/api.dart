import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import 'models.dart';

class ApiException implements Exception {
  ApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Contract shared by the mock and the real REST implementations.
abstract class IdeaApi {
  bool get isMock;
  Future<List<Idea>> getIdeas(); // GET /ideas
  Future<Idea> getIdea(String id); // GET /ideas/{id}
  Future<Idea> postIdea(Idea idea); // POST /ideas
  Future<List<String>> getCategories(); // GET /categories
  Future<int> vote(String id); // POST /ideas/{id}/vote
  Future<Comment> addComment(String id, String text, String author); // POST /ideas/{id}/comments
  Future<AppUser> getUser(String id); // GET /users/{id}
}

Idea _s(String id, String title, String cat, String author, String stage,
        int votes, List<String> tags, String problem, String solution,
        String impact, int days) =>
    Idea(
      id: id, title: title, category: cat, author: author, stage: stage,
      votes: votes, tags: tags, problem: problem, solution: solution,
      impact: impact, description: '$solution $impact',
      createdAt: DateTime.now().subtract(Duration(days: days)),
      comments: [
        Comment(
            author: 'Priya Nair',
            text: 'Strong concept! A small campus pilot would give great feedback.',
            time: DateTime.now().subtract(Duration(days: days - 1)))
      ],
    );

List<Idea> seedIdeas() => [
      _s('1', 'AI-Powered Crop Disease Detection', 'Agriculture', 'Ananya Rao', 'Prototype', 128,
          ['TensorFlow', 'Python', 'Flutter'],
          'Smallholder farmers lose yield because leaf diseases are spotted too late.',
          'A phone app classifies leaf photos offline and suggests treatments in local languages.',
          'Could cut avoidable losses and reduce pesticide overuse.', 3),
      _s('2', 'Smart Campus Navigation', 'Smart Cities', 'Rohan Mehta', 'Development', 96,
          ['Flutter', 'Firebase', 'IoT'],
          'New students waste time finding rooms, labs and events across a large campus.',
          'Indoor-outdoor maps with live room availability and step-by-step routes.',
          'Saves time and improves accessibility for everyone on campus.', 5),
      _s('3', 'Student Mental Wellness Companion', 'Healthcare', 'Demo Student', 'Concept', 74,
          ['Flutter', 'Firebase', 'Machine Learning'],
          'Students hesitate to seek help during stressful exam periods.',
          'An anonymous check-in app with mood trends, breathing exercises and counsellor links.',
          'Encourages early support and healthier study habits.', 7),
      _s('4', 'AI-Based Resume Analyzer', 'Artificial Intelligence', 'Demo Student', 'Testing', 88,
          ['Python', 'Machine Learning', 'React'],
          'Fresh graduates do not know why their resumes get rejected by screening tools.',
          'Upload a resume and get keyword gaps, formatting fixes and role-fit scores.',
          'Helps students apply with stronger, targeted resumes.', 2),
      _s('5', 'Smart Waste Segregation System', 'Environment', 'Sneha Iyer', 'Prototype', 61,
          ['Arduino', 'IoT', 'TensorFlow'],
          'Mixed waste in campus bins makes recycling nearly impossible.',
          'A camera-equipped bin sorts items into dry, wet and recyclable compartments.',
          'Raises recycling rates and lowers landfill load.', 9),
      _s('6', 'Emergency Resource Allocation Platform', 'Social Innovation', 'Karthik Reddy', 'Development', 112,
          ['Django', 'SQL', 'React'],
          'During disasters, relief supplies are poorly matched to where they are needed.',
          'A dashboard that maps needs and inventory and recommends allocation in real time.',
          'Faster, fairer relief delivery during emergencies.', 4),
      _s('7', 'Personalized Learning Assistant', 'Education', 'Meera Joshi', 'Concept', 69,
          ['Python', 'Machine Learning', 'Flutter'],
          'One-size-fits-all study material leaves many learners behind.',
          'An assistant that builds adaptive study plans from quiz performance.',
          'Better retention and less exam anxiety.', 11),
      _s('8', 'Smart Energy Monitoring', 'Smart Cities', 'Aditya Verma', 'Launched', 45,
          ['IoT', 'Arduino', 'Node.js'],
          'Hostels and labs waste electricity with no visibility into usage.',
          'Low-cost sensors stream usage to a live dashboard with waste alerts.',
          'Lower bills and a smaller carbon footprint.', 14),
      _s('9', 'Blood Donation Coordination Platform', 'Healthcare', 'Fatima Khan', 'Testing', 83,
          ['Django', 'SQL', 'Flutter'],
          'Finding matching blood donors quickly in emergencies is chaotic.',
          'Verified donor network with blood-group matching and nearby request alerts.',
          'Shorter response times when every minute counts.', 6),
      _s('10', 'Accessible Education Companion', 'Education', 'Arjun Patel', 'Prototype', 57,
          ['Flutter', 'Dart', 'Machine Learning'],
          'Visually and hearing impaired students struggle with standard course material.',
          'Auto captions, screen-reader-friendly notes and audio summaries of lectures.',
          'More inclusive classrooms.', 8),
      _s('11', 'Campus Micro-Budget Tracker', 'FinTech', 'Lakshmi Narayan', 'Concept', 38,
          ['Flutter', 'Firebase'],
          'Students overspend because small daily expenses go untracked.',
          'Fast expense logging with weekly insights and shared hostel budgets.',
          'Builds financial literacy early.', 12),
      _s('12', 'Autonomous Lab Assistant Robot', 'Robotics', 'Vikram Singh', 'Prototype', 52,
          ['Arduino', 'Python', 'IoT'],
          'Lab consumables and equipment handover waste instructor time.',
          'A line-following robot that delivers components to lab benches on request.',
          'Frees up time for hands-on learning.', 10),
      _s('13', 'Open Source Portfolio Builder', 'Web Development', 'Nisha Thomas', 'Development', 41,
          ['React', 'Node.js', 'SQL'],
          'Students struggle to present projects professionally.',
          'Connect a GitHub account and generate a polished, customizable portfolio site.',
          'Better visibility to recruiters.', 13),
    ];

class MockIdeaApi implements IdeaApi {
  MockIdeaApi({this.delay = const Duration(milliseconds: 400), this.fail = false});
  final Duration delay;
  bool fail;
  final List<Idea> _ideas = seedIdeas();

  @override
  bool get isMock => true;

  Future<void> _d() async {
    await Future.delayed(delay);
    if (fail) throw ApiException('Mock network failure. Please try again.');
  }

  Idea _find(String id) => _ideas.firstWhere((i) => i.id == id,
      orElse: () => throw ApiException('Idea not found'));

  @override
  Future<List<Idea>> getIdeas() async {
    await _d();
    return List.of(_ideas);
  }

  @override
  Future<Idea> getIdea(String id) async {
    await _d();
    return _find(id);
  }

  @override
  Future<Idea> postIdea(Idea idea) async {
    await _d();
    final created = idea.withId('idea-${_ideas.length + 1}');
    _ideas.insert(0, created);
    return created;
  }

  @override
  Future<List<String>> getCategories() async {
    await _d();
    return categories;
  }

  @override
  Future<int> vote(String id) async {
    await _d();
    final i = _find(id);
    i.votes++;
    return i.votes;
  }

  @override
  Future<Comment> addComment(String id, String text, String author) async {
    await _d();
    _find(id);
    return Comment(author: author, text: text);
  }

  @override
  Future<AppUser> getUser(String id) async {
    await _d();
    return demoUser;
  }
}

class HttpIdeaApi implements IdeaApi {
  HttpIdeaApi(this.baseUrl, {http.Client? client}) : _c = client ?? http.Client();
  final String baseUrl;
  final http.Client _c;
  static const _h = {'Content-Type': 'application/json'};

  @override
  bool get isMock => false;

  Uri _u(String p) => Uri.parse('$baseUrl$p');

  dynamic _decode(http.Response r) {
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw ApiException('Server error (${r.statusCode})');
    }
    return jsonDecode(r.body);
  }

  Future<T> _run<T>(Future<T> Function() f) async {
    try {
      return await f();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  @override
  Future<List<Idea>> getIdeas() => _run(() async {
        final d = _decode(await _c.get(_u('/ideas'))) as List;
        return d.map((j) => Idea.fromJson(Map<String, dynamic>.from(j))).toList();
      });

  @override
  Future<Idea> getIdea(String id) => _run(() async => Idea.fromJson(
      Map<String, dynamic>.from(_decode(await _c.get(_u('/ideas/$id'))))));

  @override
  Future<Idea> postIdea(Idea idea) => _run(() async => Idea.fromJson(
      Map<String, dynamic>.from(_decode(await _c.post(_u('/ideas'),
          headers: _h, body: jsonEncode(idea.toJson()))))));

  @override
  Future<List<String>> getCategories() => _run(() async =>
      (_decode(await _c.get(_u('/categories'))) as List).map((e) => e.toString()).toList());

  @override
  Future<int> vote(String id) => _run(() async {
        final d = _decode(await _c.post(_u('/ideas/$id/vote')));
        return (d['votes'] as num).toInt();
      });

  @override
  Future<Comment> addComment(String id, String text, String author) =>
      _run(() async => Comment.fromJson(Map<String, dynamic>.from(_decode(
          await _c.post(_u('/ideas/$id/comments'),
              headers: _h, body: jsonEncode({'text': text, 'author': author}))))));

  @override
  Future<AppUser> getUser(String id) => _run(() async => AppUser.fromJson(
      Map<String, dynamic>.from(_decode(await _c.get(_u('/users/$id'))))));
}
