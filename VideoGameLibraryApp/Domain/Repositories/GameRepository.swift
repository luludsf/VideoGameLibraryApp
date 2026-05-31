//
//  GameRepository.swift
//  VideoGameLibraryApp
//
//  Created by Luana Duarte on 31/05/26.
//

import Foundation

protocol GameRepository {
    func fetchGames(searchQuery: String?) async throws -> [GameItem]
}
