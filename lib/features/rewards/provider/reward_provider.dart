import 'package:flutter/material.dart';
import '../model/badge_model.dart';
import '../ui/animation/badge_tier_rive.dart';

class RewardProvider extends ChangeNotifier {
  int _completedLists = 0;
  final Set<BadgeTier> _earnedTiers = {};

  /// Non-null while there is an unacknowledged completion to show.
  /// - [BadgeCompletion] → show badge unlock screen
  /// - [DefaultCompletion] → show plain checkmark screen
  /// - null → nothing pending
  CompletionEvent? _pendingCompletion;

  int get completedLists => _completedLists;
  CompletionEvent? get pendingCompletion => _pendingCompletion;

  void onListCompleted() {
    _completedLists += 1;

    final badge = BadgeDefinitions.unlockedAt(_completedLists);

    if (badge != null && !_earnedTiers.contains(badge.tier)) {
      _earnedTiers.add(badge.tier);
      _pendingCompletion = BadgeCompletion(badge);
    } else {
      _pendingCompletion = const DefaultCompletion();
    }

    notifyListeners();
  }

  void clearPendingCompletion() {
    _pendingCompletion = null;
    notifyListeners();
  }
}
