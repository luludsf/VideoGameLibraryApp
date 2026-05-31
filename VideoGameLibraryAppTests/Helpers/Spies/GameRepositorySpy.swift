//
//  GameRepositorySpy.swift
//  VideoGameLibraryAppTests
//
//  Created by Luana Duarte on 31/05/26.
//

import Foundation
@testable import VideoGameLibraryApp

final class GameRepositorySpy: GameRepository {
    var fetchGamesCallCount = 0
    var result: Result<[GameItem], Error>

    init(result: Result<[GameItem], Error>) {
        self.result = result
    }

    func fetchGames() async throws -> [GameItem] {
        fetchGamesCallCount += 1
        return try result.get()
    }
}
