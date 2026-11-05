import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/core.dart';

class SubmitIdeaPage extends StatefulWidget {
  const SubmitIdeaPage({super.key});
  @override
  State<SubmitIdeaPage> createState() => _SubmitIdeaPageState();
}

class _SubmitIdeaPageState extends State<SubmitIdeaPage> {
  final _key = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _problem = TextEditingController();
  final _solution = TextEditingController();
  final _desc = TextEditingController();
  final _impact = TextEditingController();
  final _team = TextEditingController();
  String? _category;
  String _stage = stages.first;
  final Set<String> _tags = {};
  bool _tagError = false;
  bool _busy = false;
  Idea? _created;

  @override
  void dispose() {
    for (final c in [_title, _problem, _solution, _desc, _impact, _team]) {
      c.dispose();
    }
    super.dispose();
  }

  String? Function(String?) _req(String label, int min) => (v) {
        final t = v?.trim() ?? '';
        if (t.isEmpty) return '$label is required';
        if (t.length < min) return '$label must be at least $min characters';
        return null;
      };

  Future<void> _submit() async {
    final ok = _key.currentState!.validate();
    setState(() => _tagError = _tags.isEmpty);
    if (!ok || _tags.isEmpty) {
      toast(context, 'Please fix the highlighted fields.', error: true);
      return;
    }
    final p = context.read<IdeaProvider>();
    setState(() => _busy = true);
    try {
      final idea = await p.submit(Idea(
        id: '', title: _title.text.trim(), problem: _problem.text.trim(),
        solution: _solution.text.trim(), description: _desc.text.trim(),
        category: _category!, author: p.user.name, impact: _impact.text.trim(),
        stage: _stage, tags: _tags.toList(),
        team: _team.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      ));
      if (!mounted) return;
      setState(() => _created = idea);
      toast(context, p.isMock
          ? 'Idea added (demo mode: stored in this session only, not on a server).'
          : 'Idea submitted successfully!');
    } catch (e) {
      if (mounted) toast(context, 'Submission failed: $e', error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _reset() {
    _key.currentState?.reset();
    for (final c in [_title, _problem, _solution, _desc, _impact, _team]) {
      c.clear();
    }
    setState(() {
      _created = null;
      _category = null;
      _stage = stages.first;
      _tags.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_created != null) {
      return Center(
        child: EmptyStateWidget(
          icon: Icons.check_circle_rounded,
          title: 'Idea submitted!',
          message: '"${_created!.title}" is now in the vault.',
          action: Wrap(spacing: 12, runSpacing: 12, alignment: WrapAlignment.center, children: [
            GradientButton(label: 'View idea', onPressed: () => context.push('/idea/${_created!.id}')),
            GradientButton(label: 'Submit another', outlined: true, onPressed: _reset),
          ]),
        ),
      );
    }
    const gap = SizedBox(height: 16);
    return PageBody(children: [
      Text('Submit Your Idea', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
      const SizedBox(height: 4),
      const Text('Share your project or startup idea with the community.', style: TextStyle(color: C.muted)),
      const SizedBox(height: 20),
      GlassCard(
        padding: EdgeInsets.all(isMobile(context) ? 16 : 28),
        child: Form(
          key: _key,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CustomTextField(label: 'Idea title', controller: _title, validator: _req('Idea title', 5)),
            gap,
            CustomTextField(label: 'Problem statement', controller: _problem, maxLines: 3, validator: _req('Problem statement', 20)),
            gap,
            CustomTextField(label: 'Proposed solution', controller: _solution, maxLines: 3, validator: _req('Proposed solution', 20)),
            gap,
            CustomTextField(label: 'Detailed description', controller: _desc, maxLines: 5, validator: _req('Detailed description', 40)),
            gap,
            DropdownButtonFormField<String>(
              initialValue: _category,
              isExpanded: true,
              dropdownColor: C.surface,
              decoration: fieldDecoration('Innovation category'),
              items: [for (final c in categories) DropdownMenuItem(value: c, child: Text(c))],
              onChanged: (v) => setState(() => _category = v),
              validator: (v) => v == null ? 'Please choose a category' : null,
            ),
            gap,
            const Text('Technologies used', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final t in techOptions)
                FilterChip(
                  label: Text(t),
                  selected: _tags.contains(t),
                  selectedColor: C.violet,
                  showCheckmark: false,
                  onSelected: (s) => setState(() {
                    s ? _tags.add(t) : _tags.remove(t);
                    _tagError = false;
                  }),
                ),
            ]),
            if (_tagError)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text('Select at least one technology', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
              ),
            gap,
            CustomTextField(label: 'Expected impact', controller: _impact, maxLines: 2, validator: _req('Expected impact', 10)),
            gap,
            DropdownButtonFormField<String>(
              initialValue: _stage,
              isExpanded: true,
              dropdownColor: C.surface,
              decoration: fieldDecoration('Development stage'),
              items: [for (final s in stages) DropdownMenuItem(value: s, child: Text(s))],
              onChanged: (v) => setState(() => _stage = v ?? stages.first),
            ),
            gap,
            CustomTextField(label: 'Team members (optional)', controller: _team, hint: 'Comma separated names'),
            const SizedBox(height: 24),
            _busy
                ? const LoadingIndicator()
                : GradientButton(label: 'Submit Idea', icon: Icons.rocket_launch_rounded, onPressed: _submit),
          ]),
        ),
      ),
    ]);
  }
}
