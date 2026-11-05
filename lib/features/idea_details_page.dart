import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/core.dart';

class IdeaDetailsPage extends StatefulWidget {
  const IdeaDetailsPage({super.key, required this.id});
  final String id;
  @override
  State<IdeaDetailsPage> createState() => _IdeaDetailsPageState();
}

class _IdeaDetailsPageState extends State<IdeaDetailsPage> {
  final _comment = TextEditingController();
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<IdeaProvider>().markViewed(widget.id);
    });
  }

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _vote(IdeaProvider p) async {
    try {
      final ok = await p.vote(widget.id);
      if (mounted) toast(context, ok ? 'Thanks for voting!' : 'You already voted for this idea.');
    } catch (e) {
      if (mounted) toast(context, 'Vote failed: $e', error: true);
    }
  }

  Future<void> _post(IdeaProvider p) async {
    final t = _comment.text.trim();
    if (t.isEmpty) {
      toast(context, 'Write a comment first.', error: true);
      return;
    }
    setState(() => _busy = true);
    try {
      await p.addComment(widget.id, t);
      _comment.clear();
    } catch (e) {
      if (mounted) toast(context, 'Could not post comment: $e', error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _block(String title, String body) => Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(color: C.cyan, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(body, style: const TextStyle(height: 1.5)),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    return PageBody(children: [
      StateGate(
        builder: (p) {
          final idea = p.byId(widget.id);
          if (idea == null) {
            return EmptyStateWidget(
              icon: Icons.help_outline_rounded,
              title: 'Idea not found',
              message: 'It may have been removed.',
              action: GradientButton(label: 'Back to Explore', onPressed: () => context.go('/explore')),
            );
          }
          final saved = p.saved.contains(idea.id);
          final voted = p.voted.contains(idea.id);
          final related = p.ideas.where((i) => i.category == idea.category && i.id != idea.id).take(3).toList();
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            TextButton.icon(
              onPressed: () => context.canPop() ? context.pop() : context.go('/explore'),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Back'),
            ),
            Wrap(spacing: 8, children: [Pill(idea.category), Pill(idea.stage, color: C.cyan)]),
            const SizedBox(height: 12),
            Text(idea.title, style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Row(children: [
              ProfileAvatar(name: idea.author, radius: 16),
              const SizedBox(width: 10),
              Expanded(child: Text('${idea.author} · ${timeAgo(idea.createdAt)}', style: const TextStyle(color: C.muted), overflow: TextOverflow.ellipsis)),
            ]),
            const SizedBox(height: 16),
            Wrap(spacing: 12, runSpacing: 12, children: [
              GradientButton(
                  label: voted ? 'Voted · ${idea.votes}' : 'Vote · ${idea.votes}',
                  icon: Icons.arrow_upward_rounded,
                  onPressed: voted ? null : () => _vote(p)),
              GradientButton(
                  label: saved ? 'Saved' : 'Save',
                  icon: saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                  outlined: true,
                  onPressed: () => p.toggleSave(idea.id)),
            ]),
            const SizedBox(height: 24),
            GlassCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Development progress', style: TextStyle(color: C.cyan, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(value: idea.progress, minHeight: 10, color: C.violet, backgroundColor: Colors.white12),
                ),
                const SizedBox(height: 8),
                Wrap(spacing: 12, children: [
                  for (final s in stages)
                    Text(s, style: TextStyle(fontSize: 12, color: s == idea.stage ? C.cyan : C.muted)),
                ]),
              ]),
            ),
            const SizedBox(height: 24),
            _block('Problem statement', idea.problem),
            _block('Proposed solution', idea.solution),
            _block('Description', idea.description),
            _block('Expected impact', idea.impact),
            const Text('Technologies', style: TextStyle(color: C.cyan, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [for (final t in idea.tags) Pill(t, color: C.teal)]),
            if (idea.team.isNotEmpty) ...[
              const SizedBox(height: 20),
              _block('Team', idea.team.join(', ')),
            ],
            SectionTitle('Comments (${idea.comments.length})'),
            TextField(
              controller: _comment,
              minLines: 2,
              maxLines: 4,
              decoration: fieldDecoration('Share constructive feedback'),
            ),
            const SizedBox(height: 10),
            _busy ? const LoadingIndicator() : GradientButton(label: 'Post comment', icon: Icons.send_rounded, onPressed: () => _post(p)),
            const SizedBox(height: 16),
            if (idea.comments.isEmpty)
              const Text('No comments yet. Be the first!', style: TextStyle(color: C.muted)),
            for (final c in idea.comments)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GlassCard(
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    ProfileAvatar(name: c.author, radius: 16),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('${c.author} · ${timeAgo(c.time)}', style: const TextStyle(color: C.muted, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(c.text),
                      ]),
                    ),
                  ]),
                ),
              ),
            if (related.isNotEmpty) ...[
              const SectionTitle('Related ideas'),
              IdeaGrid(related),
            ],
          ]);
        },
      ),
    ]);
  }
}
