//
//  GameListViewModelTests.swift
//  VideoGameLibraryAppTests
//
//  Created by Luana Duarte on 31/05/26.
//

import Foundation
import Testing
@testable import VideoGameLibraryApp

struct GameListViewModelTests {
    @MainActor
    @Test
    func fetchGamesEmitsLoadingAndSuccessStates() async {
        let expectedGames = [
            GameItem(
                id: "1",
                title: "Mario",
                imageURL: URL(string: "https://images.igdb.com/igdb/image/upload/t_cover_big/co1.jpg"),
                isFavorite: false
            )
        ]
        let useCase = FetchGamesUseCaseSpy(
            result: .success(GamesPage(items: expectedGames, nextOffset: 25))
        )
        let favoriteGamesStore = FavoriteGamesStoreSpy(favoriteGameIDsResult: .success([]))
        let sut = GameListViewModel(
            fetchGamesUseCase: useCase,
            favoriteGamesStore: favoriteGamesStore
        )
        var receivedStates: [ScreenState<GameItem>] = []

        sut.onStateChange = { state in
            receivedStates.append(state)
        }

        await sut.fetchGames()

        #expect(useCase.executeCallCount == 1)
        #expect(useCase.receivedSearchQueries == [nil])
        #expect(useCase.receivedOffsets == [0])
        #expect(useCase.receivedLimits == [25])
        #expect(favoriteGamesStore.fetchFavoriteGameIDsCallCount == 1)
        #expect(receivedStates.count == 2)

        if case .loading = receivedStates[0] {
        } else {
            Issue.record("Expected first state to be loading")
        }

        if case .success(let games) = receivedStates[1] {
            #expect(games == expectedGames)
        } else {
            Issue.record("Expected second state to be success")
        }
    }

    @MainActor
    @Test
    func fetchGamesEmitsEmptyStateWhenUseCaseReturnsNoItems() async {
        let useCase = FetchGamesUseCaseSpy(result: .success(GamesPage(items: [], nextOffset: nil)))
        let sut = GameListViewModel(
            fetchGamesUseCase: useCase,
            favoriteGamesStore: FavoriteGamesStoreSpy()
        )
        var receivedStates: [ScreenState<GameItem>] = []

        sut.onStateChange = { state in
            receivedStates.append(state)
        }

        await sut.fetchGames()

        #expect(receivedStates.count == 2)

        if case .loading = receivedStates[0] {
        } else {
            Issue.record("Expected first state to be loading")
        }

        if case .empty = receivedStates[1] {
        } else {
            Issue.record("Expected second state to be empty")
        }
    }

    @MainActor
    @Test
    func fetchGamesEmitsErrorStateWhenUseCaseFails() async {
        let useCase = FetchGamesUseCaseSpy(result: .failure(TestLocalizedError(errorDescription: "Failed")))
        let sut = GameListViewModel(
            fetchGamesUseCase: useCase,
            favoriteGamesStore: FavoriteGamesStoreSpy()
        )
        var receivedStates: [ScreenState<GameItem>] = []

        sut.onStateChange = { state in
            receivedStates.append(state)
        }

        await sut.fetchGames()

        #expect(receivedStates.count == 2)

        if case .loading = receivedStates[0] {
        } else {
            Issue.record("Expected first state to be loading")
        }

        if case .error(let message) = receivedStates[1] {
            #expect(message == "Failed")
        } else {
            Issue.record("Expected second state to be error")
        }
    }

