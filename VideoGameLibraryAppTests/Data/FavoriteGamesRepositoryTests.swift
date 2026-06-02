//
//  FavoriteGamesRepositoryTests.swift
//  VideoGameLibraryAppTests
//
//  Created by Luana Duarte on 31/05/26.
//

import Foundation
import SwiftData
import Testing
@testable import VideoGameLibraryApp

@MainActor
@Suite(.serialized)
struct FavoriteGamesRepositoryTests {
    @Test
    func saveFavoritePersistsAndFetchesGame() async throws {
        let sut = makeRepository()
        let game = GameItem(
            id: "1",
            title: "Mario",
            imageURL: URL(string: "https://images.igdb.com/igdb/image/upload/t_cover_big/co1.jpg"),
            summary: "Um classico de plataforma.",
            rating: 94.0,
            platforms: ["NES", "Switch"],
            isFavorite: true
        )

        try await sut.saveFavorite(game)
        let favorites = try await sut.fetchFavoriteGames()

        #expect(favorites.count == 1)
        #expect(favorites[0].id == "1")
        #expect(favorites[0].title == "Mario")
        #expect(favorites[0].summary == "Um classico de plataforma.")
        #expect(favorites[0].rating == 94.0)
        #expect(favorites[0].platforms == ["NES", "Switch"])
        #expect(favorites[0].isFavorite == true)
    }

    @Test
    func removeFavoriteDeletesPersistedGame() async throws {
        let sut = makeRepository()
        let game = GameItem(
            id: "1",
            title: "Mario",
            imageURL: URL(string: "https://images.igdb.com/igdb/image/upload/t_cover_big/co1.jpg"),
            isFavorite: true
        )

        try await sut.saveFavorite(game)
        try await sut.removeFavorite(gameID: "1")

        #expect(try await sut.fetchFavoriteGames().isEmpty)
        #expect(try await sut.fetchFavoriteGameIDs().isEmpty)
    }

    private func makeRepository() -> FavoriteGamesRepository {
        let configuration = ModelConfiguration(
            "FavoriteGamesRepositoryTests-\(UUID().uuidString)",
            schema: nil,
            isStoredInMemoryOnly: true
        )
        let container = try! ModelContainer(for: FavoriteGameObj.self, configurations: configuration)
        return FavoriteGamesRepository(modelContainer: container)
    }
}
