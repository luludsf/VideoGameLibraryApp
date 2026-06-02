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

    @Test
    func saveFavoriteUpdatesExistingRecordInsteadOfDuplicatingIt() async throws {
        let sut = makeRepository()
        let originalGame = GameItem(
            id: "1",
            title: "Mario",
            imageURL: URL(string: "https://images.igdb.com/igdb/image/upload/t_cover_big/co1.jpg"),
            summary: "Original summary",
            rating: 80.0,
            platforms: ["NES"],
            isFavorite: true
        )
        let updatedGame = GameItem(
            id: "1",
            title: "Super Mario Bros.",
            imageURL: URL(string: "https://images.igdb.com/igdb/image/upload/t_cover_big/co2.jpg"),
            summary: "Updated summary",
            rating: 95.0,
            platforms: ["Switch"],
            isFavorite: true
        )

        try await sut.saveFavorite(originalGame)
        try await sut.saveFavorite(updatedGame)

        let favorites = try await sut.fetchFavoriteGames()

        #expect(favorites.count == 1)
        #expect(favorites[0].title == "Super Mario Bros.")
        #expect(favorites[0].summary == "Updated summary")
        #expect(favorites[0].rating == 95.0)
        #expect(favorites[0].platforms == ["Switch"])
        #expect(favorites[0].imageURL?.absoluteString == "https://images.igdb.com/igdb/image/upload/t_cover_big/co2.jpg")
    }

    @Test
    func fetchFavoriteGamesReturnsMostRecentlyFavoritedItemFirst() async throws {
        let sut = makeRepository()
        let olderGame = GameItem(id: "1", title: "Mario", imageURL: nil, isFavorite: true)
        let newerGame = GameItem(id: "2", title: "Zelda", imageURL: nil, isFavorite: true)

        try await sut.saveFavorite(olderGame)
        try await sut.saveFavorite(newerGame)

        let favorites = try await sut.fetchFavoriteGames()

        #expect(favorites.map(\.id) == ["2", "1"])
    }

    @Test
    func fetchFavoriteGameIDsReturnsPersistedIDs() async throws {
        let sut = makeRepository()
        let firstGame = GameItem(id: "1", title: "Mario", imageURL: nil, isFavorite: true)
        let secondGame = GameItem(id: "2", title: "Zelda", imageURL: nil, isFavorite: true)

        try await sut.saveFavorite(firstGame)
        try await sut.saveFavorite(secondGame)

        let ids = try await sut.fetchFavoriteGameIDs()

        #expect(ids == ["1", "2"])
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