    @MainActor
    @Test
    func toggleFavoriteEmitsUpdatedSuccessState() async {
        let initialGame = GameItem(
            id: "1",
            title: "Mario",
            imageURL: URL(string: "https://images.igdb.com/igdb/image/upload/t_cover_big/co1.jpg"),
            isFavorite: false
        )
        let useCase = FetchGamesUseCaseSpy(
            result: .success(GamesPage(items: [initialGame], nextOffset: nil))
        )
        let favoriteGamesStore = FavoriteGamesStoreSpy()
        let sut = GameListViewModel(
            fetchGamesUseCase: useCase,
            favoriteGamesStore: favoriteGamesStore
        )
        var receivedStates: [ScreenState<GameItem>] = []

        sut.onStateChange = { state in
            receivedStates.append(state)
        }

        await sut.fetchGames()
        await sut.toggleFavorite(for: initialGame)

        #expect(receivedStates.count == 3)

        if case .success(let games) = receivedStates[2] {
            #expect(games.count == 1)
            #expect(games[0].isFavorite == true)
            #expect(favoriteGamesStore.saveFavoriteCallCount == 1)
            #expect(favoriteGamesStore.savedGames.first?.isFavorite == false)
        } else {
            Issue.record("Expected third state to be success")
        }
    }

    @MainActor
    @Test
    func fetchGamesPassesSearchQueryToUseCase() async {
        let useCase = FetchGamesUseCaseSpy(result: .success(GamesPage(items: [], nextOffset: nil)))
        let sut = GameListViewModel(
            fetchGamesUseCase: useCase,
            favoriteGamesStore: FavoriteGamesStoreSpy()
        )

        await sut.fetchGames(searchQuery: "Zelda")

        #expect(useCase.executeCallCount == 1)
        #expect(useCase.receivedSearchQueries == ["Zelda"])
        #expect(useCase.receivedOffsets == [0])
        #expect(useCase.receivedLimits == [25])
    }

    @MainActor
    @Test
    func fetchGamesNormalizesEmptySearchQueryBeforeExecutingUseCase() async {
        let useCase = FetchGamesUseCaseSpy(result: .success(GamesPage(items: [], nextOffset: nil)))
        let sut = GameListViewModel(
            fetchGamesUseCase: useCase,
            favoriteGamesStore: FavoriteGamesStoreSpy()
        )

        await sut.fetchGames(searchQuery: "   ")

        #expect(useCase.executeCallCount == 1)
        #expect(useCase.receivedSearchQueries == [nil])
    }

    @MainActor
    @Test
    func fetchGamesDoesNotExecuteAgainWhenNormalizedSearchQueryDoesNotChange() async {
        let useCase = FetchGamesUseCaseSpy(result: .success(GamesPage(items: [], nextOffset: nil)))
        let sut = GameListViewModel(
            fetchGamesUseCase: useCase,
            favoriteGamesStore: FavoriteGamesStoreSpy()
        )
        var receivedStates: [ScreenState<GameItem>] = []

        sut.onStateChange = { state in
            receivedStates.append(state)
        }

        await sut.fetchGames(searchQuery: "Zelda")
        await sut.fetchGames(searchQuery: "  Zelda  ")

        #expect(useCase.executeCallCount == 1)
        #expect(useCase.receivedSearchQueries == ["Zelda"])
        #expect(receivedStates.count == 2)
    }

    @MainActor
    @Test
    func fetchGamesMarksPersistedFavoritesInSuccessState() async {
        let remoteGame = GameItem(
            id: "1",
            title: "Mario",
            imageURL: URL(string: "https://images.igdb.com/igdb/image/upload/t_cover_big/co1.jpg"),
            isFavorite: false
        )
        let useCase = FetchGamesUseCaseSpy(
            result: .success(GamesPage(items: [remoteGame], nextOffset: nil))
        )
        let favoriteGamesStore = FavoriteGamesStoreSpy(
            favoriteGameIDsResult: .success(["1"])
        )
        let sut = GameListViewModel(
            fetchGamesUseCase: useCase,
            favoriteGamesStore: favoriteGamesStore
        )
        var receivedStates: [ScreenState<GameItem>] = []

        sut.onStateChange = { state in
            receivedStates.append(state)
        }

        await sut.fetchGames()

        if case .success(let games) = receivedStates[1] {
            #expect(games.first?.isFavorite == true)
        } else {
            Issue.record("Expected success state")
        }
    }

