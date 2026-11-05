import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/models.dart';
import '../providers/idea_provider.dart';
import 'constants.dart';
import 'theme.dart';

class Wide extends StatelessWidget {
  const Wide({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile(context) ? 16 : 32),
              child: child),
        ),
      );
}

class PageBody extends StatelessWidget {
  const PageBody({super.key, required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: isMobile(context) ? 16 : 32),
        child: Wide(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children)),
      );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.trailing});
  final String text;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 32, bottom: 16),
        child: Row(children: [
          Expanded(
              child: Text(text,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w700))),
          if (trailing != null) trailing!,
        ]),
      );
}

class FadeIn extends StatelessWidget {
  const FadeIn({super.key, required this.child, this.ms = 700});
  final Widget child;
  final int ms;
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: Duration(milliseconds: ms),
        curve: Curves.easeOutCubic,
        builder: (c, v, ch) => Opacity(
            opacity: v, child: Transform.translate(offset: Offset(0, 24 * (1 - v)), child: ch)),
        child: child,
      );
}

class GlassCard extends StatefulWidget {
  const GlassCard({super.key, required this.child, this.onTap, this.padding = const EdgeInsets.all(18)});
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    final lift = _hover && widget.onTap != null;
    return MouseRegion(
      cursor: widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.translationValues(0, lift ? -4 : 0, 0),
          padding: widget.padding,
          decoration: BoxDecoration(
            color: const Color.fromRGBO(255, 255, 255, .06),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: lift ? C.cyan.withAlpha(160) : const Color.fromRGBO(255, 255, 255, .12)),
            boxShadow: [
              BoxShadow(
                  color: Color.fromRGBO(124, 58, 237, lift ? .35 : .12), blurRadius: 24)
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

class GradientButton extends StatelessWidget {
  const GradientButton(
      {super.key, required this.label, this.icon, this.onPressed, this.outlined = false});
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool outlined;
  @override
  Widget build(BuildContext context) {
    final content = Row(mainAxisSize: MainAxisSize.min, children: [
      if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
      Flexible(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
    ]);
    if (outlined) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 50),
          foregroundColor: C.cyan,
          side: const BorderSide(color: C.cyan),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: content,
      );
    }
    return Opacity(
      opacity: onPressed == null ? .5 : 1,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            gradient: C.grad,
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [BoxShadow(color: Color.fromRGBO(124, 58, 237, .45), blurRadius: 18)],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: onPressed,
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                child: DefaultTextStyle.merge(style: const TextStyle(color: Colors.white), child: IconTheme.merge(data: const IconThemeData(color: Colors.white), child: content))),
          ),
        ),
      ),
    );
  }
}

class CategoryChip extends StatelessWidget {
  const CategoryChip({super.key, required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: C.violet,
        backgroundColor: const Color.fromRGBO(255, 255, 255, .06),
        showCheckmark: false,
        side: BorderSide(color: selected ? C.violet : const Color.fromRGBO(255, 255, 255, .15)),
      );
}

class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({super.key, required this.onChanged, this.initial = '', this.hint = 'Search ideas, tags or authors'});
  final ValueChanged<String> onChanged;
  final String initial, hint;
  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late final TextEditingController _c = TextEditingController(text: widget.initial);
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
        controller: _c,
        onChanged: widget.onChanged,
        decoration: fieldDecoration('Search', hint: widget.hint).copyWith(
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () {
                _c.clear();
                widget.onChanged('');
              }),
        ),
      );
}

class CustomTextField extends StatelessWidget {
  const CustomTextField(
      {super.key, required this.label, required this.controller, this.validator, this.maxLines = 1, this.hint});
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final int maxLines;
  final String? hint;
  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        validator: validator,
        maxLines: maxLines,
        decoration: fieldDecoration(label, hint: hint),
      );
}

class StatisticCard extends StatelessWidget {
  const StatisticCard({super.key, required this.icon, required this.label, required this.value, this.color = C.cyan});
  final IconData icon;
  final String label;
  final int value;
  final Color color;
  @override
  Widget build(BuildContext context) => GlassCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: color),
          const SizedBox(height: 10),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value.toDouble()),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOut,
            builder: (c, v, _) => Text('${v.round()}',
                style: Theme.of(c).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
          ),
          Text(label, style: const TextStyle(color: C.muted), overflow: TextOverflow.ellipsis),
        ]),
      );
}

class StatGrid extends StatelessWidget {
  const StatGrid(this.cards, {super.key});
  final List<Widget> cards;
  @override
  Widget build(BuildContext context) => GridView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 280, mainAxisExtent: 150, crossAxisSpacing: 16, mainAxisSpacing: 16),
        children: cards,
      );
}

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, required this.name, this.radius = 20});
  final String name;
  final double radius;
  @override
  Widget build(BuildContext context) {
    final parts = name.trim().split(' ').where((e) => e.isNotEmpty).toList();
    final initials = parts.isEmpty ? '?' : parts.take(2).map((e) => e[0].toUpperCase()).join();
    return Container(
      width: radius * 2,
      height: radius * 2,
      alignment: Alignment.center,
      decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [C.violet, C.cyan])),
      child: Text(initials,
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: radius * .8)),
    );
  }
}

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Padding(padding: EdgeInsets.all(48), child: CircularProgressIndicator(color: C.cyan)));
}

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({super.key, required this.icon, required this.title, required this.message, this.action});
  final IconData icon;
  final String title, message;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 56, color: C.muted),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(message, style: const TextStyle(color: C.muted), textAlign: TextAlign.center),
            if (action != null) ...[const SizedBox(height: 16), action!],
          ]),
        ),
      );
}

