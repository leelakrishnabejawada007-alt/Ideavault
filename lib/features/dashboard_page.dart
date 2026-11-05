import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/core.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});
  @override
  Widget build(BuildContext context) {
    return PageBody(children: [
      StateGate(
        builder: (p) {
          final maxCount = categories.map(p.countIn).fold(0, (a, b) => a > b ? a : b);
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Wrap(spacing: 16, runSpacing: 16, crossAxisAlignment: WrapCrossAlignment.center, children: [
              ProfileAvatar(name: p.user.name, radius: 28),
              Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Text('Welcome back, ${p.user.name.split(' ').first}!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                Text('${p.user.department} · ${p.user.institution}',
                    style: const TextStyle(color: C.muted)),
              ]),
              GradientButton(label: 'Submit new idea', icon: Icons.add_rounded, onPressed: () => context.go('/submit')),
            ]),
            const SizedBox(height: 24),
            StatGrid([
              StatisticCard(icon: Icons.lightbulb_rounded, label: 'Ideas submitted', value: p.myIdeas.length, color: C.violet),
              StatisticCard(icon: Icons.bookmark_rounded, label: 'Saved ideas', value: p.saved.length),
              StatisticCard(icon: Icons.thumb_up_alt_rounded, label: 'Votes received', value: p.votesReceived, color: C.teal),
              StatisticCard(icon: Icons.public_rounded, label: 'Ideas on platform', value: p.ideas.length, color: C.indigo),
            ]),
            const SectionTitle('Your idea development status'),
            if (p.myIdeas.isEmpty)
              const EmptyStateWidget(icon: Icons.lightbulb_outline_rounded, title: 'No ideas yet', message: 'Submit your first idea to track its progress here.')
            else
              for (final i in p.myIdeas)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GlassCard(
                    onTap: () => context.push('/idea/${i.id}'),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Expanded(child: Text(i.title, style: const TextStyle(fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis)),
                        Pill(i.stage, color: C.cyan),
                      ]),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: i.progress),
                          duration: const Duration(milliseconds: 900),
                          builder: (c, v, _) => LinearProgressIndicator(
                              value: v, minHeight: 8, color: C.violet, backgroundColor: Colors.white12),
                        ),
                      ),
                    ]),
                  ),
                ),
            const SectionTitle('Recently viewed'),
            p.viewedIdeas.isEmpty
                ? const Text('Ideas you open will show up here.', style: TextStyle(color: C.muted))
                : IdeaGrid(p.viewedIdeas),
            const SectionTitle('Trending innovations'),
            IdeaGrid(p.trending.take(3).toList()),
            const SectionTitle('Community activity by category'),
            GlassCard(
              child: Column(children: [
                for (final c in categories)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(children: [
                      SizedBox(width: 130, child: Text(c, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12))),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                              value: maxCount == 0 ? 0 : p.countIn(c) / maxCount,
                              minHeight: 8, color: C.cyan, backgroundColor: Colors.white12),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('${p.countIn(c)}'),
                    ]),
                  ),
              ]),
            ),
          ]);
        },
      ),
    ]);
  }
}
