import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// State for local favorites
class LocalFavoritesState {
  final Set<String> favoriteIds;
  final bool isLoading;

  const LocalFavoritesState({
    this.favoriteIds = const {},
    this.isLoading = false,
  });

  LocalFavoritesState copyWith({Set<String>? favoriteIds, bool? isLoading}) {
    return LocalFavoritesState(
      favoriteIds: favoriteIds ?? this.favoriteIds,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  bool isFavorite(String serviceId) => favoriteIds.contains(serviceId);
}

/// StateNotifier for managing local favorites
class LocalFavoritesNotifier extends StateNotifier<LocalFavoritesState> {
  static const String _favoritesKey = 'user_favorite_services';

  LocalFavoritesNotifier() : super(const LocalFavoritesState(isLoading: true)) {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = prefs.getStringList(_favoritesKey) ?? [];
      state = state.copyWith(favoriteIds: favorites.toSet(), isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> addFavorite(String serviceId) async {
    final newFavorites = {...state.favoriteIds, serviceId};
    state = state.copyWith(favoriteIds: newFavorites);
    await _saveFavorites();
  }

  Future<void> removeFavorite(String serviceId) async {
    final newFavorites = {...state.favoriteIds}..remove(serviceId);
    state = state.copyWith(favoriteIds: newFavorites);
    await _saveFavorites();
  }

  Future<bool> toggleFavorite(String serviceId) async {
    if (state.favoriteIds.contains(serviceId)) {
      await removeFavorite(serviceId);
      return false;
    } else {
      await addFavorite(serviceId);
      return true;
    }
  }

  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_favoritesKey, state.favoriteIds.toList());
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> clearFavorites() async {
    state = state.copyWith(favoriteIds: {});
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_favoritesKey);
  }
}

/// Provider for local favorites
final localFavoritesProvider =
    StateNotifierProvider<LocalFavoritesNotifier, LocalFavoritesState>((ref) {
      return LocalFavoritesNotifier();
    });
