//
//  FetchGamesUseCase.swift
//  VideoGameLibraryApp
//
//  Created by Luana Duarte on 31/05/26.
//

import Foundation

protocol FetchGamesUseCaseProtocol {
    func execute(searchQuery: String?, offset: Int, limit: Int) async throws -> GamesPage
}

struct FetchGamesUseCase: FetchGamesUseCaseProtocol {
    private let repository: GameRepositoryProtocol

    init(repository: GameRepositoryProtocol) {
        self.repository = repository
    }

    func execute(searchQuery: String?, offset: Int, limit: Int) async throws -> GamesPage {
        try await repository.fetchGames(searchQuery: searchQuery, offset: offset, limit: limit)
    }
}
