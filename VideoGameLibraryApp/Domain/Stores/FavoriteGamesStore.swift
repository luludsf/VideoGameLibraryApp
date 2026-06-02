//
//  FavoriteGamesStore.swift
//  VideoGameLibraryApp
//
//  Created by Luana Duarte on 31/05/26.
//

import Foundation

@MainActor
protocol FavoriteGamesStoreProtocol {
    func fetchFavoriteGames() async throws -> [GameItem]
    func fetchFavoriteGameIDs() async throws -> Set<String>
    func saveFavorite(_ game: GameItem) async throws
    func removeFavorite(gameID: String) async throws
}

@MainActor
final class FavoriteGamesStore: FavoriteGamesStoreProtocol {
    private let repository: FavoriteGamesRepositoryProtocol
    private var favoriteGames: [GameItem] = []
    private var hasLoadedFavorites = false

    init(repository: FavoriteGamesRepositoryProtocol) {
        self.repository = repository
    }

    func fetchFavoriteGames() async throws -> [GameItem] {
        try await loadFavoritesIfNeeded()
        return favoriteGames
    }

    func fetchFavoriteGameIDs() async throws -> Set<String> {
        try await loadFavoritesIfNeeded()
        return Set(favoriteGames.map(\.id))
    }

    func saveFavorite(_ game: GameItem) async throws {
        let favoriteGame = game.updatingFavorite(to: true)
        try await repository.saveFavorite(favoriteGame)
        replaceOrInsertFavorite(favoriteGame)
        hasLoadedFavorites = true
    }

    func removeFavorite(gameID: String) async throws {
        try await repository.removeFavorite(gameID: gameID)
        favoriteGames.removeAll { $0.id == gameID }
        hasLoadedFavorites = true
    }

    private func loadFavoritesIfNeeded() async throws {
        guard !hasLoadedFavorites else { return }
        favoriteGames = try await repository.fetchFavoriteGames()
        hasLoadedFavorites = true
    }

    private func replaceOrInsertFavorite(_ favoriteGame: GameItem) {
        favoriteGames.removeAll { $0.id == favoriteGame.id }
        favoriteGames.insert(favoriteGame, at: 0)
    }
}
