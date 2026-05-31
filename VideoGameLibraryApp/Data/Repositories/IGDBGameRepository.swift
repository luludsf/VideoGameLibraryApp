//
//  IGDBGameRepository.swift
//  VideoGameLibraryApp
//
//  Created by Luana Duarte on 31/05/26.
//

import Foundation
import NetworkingKit

final class IGDBGameRepository: GameRepository {
    private let networking: Networking

    init(networking: Networking = URLSessionClient()) {
        self.networking = networking
    }

    func fetchGames(searchQuery: String?) async throws -> [GameItem] {
        let gamesResponse: [IGDBGameResponse]

        do {
            gamesResponse = try await networking.perform(IGDBGamesRequest(searchQuery: searchQuery))
        } catch let error as NetworkingError {
            throw GameListRequestError(networkingError: error)
        }

        return gamesResponse.map { game in
            GameItem(
                id: String(game.id),
                title: game.name,
                imageURL: game.cover?.imageURL,
                isFavorite: false
            )
        }
    }
}
