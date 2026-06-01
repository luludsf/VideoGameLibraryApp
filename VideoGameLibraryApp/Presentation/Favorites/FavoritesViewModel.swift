//
//  FavoritesViewModel.swift
//  VideoGameLibraryApp
//
//  Created by Luana Duarte on 31/05/26.
//

import Foundation

@MainActor
final class FavoritesViewModel {
    var onStateChange: ((ScreenState<GameItem>) -> Void)?

    private let favoriteGamesStore: FavoriteGamesStoreProtocol

    init(favoriteGamesStore: FavoriteGamesStoreProtocol) {
        self.favoriteGamesStore = favoriteGamesStore
    }

    func fetchFavoriteGames() async {
        onStateChange?(.loading)

        do {
            let favoriteGames = try await favoriteGamesStore.fetchFavoriteGames()
            if favoriteGames.isEmpty {
                onStateChange?(.empty)
            } else {
                onStateChange?(.success(favoriteGames))
            }
        } catch {
            onStateChange?(.error(error.localizedDescription))
        }
    }

    func toggleFavorite(for item: GameItem) async {
        do {
            if item.isFavorite {
                try await favoriteGamesStore.removeFavorite(gameID: item.id)
            } else {
                try await favoriteGamesStore.saveFavorite(item)
            }

            let updatedFavorites = try await favoriteGamesStore.fetchFavoriteGames()
            if updatedFavorites.isEmpty {
                onStateChange?(.empty)
            } else {
                onStateChange?(.success(updatedFavorites))
            }
        } catch {
            onStateChange?(.error(error.localizedDescription))
        }
    }
}
