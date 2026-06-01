//
//  GameRepositorySpy.swift
//  VideoGameLibraryAppTests
//
//  Created by Luana Duarte on 31/05/26.
//

import Foundation
@testable import VideoGameLibraryApp

final class GameRepositorySpy: GameRepositoryProtocol {
    var fetchGamesCallCount = 0
    var receivedSearchQueries: [String?] = []
    var receivedOffsets: [Int] = []
    var receivedLimits: [Int] = []
    var result: Result<GamesPage, Error>

    init(result: Result<GamesPage, Error>) {
        self.result = result
    }

    func fetchGames(searchQuery: String?, offset: Int, limit: Int) async throws -> GamesPage {
        fetchGamesCallCount += 1
        receivedSearchQueries.append(searchQuery)
        receivedOffsets.append(offset)
        receivedLimits.append(limit)
        return try result.get()
    }
}
