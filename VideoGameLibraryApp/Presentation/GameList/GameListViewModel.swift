//
//  GameListViewModel.swift
//  VideoGameLibraryApp
//
//  Created by Luana Duarte on 30/05/26.
//

import Foundation

@MainActor
final class GameListViewModel {
    private enum ExecutedSearchQuery: Equatable {
        case none
        case value(String?)
    }

    var onStateChange: ((ScreenState<GameItem>) -> Void)?
    
    private var games: [GameItem] = []
    private var favoriteGameIDs = Set<String>()
    private var lastExecutedSearchQuery: ExecutedSearchQuery = .none
    private let fetchGamesUseCase: FetchGamesUseCase

    init(fetchGamesUseCase: FetchGamesUseCase) {
        self.fetchGamesUseCase = fetchGamesUseCase
    }
    
    func fetchGames(searchQuery: String? = nil) async {
        let normalizedSearchQuery = normalizedSearchQuery(from: searchQuery)
        let currentSearchQuery: ExecutedSearchQuery = .value(normalizedSearchQuery)
        guard currentSearchQuery != lastExecutedSearchQuery else { return }

        lastExecutedSearchQuery = currentSearchQuery
        onStateChange?(.loading)

        do {
            let fetchedGames = try await self.fetchGamesUseCase.execute(searchQuery: normalizedSearchQuery)
            self.games = applyFavoriteState(to: fetchedGames)

            if games.isEmpty {
                self.onStateChange?(.empty)
            } else {
                self.onStateChange?(.success(games))
            }
        } catch {
            self.onStateChange?(.error(error.localizedDescription))
        }
    }
    
    func toggleFavorite(for item: GameItem) {
        if favoriteGameIDs.contains(item.id) {
            favoriteGameIDs.remove(item.id)
        } else {
            favoriteGameIDs.insert(item.id)
        }

        self.games = self.games.map { game in
            if game.id == item.id {
                return GameItem(
                    id: game.id,
                    title: game.title,
                    imageURL: game.imageURL,
                    isFavorite: favoriteGameIDs.contains(game.id)
                )
            }
            return game
        }
        
        onStateChange?(.success(self.games))
    }

    private func normalizedSearchQuery(from searchQuery: String?) -> String? {
        guard let searchQuery = searchQuery?.trimmingCharacters(in: .whitespacesAndNewlines),
              !searchQuery.isEmpty else {
            return nil
        }

        return searchQuery
    }

    private func applyFavoriteState(to games: [GameItem]) -> [GameItem] {
        games.map { game in
            GameItem(
                id: game.id,
                title: game.title,
                imageURL: game.imageURL,
                isFavorite: favoriteGameIDs.contains(game.id)
            )
        }
    }
}
