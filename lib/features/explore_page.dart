import 'package:flutter/material.dart';
import '../core/core.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});
  @override
  Widget build(BuildContext context) {
    return PageBody(children: [
      Text('Explore Ideas', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
      const SizedBox(height: 16),
      StateGate(
        builder: (p) {
          final list = p.explore;
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SearchBarWidget(initial: p.query, onChanged: p.setQuery),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                CategoryChip(label: 'All', selected: p.category == null, onTap: () => p.setCategory(null)),
                for (final c in categories)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: CategoryChip(label: c, selected: p.category == c, onTap: () => p.setCategory(c)),
                  ),
              ]),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: Text('${list.length} ideas', style: const TextStyle(color: C.muted))),
              DropdownButton<SortMode>(
                value: p.sort,
                dropdownColor: C.surface,
                underline: const SizedBox.shrink(),
                items: const [
                  DropdownMenuItem(value: SortMode.trending, child: Text('Trending')),
                  DropdownMenuItem(value: SortMode.latest, child: Text('Latest')),
                  DropdownMenuItem(value: SortMode.mostVoted, child: Text('Most voted')),
                ],
                onChanged: (v) => p.setSort(v ?? SortMode.trending),
              ),
            ]),
            const SizedBox(height: 8),
            if (list.isEmpty)
              EmptyStateWidget(
                icon: Icons.search_off_rounded,
                title: 'No ideas found',
                message: 'Try a different search or clear the filters.',
                action: GradientButton(label: 'Clear filters', onPressed: () {
                  p.setQuery('');
                  p.setCategory(null);
                }),
              )
            else
              IdeaGrid(list),
          ]);
        },
      ),
    ]);
  }
}
