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
        let useCase = FetchGamesUseCaseSpy(result: .success(expectedGames))
        let sut = GameListViewModel(fetchGamesUseCase: useCase)
        var receivedStates: [ScreenState<GameItem>] = []

        sut.onStateChange = { state in
            receivedStates.append(state)
        }

        await sut.fetchGames()

        #expect(useCase.executeCallCount == 1)
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
        let useCase = FetchGamesUseCaseSpy(result: .success([]))
        let sut = GameListViewModel(fetchGamesUseCase: useCase)
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
        let useCase = FetchGamesUseCaseSpy(result: .failure(TestLocalizedError(errorDescription: "Falhou")))
        let sut = GameListViewModel(fetchGamesUseCase: useCase)
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
            #expect(message == "Falhou")
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
        let useCase = FetchGamesUseCaseSpy(result: .success([initialGame]))
        let sut = GameListViewModel(fetchGamesUseCase: useCase)
        var receivedStates: [ScreenState<GameItem>] = []

        sut.onStateChange = { state in
            receivedStates.append(state)
        }

        await sut.fetchGames()
        sut.toggleFavorite(for: initialGame)

        #expect(receivedStates.count == 3)

        if case .success(let games) = receivedStates[2] {
            #expect(games.count == 1)
            #expect(games[0].isFavorite == true)
        } else {
            Issue.record("Expected third state to be success")
        }
    }

    @MainActor
    @Test
    func toggleFavoriteUpdatesOnlyTheTargetItemWhenThereAreMultipleGames() async {
        let targetGame = GameItem(
            id: "1",
            title: "Mario",
            imageURL: URL(string: "https://images.igdb.com/igdb/image/upload/t_cover_big/co1.jpg"),
            isFavorite: false
        )
        let untouchedGame = GameItem(
            id: "2",
            title: "Zelda",
            imageURL: URL(string: "https://images.igdb.com/igdb/image/upload/t_cover_big/co2.jpg"),
            isFavorite: false
        )
        let useCase = FetchGamesUseCaseSpy(result: .success([targetGame, untouchedGame]))
        let sut = GameListViewModel(fetchGamesUseCase: useCase)
        var receivedStates: [ScreenState<GameItem>] = []

        sut.onStateChange = { state in
            receivedStates.append(state)
        }

        await sut.fetchGames()
        sut.toggleFavorite(for: targetGame)

        #expect(receivedStates.count == 3)

        if case .success(let games) = receivedStates[2] {
            #expect(games.count == 2)
            #expect(games[0].id == "1")
            #expect(games[0].isFavorite == true)
            #expect(games[1].id == "2")
            #expect(games[1].isFavorite == false)
        } else {
            Issue.record("Expected third state to be success")
        }
    }
}
