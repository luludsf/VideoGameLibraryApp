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
        let expectedPage = GamesPage(items: expectedGames, nextOffset: 25)
        let repository = GameRepositorySpy(result: .success(expectedPage))
        let sut = FetchGamesUseCase(repository: repository)
        
        let page = try await sut.execute(searchQuery: nil, offset: 0, limit: 25)
        
        #expect(repository.fetchGamesCallCount == 1)
        #expect(repository.receivedSearchQueries == [nil])
        #expect(repository.receivedOffsets == [0])
        #expect(repository.receivedLimits == [25])
        #expect(page == expectedPage)
    }

    @Test
    func executePropagatesRepositoryError() async {
        let repository = GameRepositorySpy(result: .failure(TestLocalizedError(errorDescription: "Repository failed")))
        let sut = FetchGamesUseCase(repository: repository)

        do {
            _ = try await sut.execute(searchQuery: "Zelda", offset: 25, limit: 25)
            Issue.record("Expected execute to throw")
        } catch {
            #expect(error.localizedDescription == "Repository failed")
        }
    }
}
