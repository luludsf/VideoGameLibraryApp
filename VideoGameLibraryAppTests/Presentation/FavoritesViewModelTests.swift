//
//  FavoritesViewModelTests.swift
//  VideoGameLibraryAppTests
//
//  Created by Luana Duarte on 31/05/26.
//

import Foundation
import Testing
@testable import VideoGameLibraryApp

    @MainActor
    struct FavoritesViewModelTests {
    @Test
    func fetchFavoriteGamesEmitsSuccessState() async {
        let favoriteGame = GameItem(
            id: "1",
            title: "Mario",
            imageURL: URL(string: "https://images.igdb.com/igdb/image/upload/t_cover_big/co1.jpg"),
            isFavorite: true
        )
        let favoriteGamesStore = FavoriteGamesStoreSpy(
            favoriteGamesResult: .success([favoriteGame])
        )
        let sut = FavoritesViewModel(favoriteGamesStore: favoriteGamesStore)
        var receivedStates: [ScreenState<GameItem>] = []

        sut.onStateChange = { state in
            receivedStates.append(state)
        }

        await sut.fetchFavoriteGames()

        #expect(favoriteGamesStore.fetchFavoriteGamesCallCount == 1)
        #expect(receivedStates.count == 2)

        if case let .content(items, _, _) = receivedStates[1] {
            #expect(items == [favoriteGame])
        } else {
            Issue.record("Expected content state")
        }
    }

    @Test
    func toggleFavoriteRemovesGameAndEmitsEmptyStateWhenRepositoryBecomesEmpty() async {
        let favoriteGame = GameItem(
            id: "1",
            title: "Mario",
            imageURL: URL(string: "https://images.igdb.com/igdb/image/upload/t_cover_big/co1.jpg"),
            isFavorite: true
        )
        let favoriteGamesStore = FavoriteGamesStoreSpy(
            favoriteGamesResult: .success([])
        )
        let sut = FavoritesViewModel(favoriteGamesStore: favoriteGamesStore)
        var receivedStates: [ScreenState<GameItem>] = []

        sut.onStateChange = { state in
            receivedStates.append(state)
        }

        await sut.toggleFavorite(for: favoriteGame)

        #expect(favoriteGamesStore.removeFavoriteCallCount == 1)
        #expect(favoriteGamesStore.removedGameIDs == ["1"])

        if case .empty = receivedStates.last {
        } else {
            Issue.record("Expected empty state after removing last favorite")
        }
    }
}