class ErrorStateWidget extends StatelessWidget {
  const ErrorStateWidget({super.key, required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => EmptyStateWidget(
        icon: Icons.cloud_off_rounded,
        title: 'Something went wrong',
        message: message,
        action: GradientButton(label: 'Retry', icon: Icons.refresh_rounded, onPressed: onRetry),
      );
}

/// Shows loading / error states, otherwise builds content.
class StateGate extends StatelessWidget {
  const StateGate({super.key, required this.builder});
  final Widget Function(IdeaProvider p) builder;
  @override
  Widget build(BuildContext context) {
    final p = context.watch<IdeaProvider>();
    if (p.loading && p.ideas.isEmpty) return const LoadingIndicator();
    if (p.error != null && p.ideas.isEmpty) return ErrorStateWidget(message: p.error!, onRetry: p.load);
    return builder(p);
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.text, {this.color = C.violet});
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: color.withAlpha(70), borderRadius: BorderRadius.circular(20)),
        child: Text(text, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis, maxLines: 1),
      );
}

class Pill extends StatelessWidget {
  const Pill(this.text, {super.key, this.color = C.violet});
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) => _Pill(text, color: color);
}

class IdeaCard extends StatelessWidget {
  const IdeaCard({super.key, required this.idea});
  final Idea idea;
  @override
  Widget build(BuildContext context) {
    final p = context.watch<IdeaProvider>();
    final saved = p.saved.contains(idea.id);
    return GlassCard(
      onTap: () => context.push('/idea/${idea.id}'),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Flexible(child: _Pill(idea.category)),
          const Spacer(),
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: saved ? 'Remove bookmark' : 'Save idea',
            onPressed: () => p.toggleSave(idea.id),
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
              child: Icon(saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                  key: ValueKey(saved), color: saved ? C.cyan : C.muted),
            ),
          ),
        ]),
        Text(idea.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(idea.description,
            maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: C.muted)),
        const SizedBox(height: 12),
        SizedBox(
          height: 28,
          child: ListView(scrollDirection: Axis.horizontal, children: [
            for (final t in idea.tags)
              Padding(padding: const EdgeInsets.only(right: 6), child: _Pill(t, color: C.teal)),
          ]),
        ),
        const Spacer(),
        Row(children: [
          ProfileAvatar(name: idea.author, radius: 12),
          const SizedBox(width: 6),
          Expanded(child: Text(idea.author, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: C.muted))),
          const Icon(Icons.arrow_upward_rounded, size: 16, color: C.teal),
          Text(' ${idea.votes}', style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 10),
          Flexible(child: Text(idea.stage, overflow: TextOverflow.ellipsis, style: const TextStyle(color: C.cyan, fontSize: 12))),
        ]),
      ]),
    );
  }
}

class IdeaGrid extends StatelessWidget {
  const IdeaGrid(this.ideas, {super.key});
  final List<Idea> ideas;
  @override
  Widget build(BuildContext context) => GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: ideas.length,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 380, mainAxisExtent: 280, crossAxisSpacing: 16, mainAxisSpacing: 16),
        itemBuilder: (c, i) => IdeaCard(idea: ideas[i]),
      );
}

class Logo extends StatelessWidget {
  const Logo({super.key});
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () => context.go('/'),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(gradient: C.grad, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.lightbulb_rounded, size: 20, color: Colors.white),
          ),
          const SizedBox(width: 10),
          const Text('Idea Vault', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        ]),
      );
}

/// Top navigation for the public (landing) site.
class CustomNavigationBar extends StatelessWidget {
  const CustomNavigationBar({super.key});
  @override
  Widget build(BuildContext context) {
    return Wide(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(children: [
          const Logo(),
          const Spacer(),
          if (isMobile(context))
            PopupMenuButton<String>(
              icon: const Icon(Icons.menu_rounded),
              onSelected: (v) => context.go(v),
              itemBuilder: (c) => [
                for (final n in navItems) PopupMenuItem(value: n.path, child: Text(n.label)),
              ],
            )
          else ...[
            for (final n in navItems.take(3))
              TextButton(onPressed: () => context.go(n.path), child: Text(n.label, style: const TextStyle(color: C.text))),
            const SizedBox(width: 12),
            GradientButton(label: 'Dashboard', onPressed: () => context.go('/dashboard')),
          ],
        ]),
      ),
    );
  }
}

/// Desktop sidebar for the signed-in area.
class CustomSidebar extends StatelessWidget {
  const CustomSidebar({super.key, required this.selected});
  final int selected;
  @override
  Widget build(BuildContext context) {
    final user = context.read<IdeaProvider>().user;
    return Container(
      width: 240,
      decoration: const BoxDecoration(
          color: C.surface, border: Border(right: BorderSide(color: Color.fromRGBO(255, 255, 255, .08)))),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Padding(padding: EdgeInsets.fromLTRB(8, 8, 8, 28), child: Logo()),
        for (var i = 0; i < navItems.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Material(
              color: Colors.transparent,
              child: Ink(
                decoration: BoxDecoration(
                    gradient: i == selected ? C.grad : null, borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  dense: true,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  leading: Icon(navItems[i].icon, color: i == selected ? Colors.white : C.muted),
                  title: Text(navItems[i].label,
                      style: TextStyle(fontWeight: FontWeight.w600, color: i == selected ? Colors.white : C.muted)),
                  onTap: () => context.go(navItems[i].path),
                ),
              ),
            ),
          ),
        const Spacer(),
        Row(children: [
          ProfileAvatar(name: user.name),
          const SizedBox(width: 10),
          Expanded(child: Text(user.name, overflow: TextOverflow.ellipsis)),
        ]),
      ]),
    );
  }
}
