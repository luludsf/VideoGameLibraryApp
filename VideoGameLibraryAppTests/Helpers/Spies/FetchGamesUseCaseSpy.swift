//
//  FetchGamesUseCaseSpy.swift
//  VideoGameLibraryAppTests
//
//  Created by Luana Duarte on 31/05/26.
//

import Foundation
@testable import VideoGameLibraryApp

final class FetchGamesUseCaseSpy: FetchGamesUseCase {
    var executeCallCount = 0
    var receivedSearchQueries: [String?] = []
    var result: Result<[GameItem], Error>

    init(result: Result<[GameItem], Error>) {
        self.result = result
    }

    func execute(searchQuery: String?) async throws -> [GameItem] {
        executeCallCount += 1
        receivedSearchQueries.append(searchQuery)
        return try result.get()
    }
}
