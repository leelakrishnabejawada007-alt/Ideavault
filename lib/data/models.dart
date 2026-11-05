const stages = ['Concept', 'Prototype', 'Development', 'Testing', 'Launched'];

List<String> _l(dynamic v) =>
    v is List ? v.map((e) => e.toString()).toList() : <String>[];

class Comment {
  Comment({required this.author, required this.text, DateTime? time})
      : time = time ?? DateTime.now();
  final String author;
  final String text;
  final DateTime time;

  factory Comment.fromJson(Map<String, dynamic> j) => Comment(
        author: j['author']?.toString() ?? 'Anonymous',
        text: j['text']?.toString() ?? '',
        time: DateTime.tryParse(j['time']?.toString() ?? ''),
      );
  Map<String, dynamic> toJson() =>
      {'author': author, 'text': text, 'time': time.toIso8601String()};
}

class Idea {
  Idea({
    required this.id,
    required this.title,
    required this.problem,
    required this.solution,
    required this.description,
    required this.category,
    required this.author,
    required this.impact,
    required this.stage,
    required this.tags,
    this.team = const [],
    this.votes = 0,
    DateTime? createdAt,
    List<Comment>? comments,
  })  : createdAt = createdAt ?? DateTime.now(),
        comments = comments ?? [];

  final String id;
  final String title, problem, solution, description, category, author, impact;
  final String stage;
  final List<String> tags, team;
  int votes;
  final DateTime createdAt;
  final List<Comment> comments;

  double get progress => (stages.indexOf(stage) + 1) / stages.length;

  Idea withId(String newId) => Idea(
      id: newId, title: title, problem: problem, solution: solution,
      description: description, category: category, author: author,
      impact: impact, stage: stage, tags: tags, team: team, votes: votes,
      createdAt: createdAt, comments: comments);

  factory Idea.fromJson(Map<String, dynamic> j) => Idea(
        id: j['id'].toString(),
        title: j['title']?.toString() ?? '',
        problem: j['problem']?.toString() ?? '',
        solution: j['solution']?.toString() ?? '',
        description: j['description']?.toString() ?? '',
        category: j['category']?.toString() ?? '',
        author: j['author']?.toString() ?? '',
        impact: j['impact']?.toString() ?? '',
        stage: j['stage']?.toString() ?? stages.first,
        tags: _l(j['tags']),
        team: _l(j['team']),
        votes: (j['votes'] as num?)?.toInt() ?? 0,
        createdAt: DateTime.tryParse(j['createdAt']?.toString() ?? ''),
        comments: (j['comments'] is List)
            ? (j['comments'] as List)
                .map((c) => Comment.fromJson(Map<String, dynamic>.from(c)))
                .toList()
            : [],
      );

  Map<String, dynamic> toJson() => {
        'id': id, 'title': title, 'problem': problem, 'solution': solution,
        'description': description, 'category': category, 'author': author,
        'impact': impact, 'stage': stage, 'tags': tags, 'team': team,
        'votes': votes, 'createdAt': createdAt.toIso8601String(),
        'comments': comments.map((c) => c.toJson()).toList(),
      };
}

class AppUser {
  const AppUser({
    required this.id, required this.name, required this.institution,
    required this.department, required this.skills, required this.interests,
  });
  final String id, name, institution, department;
  final List<String> skills, interests;

  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
        id: j['id'].toString(),
        name: j['name']?.toString() ?? '',
        institution: j['institution']?.toString() ?? '',
        department: j['department']?.toString() ?? '',
        skills: _l(j['skills']),
        interests: _l(j['interests']),
      );
}

const demoUser = AppUser(
  id: 'u1',
  name: 'Demo Student',
  institution: 'Vijayawada Institute of Technology',
  department: 'B.Tech - Computer Science',
  skills: ['Flutter', 'Dart', 'Python', 'UI Design'],
  interests: ['AI for Good', 'Web Development', 'Hackathons'],
);
