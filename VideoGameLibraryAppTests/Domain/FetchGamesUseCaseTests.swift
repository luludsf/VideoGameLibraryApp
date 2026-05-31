//
//  FetchGamesUseCaseTests.swift
//  VideoGameLibraryAppTests
//
//  Created by Luana Duarte on 31/05/26.
//

import Testing
@testable import VideoGameLibraryApp
import Foundation

@MainActor
struct FetchGamesUseCaseTests {
    @Test
    func executeDelegatesToRepository() async throws {
        let expectedGames = [
            GameItem(
                id: "1",
                title: "Mario",
                imageURL: URL(string: "https://images.igdb.com/igdb/image/upload/t_cover_big/co1.jpg"),
                isFavorite: false
            )
        ]
        let repository = GameRepositorySpy(result: .success(expectedGames))
        let sut = DefaultFetchGamesUseCase(repository: repository)
        
        let games = try await sut.execute(searchQuery: nil)
        
        #expect(repository.fetchGamesCallCount == 1)
        #expect(repository.receivedSearchQueries == [nil])
        #expect(games == expectedGames)
    }
}
