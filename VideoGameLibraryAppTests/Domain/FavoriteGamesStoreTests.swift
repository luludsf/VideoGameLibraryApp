//
//  FavoriteGamesStoreTests.swift
//  VideoGameLibraryAppTests
//
//  Created by Luana Duarte on 31/05/26.
//

import Foundation
import Testing
@testable import VideoGameLibraryApp

@MainActor
struct FavoriteGamesStoreTests {
    @Test
    func fetchFavoriteGameIDsLoadsPersistedFavorites() async throws {
        let favoriteGame = GameItem(
            id: "1",
            title: "Mario",
            imageURL: URL(string: "https://images.igdb.com/igdb/image/upload/t_cover_big/co1.jpg"),
            isFavorite: true
        )
        let repository = FavoriteGamesRepositorySpy(
            favoriteGamesResult: .success([favoriteGame])
        )
        let sut = FavoriteGamesStore(repository: repository)

        let favoriteGameIDs = try await sut.fetchFavoriteGameIDs()

        #expect(repository.fetchFavoriteGamesCallCount == 1)
        #expect(favoriteGameIDs == ["1"])
    }

    @Test
    func saveFavoriteUpdatesCachedFavoritesAndPersistsFavoriteState() async throws {
        let game = GameItem(
            id: "1",
            title: "Mario",
            imageURL: URL(string: "https://images.igdb.com/igdb/image/upload/t_cover_big/co1.jpg"),
            isFavorite: false
        )
        let repository = FavoriteGamesRepositorySpy()
        let sut = FavoriteGamesStore(repository: repository)

        try await sut.saveFavorite(game)

        let favorites = try await sut.fetchFavoriteGames()

        #expect(repository.saveFavoriteCallCount == 1)
        #expect(repository.savedGames.first?.isFavorite == true)
        #expect(favorites == [game.updatingFavorite(to: true)])
        #expect(repository.fetchFavoriteGamesCallCount == 0)
    }

    @Test
    func removeFavoriteUpdatesCachedFavorites() async throws {
        let favoriteGame = GameItem(
            id: "1",
            title: "Mario",
            imageURL: URL(string: "https://images.igdb.com/igdb/image/upload/t_cover_big/co1.jpg"),
            isFavorite: true
        )
        let repository = FavoriteGamesRepositorySpy(
            favoriteGamesResult: .success([favoriteGame])
        )
        let sut = FavoriteGamesStore(repository: repository)

        _ = try await sut.fetchFavoriteGames()
        try await sut.removeFavorite(gameID: "1")

        let favorites = try await sut.fetchFavoriteGames()

        #expect(repository.removeFavoriteCallCount == 1)
        #expect(favorites.isEmpty)
    }
}
