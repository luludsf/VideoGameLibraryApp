//
//  SwiftDataFavoriteGamesRepositorySpy.swift
//  VideoGameLibraryAppTests
//
//  Created by Luana Duarte on 31/05/26.
//

import Foundation
@testable import VideoGameLibraryApp

final class SwiftDataFavoriteGamesRepositorySpy: SwiftDataFavoriteGamesRepositoryProtocol {
    var fetchFavoriteGamesCallCount = 0
    var fetchFavoriteGameIDsCallCount = 0
    var saveFavoriteCallCount = 0
    var removeFavoriteCallCount = 0
    var savedGames: [GameItem] = []
    var removedGameIDs: [String] = []

    var favoriteGamesResult: Result<[GameItem], Error>
    var favoriteGameIDsResult: Result<Set<String>, Error>
    var saveFavoriteError: Error?
    var removeFavoriteError: Error?

    init(
        favoriteGamesResult: Result<[GameItem], Error> = .success([]),
        favoriteGameIDsResult: Result<Set<String>, Error> = .success([])
    ) {
        self.favoriteGamesResult = favoriteGamesResult
        self.favoriteGameIDsResult = favoriteGameIDsResult
    }

    func fetchFavoriteGames() async throws -> [GameItem] {
        fetchFavoriteGamesCallCount += 1
        return try favoriteGamesResult.get()
    }

    func fetchFavoriteGameIDs() async throws -> Set<String> {
        fetchFavoriteGameIDsCallCount += 1
        return try favoriteGameIDsResult.get()
    }

    func saveFavorite(_ game: GameItem) async throws {
        saveFavoriteCallCount += 1
        savedGames.append(game)
        if let saveFavoriteError {
            throw saveFavoriteError
        }
    }

    func removeFavorite(gameID: String) async throws {
        removeFavoriteCallCount += 1
        removedGameIDs.append(gameID)
        if let removeFavoriteError {
            throw removeFavoriteError
        }
    }
}
