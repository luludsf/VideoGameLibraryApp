//
//  FavoriteGamesRepository.swift
//  VideoGameLibraryApp
//
//  Created by Luana Duarte on 31/05/26.
//

import Foundation

protocol FavoriteGamesRepositoryProtocol {
    func fetchFavoriteGames() async throws -> [GameItem]
    func fetchFavoriteGameIDs() async throws -> Set<String>
    func saveFavorite(_ game: GameItem) async throws
    func removeFavorite(gameID: String) async throws
}
