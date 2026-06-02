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
    func fetchGamesEmitsLoadingAndContentStates() async {
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

        if case let .content(games, isLoadingNextPage, paginationErrorMessage) = receivedStates[1] {
            #expect(games == expectedGames)
            #expect(isLoadingNextPage == false)
            #expect(paginationErrorMessage == nil)
        } else {
            Issue.record("Expected second state to be content")
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
    func toggleFavoriteEmitsUpdatedContentState() async {
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

        if case let .content(games, isLoadingNextPage, paginationErrorMessage) = receivedStates[2] {
            #expect(games.count == 1)
            #expect(games[0].isFavorite == true)
            #expect(isLoadingNextPage == false)
            #expect(paginationErrorMessage == nil)
            #expect(favoriteGamesStore.saveFavoriteCallCount == 1)
            #expect(favoriteGamesStore.savedGames.first?.isFavorite == false)
        } else {
            Issue.record("Expected third state to be content")
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
    func fetchGamesMarksPersistedFavoritesInContentState() async {
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

        if case let .content(games, _, _) = receivedStates[1] {
            #expect(games.first?.isFavorite == true)
        } else {
            Issue.record("Expected content state")
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

        if let lastState = receivedStates.last, case let .content(games, _, paginationErrorMessage) = lastState {
            #expect(games.first?.isFavorite == true)
            #expect(paginationErrorMessage == nil)
        } else {
            Issue.record("Expected updated content state")
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
        #expect(receivedStates.count == 4)

        if case let .content(_, isLoadingNextPage, _) = receivedStates[2] {
            #expect(isLoadingNextPage == true)
        } else {
            Issue.record("Expected intermediate pagination loading content state")
        }

        if let lastState = receivedStates.last, case let .content(games, isLoadingNextPage, paginationErrorMessage) = lastState {
            #expect(games.map(\.id) == ["1", "2"])
            #expect(isLoadingNextPage == false)
            #expect(paginationErrorMessage == nil)
        } else {
            Issue.record("Expected final state to be content")
        }
    }

    @MainActor
    @Test
    func loadNextPageEmitsPaginationErrorInsideContentStateWithoutReplacingCurrentContent() async {
        let firstGame = GameItem(id: "1", title: "Mario", imageURL: nil, isFavorite: false)
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
        useCase.result = .failure(TestLocalizedError(errorDescription: "Page failed"))

        await sut.loadNextPage()

        #expect(receivedStates.count == 4)

        if let lastState = receivedStates.last, case let .content(games, isLoadingNextPage, paginationErrorMessage) = lastState {
            #expect(games.map(\.id) == ["1"])
            #expect(isLoadingNextPage == false)
            #expect(paginationErrorMessage == "Page failed")
        } else {
            Issue.record("Expected content state with pagination error")
        }
    }

    @MainActor
    @Test
    func loadNextPageDoesNothingWhenThereIsNoNextOffset() async {
        let firstGame = GameItem(id: "1", title: "Mario", imageURL: nil, isFavorite: false)
        let useCase = FetchGamesUseCaseSpy(
            result: .success(GamesPage(items: [firstGame], nextOffset: nil))
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
        await sut.loadNextPage()

        #expect(useCase.executeCallCount == 1)
        #expect(receivedStates.count == 2)
    }

    @MainActor
    @Test
    func loadNextPageDeduplicatesItemsReturnedByTheNextPage() async {
        let firstGame = GameItem(id: "1", title: "Mario", imageURL: nil, isFavorite: false)
        let duplicateFirstGame = GameItem(id: "1", title: "Mario", imageURL: nil, isFavorite: false)
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
        useCase.result = .success(GamesPage(items: [duplicateFirstGame, secondGame], nextOffset: nil))

        await sut.loadNextPage()

        if let lastState = receivedStates.last, case let .content(games, _, _) = lastState {
            #expect(games.map(\.id) == ["1", "2"])
        } else {
            Issue.record("Expected content state with deduplicated items")
        }
    }

    @MainActor
    @Test
    func toggleFavoriteEmitsPaginationErrorWhenFavoriteUpdateFailsAndThereIsContent() async {
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
        favoriteGamesStore.saveFavoriteError = TestLocalizedError(errorDescription: "Save failed")
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

        if let lastState = receivedStates.last, case let .content(games, isLoadingNextPage, paginationErrorMessage) = lastState {
            #expect(games == [initialGame])
            #expect(isLoadingNextPage == false)
            #expect(paginationErrorMessage == "Save failed")
        } else {
            Issue.record("Expected content state with favorite update error")
        }
    }

    @MainActor
    @Test
    func refreshFavoriteStatesEmitsPaginationErrorWhenStoreFails() async {
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
        favoriteGamesStore.favoriteGameIDsResult = .failure(TestLocalizedError(errorDescription: "Refresh failed"))
        await sut.refreshFavoriteStates()

        if let lastState = receivedStates.last, case let .content(games, _, paginationErrorMessage) = lastState {
            #expect(games == [remoteGame])
            #expect(paginationErrorMessage == "Refresh failed")
        } else {
            Issue.record("Expected content state with refresh error")
        }
    }
}
