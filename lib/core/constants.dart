import 'package:flutter/material.dart';

const categories = [
  'Artificial Intelligence', 'Web Development', 'Healthcare', 'Education',
  'Agriculture', 'Environment', 'Robotics', 'FinTech', 'Smart Cities',
  'Social Innovation',
];

const categoryIcons = <String, IconData>{
  'Artificial Intelligence': Icons.psychology_rounded,
  'Web Development': Icons.language_rounded,
  'Healthcare': Icons.favorite_rounded,
  'Education': Icons.school_rounded,
  'Agriculture': Icons.eco_rounded,
  'Environment': Icons.recycling_rounded,
  'Robotics': Icons.smart_toy_rounded,
  'FinTech': Icons.account_balance_wallet_rounded,
  'Smart Cities': Icons.location_city_rounded,
  'Social Innovation': Icons.diversity_3_rounded,
};

const techOptions = [
  'Flutter', 'Dart', 'Python', 'Machine Learning', 'TensorFlow', 'Django',
  'React', 'Node.js', 'Firebase', 'IoT', 'Arduino', 'Java', 'SQL', 'Blockchain',
];

class NavItem {
  const NavItem(this.label, this.icon, this.path);
  final String label;
  final IconData icon;
  final String path;
}

const navItems = [
  NavItem('Dashboard', Icons.dashboard_rounded, '/dashboard'),
  NavItem('Explore', Icons.explore_rounded, '/explore'),
  NavItem('Submit', Icons.add_circle_rounded, '/submit'),
  NavItem('Saved', Icons.bookmark_rounded, '/saved'),
  NavItem('Profile', Icons.person_rounded, '/profile'),
];
