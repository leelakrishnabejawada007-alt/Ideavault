import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/core.dart';

class _BgPainter extends CustomPainter {
  _BgPainter(this.t);
  final double t;
  @override
  void paint(Canvas canvas, Size size) {
    const colors = [C.violet, C.cyan, C.indigo];
    for (var i = 0; i < 3; i++) {
      final c = Offset(size.width * (.2 + .3 * i + .05 * sin(t * 2 * pi + i)),
          size.height * (.35 + .2 * cos(t * 2 * pi + i * 2)));
      final paint = Paint()
        ..shader = RadialGradient(colors: [colors[i].withAlpha(90), Colors.transparent])
            .createShader(Rect.fromCircle(center: c, radius: 280));
      canvas.drawCircle(c, 280, paint);
    }
  }

  @override
  bool shouldRepaint(_BgPainter old) => old.t != t;
}

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});
  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with SingleTickerProviderStateMixin {
  late final AnimationController _ac =
      AnimationController(vsync: this, duration: const Duration(seconds: 14))..repeat();
  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = isMobile(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(children: [
          Stack(children: [
            Positioned.fill(
                child: AnimatedBuilder(
                    animation: _ac, builder: (c, _) => CustomPaint(painter: _BgPainter(_ac.value)))),
            Column(children: [
              const CustomNavigationBar(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: m ? 48 : 96),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 820),
                    child: Column(children: [
                      const FadeIn(child: Pill('Built by students, for students', color: C.cyan)),
                      const SizedBox(height: 20),
                      FadeIn(
                        ms: 900,
                        child: Text('Every Great Innovation Starts With an Idea.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: m ? 34 : 58, fontWeight: FontWeight.w800, height: 1.1)),
                      ),
                      const SizedBox(height: 20),
                      const FadeIn(
                        ms: 1100,
                        child: Text(
                          'The Idea Vault is a home for student projects and startup ideas. Discover, vote, give feedback, track progress and find collaborators.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: C.muted, fontSize: 17, height: 1.5),
                        ),
                      ),
                      const SizedBox(height: 32),
                      FadeIn(
                        ms: 1300,
                        child: Wrap(spacing: 14, runSpacing: 14, alignment: WrapAlignment.center, children: [
                          GradientButton(label: 'Explore Ideas', icon: Icons.explore_rounded, onPressed: () => context.go('/explore')),
                          GradientButton(label: 'Submit Your Idea', icon: Icons.add_rounded, outlined: true, onPressed: () => context.go('/submit')),
                        ]),
                      ),
                    ]),
                  ),
                ),
              ),
            ]),
          ]),
          Wide(
            child: StateGate(
              builder: (p) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                StatGrid([
                  StatisticCard(icon: Icons.lightbulb_rounded, label: 'Ideas shared', value: p.ideas.length, color: C.violet),
                  StatisticCard(icon: Icons.groups_rounded, label: 'Active innovators', value: p.innovators),
                  StatisticCard(icon: Icons.thumb_up_alt_rounded, label: 'Community votes', value: p.totalVotes, color: C.teal),
                  StatisticCard(icon: Icons.category_rounded, label: 'Categories', value: categories.length, color: C.indigo),
                ]),
                const SectionTitle('Featured ideas'),
                IdeaGrid(p.sorted(p.ideas, SortMode.mostVoted).take(3).toList()),
                const SectionTitle('Popular categories'),
                Wrap(spacing: 12, runSpacing: 12, children: [
                  for (final c in categories)
                    SizedBox(
                      width: m ? double.infinity : 220,
                      child: GlassCard(
                        onTap: () {
                          p.setCategory(c);
                          context.go('/explore');
                        },
                        child: Row(children: [
                          Icon(categoryIcons[c], color: C.cyan),
                          const SizedBox(width: 10),
                          Expanded(child: Text(c, overflow: TextOverflow.ellipsis)),
                          Text('${p.countIn(c)}', style: const TextStyle(color: C.muted)),
                        ]),
                      ),
                    ),
                ]),
                SectionTitle('Recently submitted',
                    trailing: TextButton(onPressed: () => context.go('/explore'), child: const Text('View all'))),
                IdeaGrid(p.latest.take(3).toList()),
              ]),
            ),
          ),
          const SizedBox(height: 64),
          Container(
            color: C.surface,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Wide(
              child: Wrap(spacing: 48, runSpacing: 24, alignment: WrapAlignment.spaceBetween, children: [
                const SizedBox(width: 280, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Logo(),
                  SizedBox(height: 12),
                  Text('Where Ideas Become Innovations.', style: TextStyle(color: C.muted)),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Platform', style: TextStyle(fontWeight: FontWeight.w700)),
                  for (final n in navItems)
                    TextButton(onPressed: () => context.go(n.path), child: Text(n.label, style: const TextStyle(color: C.muted))),
                ]),
                const Text('© 2026 Student Innovation Idea Vault', style: TextStyle(color: C.muted)),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}
