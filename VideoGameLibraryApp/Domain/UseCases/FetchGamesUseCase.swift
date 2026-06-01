//
//  FetchGamesUseCase.swift
//  VideoGameLibraryApp
//
//  Created by Luana Duarte on 31/05/26.
//

import Foundation

protocol FetchGamesUseCase {
    func execute(searchQuery: String?, offset: Int, limit: Int) async throws -> GamesPage
}

struct DefaultFetchGamesUseCase: FetchGamesUseCase {
    private let repository: GameRepository

    init(repository: GameRepository) {
        self.repository = repository
    }

    func execute(searchQuery: String?, offset: Int, limit: Int) async throws -> GamesPage {
        try await repository.fetchGames(searchQuery: searchQuery, offset: offset, limit: limit)
    }
}
