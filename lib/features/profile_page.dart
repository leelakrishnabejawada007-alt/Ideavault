import 'package:flutter/material.dart';
import '../core/core.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Widget _badge(String title, String sub, IconData icon, bool unlocked) => Opacity(
        opacity: unlocked ? 1 : .4,
        child: SizedBox(
          width: 260,
          child: GlassCard(
            child: Row(children: [
              Icon(icon, color: unlocked ? C.cyan : C.muted, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text(sub, style: const TextStyle(color: C.muted, fontSize: 12)),
                ]),
              ),
            ]),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return PageBody(children: [
      StateGate(
        builder: (p) {
          final u = p.user;
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            GlassCard(
              child: Wrap(spacing: 20, runSpacing: 16, crossAxisAlignment: WrapCrossAlignment.center, children: [
                ProfileAvatar(name: u.name, radius: 44),
                Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                  Text(u.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                  Text(u.department, style: const TextStyle(color: C.muted)),
                  Text(u.institution, style: const TextStyle(color: C.muted)),
                ]),
              ]),
            ),
            const SectionTitle('Skills'),
            Wrap(spacing: 8, runSpacing: 8, children: [for (final s in u.skills) Pill(s, color: C.teal)]),
            const SectionTitle('Interests'),
            Wrap(spacing: 8, runSpacing: 8, children: [for (final s in u.interests) Pill(s)]),
            const SectionTitle('Achievements & activity'),
            Wrap(spacing: 12, runSpacing: 12, children: [
              _badge('First Idea', 'Submitted an idea', Icons.emoji_objects_rounded, p.myIdeas.isNotEmpty),
              _badge('Community Favourite', '50+ votes received', Icons.emoji_events_rounded, p.votesReceived >= 50),
              _badge('Collector', 'Saved 3+ ideas', Icons.collections_bookmark_rounded, p.saved.length >= 3),
              _badge('Explorer', 'Viewed 3+ ideas', Icons.travel_explore_rounded, p.viewed.length >= 3),
            ]),
            SectionTitle('Submitted ideas (${p.myIdeas.length})'),
            p.myIdeas.isEmpty ? const Text('No submissions yet.', style: TextStyle(color: C.muted)) : IdeaGrid(p.myIdeas),
            SectionTitle('Saved ideas (${p.savedIdeas.length})'),
            p.savedIdeas.isEmpty ? const Text('No saved ideas yet.', style: TextStyle(color: C.muted)) : IdeaGrid(p.savedIdeas),
          ]);
        },
      ),
    ]);
  }
}
