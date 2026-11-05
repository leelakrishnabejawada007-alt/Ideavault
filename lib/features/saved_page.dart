import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/core.dart';

class SavedIdeasPage extends StatefulWidget {
  const SavedIdeasPage({super.key});
  @override
  State<SavedIdeasPage> createState() => _SavedIdeasPageState();
}

class _SavedIdeasPageState extends State<SavedIdeasPage> {
  String _q = '';
  String? _cat;

  @override
  Widget build(BuildContext context) {
    return PageBody(children: [
      Text('Saved Ideas', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
      const SizedBox(height: 16),
      StateGate(
        builder: (p) {
          final all = p.savedIdeas;
          final list = filterIdeas(all, _q, _cat);
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Wrap(spacing: 12, runSpacing: 12, crossAxisAlignment: WrapCrossAlignment.center, children: [
              SizedBox(width: 420, child: SearchBarWidget(initial: _q, hint: 'Search saved ideas', onChanged: (v) => setState(() => _q = v))),
              SizedBox(
                width: 240,
                child: DropdownButtonFormField<String?>(
                  initialValue: _cat,
                  isExpanded: true,
                  dropdownColor: C.surface,
                  decoration: fieldDecoration('Category'),
                  items: [
                    const DropdownMenuItem<String?>(value: null, child: Text('All categories')),
                    for (final c in categories) DropdownMenuItem<String?>(value: c, child: Text(c, overflow: TextOverflow.ellipsis)),
                  ],
                  onChanged: (v) => setState(() => _cat = v),
                ),
              ),
            ]),
            const SizedBox(height: 20),
            if (all.isEmpty)
              EmptyStateWidget(
                icon: Icons.bookmark_border_rounded,
                title: 'Nothing saved yet',
                message: 'Tap the bookmark on any idea to keep it here.',
                action: GradientButton(label: 'Explore ideas', onPressed: () => context.go('/explore')),
              )
            else if (list.isEmpty)
              const EmptyStateWidget(icon: Icons.search_off_rounded, title: 'No matches', message: 'No saved ideas match your search or filter.')
            else
              IdeaGrid(list),
          ]);
        },
      ),
    ]);
  }
}
