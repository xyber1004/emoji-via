enum PackStatus { unlocked, locked, comingSoon }

class Pack {
  const Pack({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.status,
    this.unlockCondition,
  });

  final String id;
  final String name;
  final String icon;
  final String description;
  final PackStatus status;
  final String? unlockCondition;

  bool isUnlockedForStreak(int streak) {
    if (status == PackStatus.unlocked) return true;
    if (status == PackStatus.comingSoon) return false;
    switch (id) {
      case 'foodie':
        return streak >= 3;
      case 'music':
        return streak >= 7;
      default:
        return false;
    }
  }
}

const kDefaultPacks = [
  Pack(
    id: 'movies',
    name: 'Movies',
    icon: '🎬',
    description: 'Blockbusters & classics',
    status: PackStatus.unlocked,
  ),
  Pack(
    id: 'foodie',
    name: 'Foodie',
    icon: '🍕',
    description: 'All things delicious',
    status: PackStatus.locked,
    unlockCondition: 'Play 3 days',
  ),
  Pack(
    id: 'music',
    name: 'Music',
    icon: '🎵',
    description: 'Hits & hidden gems',
    status: PackStatus.locked,
    unlockCondition: '7-day streak',
  ),
  Pack(
    id: 'sports',
    name: 'Sports',
    icon: '⚽',
    description: 'Legendary moments',
    status: PackStatus.comingSoon,
  ),
  Pack(
    id: 'travel',
    name: 'Travel',
    icon: '✈️',
    description: 'Around the world',
    status: PackStatus.comingSoon,
  ),
];
