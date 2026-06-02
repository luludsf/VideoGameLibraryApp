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
    func fetchFavoriteGamesEmitsLoadingAndContentStates() async {
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

        if case .loading = receivedStates[0] {
        } else {
            Issue.record("Expected first state to be loading")
        }

        if case let .content(items, _, _) = receivedStates[1] {
            #expect(items == [favoriteGame])
        } else {
            Issue.record("Expected content state")
        }
    }

    @Test
    func fetchFavoriteGamesEmitsErrorStateWhenStoreFails() async {
        let favoriteGamesStore = FavoriteGamesStoreSpy(
            favoriteGamesResult: .failure(TestLocalizedError(errorDescription: "Favorites failed"))
        )
        let sut = FavoritesViewModel(favoriteGamesStore: favoriteGamesStore)
        var receivedStates: [ScreenState<GameItem>] = []

        sut.onStateChange = { state in
            receivedStates.append(state)
        }

        await sut.fetchFavoriteGames()

        #expect(receivedStates.count == 2)

        if case .loading = receivedStates[0] {
        } else {
            Issue.record("Expected first state to be loading")
        }

        if case .error(let message) = receivedStates[1] {
            #expect(message == "Favorites failed")
        } else {
            Issue.record("Expected error state")
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

    @Test
    func toggleFavoriteAddsGameAndEmitsContentState() async {
        let addedFavorite = GameItem(
            id: "1",
            title: "Mario",
            imageURL: URL(string: "https://images.igdb.com/igdb/image/upload/t_cover_big/co1.jpg"),
            isFavorite: true
        )
        let gameToFavorite = addedFavorite.updatingFavorite(to: false)
        let favoriteGamesStore = FavoriteGamesStoreSpy(
            favoriteGamesResult: .success([addedFavorite])
        )
        let sut = FavoritesViewModel(favoriteGamesStore: favoriteGamesStore)
        var receivedStates: [ScreenState<GameItem>] = []

        sut.onStateChange = { state in
            receivedStates.append(state)
        }

        await sut.toggleFavorite(for: gameToFavorite)

        #expect(favoriteGamesStore.saveFavoriteCallCount == 1)
        #expect(favoriteGamesStore.savedGames.first?.id == "1")

        if case let .content(items, isLoadingNextPage, paginationErrorMessage) = receivedStates.last {
            #expect(items == [addedFavorite])
            #expect(isLoadingNextPage == false)
            #expect(paginationErrorMessage == nil)
        } else {
            Issue.record("Expected content state after adding favorite")
        }
    }

    @Test
    func toggleFavoriteEmitsErrorStateWhenStoreFails() async {
        let favoriteGame = GameItem(
            id: "1",
            title: "Mario",
            imageURL: URL(string: "https://images.igdb.com/igdb/image/upload/t_cover_big/co1.jpg"),
            isFavorite: true
        )
        let favoriteGamesStore = FavoriteGamesStoreSpy()
        favoriteGamesStore.removeFavoriteError = TestLocalizedError(errorDescription: "Remove failed")
        let sut = FavoritesViewModel(favoriteGamesStore: favoriteGamesStore)
        var receivedStates: [ScreenState<GameItem>] = []

        sut.onStateChange = { state in
            receivedStates.append(state)
        }

        await sut.toggleFavorite(for: favoriteGame)

        if case .error(let message) = receivedStates.last {
            #expect(message == "Remove failed")
        } else {
            Issue.record("Expected error state after favorite toggle failure")
        }
    }
}