    @MainActor
    @Test
    func refreshFavoriteStatesUpdatesCurrentGamesFromRepository() async {
        let remoteGame = GameItem(
            id: "1",
            title: "Mario",
            imageURL: URL(string: "https://images.igdb.com/igdb/image/upload/t_cover_big/co1.jpg"),
            isFavorite: false
        )
        let useCase = FetchGamesUseCaseSpy(
            result: .success(GamesPage(items: [remoteGame], nextOffset: nil))
        )
        let favoriteGamesStore = FavoriteGamesStoreSpy(
            favoriteGameIDsResult: .success([])
        )
        let sut = GameListViewModel(
            fetchGamesUseCase: useCase,
            favoriteGamesStore: favoriteGamesStore
        )
        var receivedStates: [ScreenState<GameItem>] = []

        sut.onStateChange = { state in
            receivedStates.append(state)
        }

        await sut.fetchGames()
        favoriteGamesStore.favoriteGameIDsResult = .success(["1"])
        await sut.refreshFavoriteStates()

        if case .success(let games) = receivedStates.last {
            #expect(games.first?.isFavorite == true)
        } else {
            Issue.record("Expected updated success state")
        }
    }

    @MainActor
    @Test
    func loadNextPageAppendsItemsAndUsesNextOffset() async {
        let firstGame = GameItem(id: "1", title: "Mario", imageURL: nil, isFavorite: false)
        let secondGame = GameItem(id: "2", title: "Zelda", imageURL: nil, isFavorite: false)
        let useCase = FetchGamesUseCaseSpy(
            result: .success(GamesPage(items: [firstGame], nextOffset: 25))
        )
        let sut = GameListViewModel(
            fetchGamesUseCase: useCase,
            favoriteGamesStore: FavoriteGamesStoreSpy()
        )
        var receivedStates: [ScreenState<GameItem>] = []

        sut.onStateChange = { state in
            receivedStates.append(state)
        }

        await sut.fetchGames()
        useCase.result = .success(GamesPage(items: [secondGame], nextOffset: nil))

        await sut.loadNextPage()

        #expect(useCase.executeCallCount == 2)
        #expect(useCase.receivedSearchQueries == [nil, nil])
        #expect(useCase.receivedOffsets == [0, 25])
        #expect(useCase.receivedLimits == [25, 25])

        if let lastState = receivedStates.last, case .success(let games) = lastState {
            #expect(games.map(\.id) == ["1", "2"])
        } else {
            Issue.record("Expected final state to be success")
        }
    }

    @MainActor
    @Test
    func loadNextPageEmitsPaginationErrorWithoutReplacingCurrentContent() async {
        let firstGame = GameItem(id: "1", title: "Mario", imageURL: nil, isFavorite: false)
        let useCase = FetchGamesUseCaseSpy(
            result: .success(GamesPage(items: [firstGame], nextOffset: 25))
        )
        let sut = GameListViewModel(
            fetchGamesUseCase: useCase,
            favoriteGamesStore: FavoriteGamesStoreSpy()
        )
        var receivedStates: [ScreenState<GameItem>] = []
        var receivedPaginationErrors: [String] = []

        sut.onStateChange = { state in
            receivedStates.append(state)
        }
        sut.onPaginationError = { message in
            receivedPaginationErrors.append(message)
        }

        await sut.fetchGames()
        useCase.result = .failure(TestLocalizedError(errorDescription: "Page failed"))

        await sut.loadNextPage()

        #expect(receivedPaginationErrors == ["Page failed"])
        #expect(receivedStates.count == 2)

        if let lastState = receivedStates.last, case .success(let games) = lastState {
            #expect(games.map(\.id) == ["1"])
        } else {
            Issue.record("Expected content to remain unchanged after pagination error")
        }
    }
}
