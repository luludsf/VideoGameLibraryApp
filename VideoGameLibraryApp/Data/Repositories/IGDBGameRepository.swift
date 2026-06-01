//
//  IGDBGameRepository.swift
//  VideoGameLibraryApp
//
//  Created by Luana Duarte on 31/05/26.
//

import Foundation
import NetworkingKit

final class IGDBGameRepository: GameRepositoryProtocol {
    private let networking: Networking

    init(networking: Networking = URLSessionClient()) {
        self.networking = networking
    }

    func fetchGames(searchQuery: String?, offset: Int, limit: Int) async throws -> GamesPage {
        let gamesResponse: [IGDBGameResponse]

        do {
            gamesResponse = try await networking.perform(
                IGDBGamesRequest(searchQuery: searchQuery, offset: offset, limit: limit)
            )
        } catch let error as NetworkingError {
            throw GameListRequestError(networkingError: error)
        }

        let games = gamesResponse.map { game in
            GameItem(
                id: String(game.id),
                title: game.name,
                imageURL: game.cover?.imageURL,
                summary: game.summary,
                rating: game.rating ?? game.totalRating,
                platforms: game.platforms?.map(\.name) ?? [],
                isFavorite: false
            )
        }

        let nextOffset = games.count < limit ? nil : offset + games.count
        return GamesPage(items: games, nextOffset: nextOffset)
    }
}
