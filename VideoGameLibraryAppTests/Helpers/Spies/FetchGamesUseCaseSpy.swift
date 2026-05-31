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
    var result: Result<[GameItem], Error>

    init(result: Result<[GameItem], Error>) {
        self.result = result
    }

    func execute() async throws -> [GameItem] {
        executeCallCount += 1
        return try result.get()
    }
}
