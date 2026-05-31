//
//  FetchGamesUseCase.swift
//  VideoGameLibraryApp
//
//  Created by Luana Duarte on 31/05/26.
//

import Foundation

protocol FetchGamesUseCase {
    func execute(searchQuery: String?) async throws -> [GameItem]
}

struct DefaultFetchGamesUseCase: FetchGamesUseCase {
    private let repository: GameRepository

    init(repository: GameRepository) {
        self.repository = repository
    }

    func execute(searchQuery: String?) async throws -> [GameItem] {
        try await repository.fetchGames(searchQuery: searchQuery)
    }
}
