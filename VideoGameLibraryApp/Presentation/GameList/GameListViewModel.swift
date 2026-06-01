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
    private var lastExecutedSearchQuery: ExecutedSearchQuery = .none
    private let fetchGamesUseCase: FetchGamesUseCase
    private let favoriteGamesStore: FavoriteGamesStore

    init(
        fetchGamesUseCase: FetchGamesUseCase,
        favoriteGamesStore: FavoriteGamesStore
    ) {
        self.fetchGamesUseCase = fetchGamesUseCase
        self.favoriteGamesStore = favoriteGamesStore
    }
    
    func fetchGames(searchQuery: String? = nil) async {
        let normalizedSearchQuery = normalizedSearchQuery(from: searchQuery)
        let currentSearchQuery: ExecutedSearchQuery = .value(normalizedSearchQuery)
        guard currentSearchQuery != lastExecutedSearchQuery else { return }

        onStateChange?(.loading)

        do {
            let fetchedGames = try await self.fetchGamesUseCase.execute(searchQuery: normalizedSearchQuery)
            let favoriteGameIDs = try await favoriteGamesStore.fetchFavoriteGameIDs()
            self.games = applyFavoriteState(to: fetchedGames, favoriteGameIDs: favoriteGameIDs)
            self.lastExecutedSearchQuery = currentSearchQuery

            if games.isEmpty {
                self.onStateChange?(.empty)
            } else {
                self.onStateChange?(.success(games))
            }
        } catch {
            self.onStateChange?(.error(error.localizedDescription))
        }
    }
    
    func toggleFavorite(for item: GameItem) async {
        do {
            if item.isFavorite {
                try await favoriteGamesStore.removeFavorite(gameID: item.id)
            } else {
                try await favoriteGamesStore.saveFavorite(item)
            }

            self.games = self.games.map { game in
                guard game.id == item.id else { return game }
                return game.updatingFavorite(to: !item.isFavorite)
            }

            onStateChange?(.success(self.games))
        } catch {
            onStateChange?(.error(error.localizedDescription))
        }
    }

    func refreshFavoriteStates() async {
        guard !games.isEmpty else { return }

        do {
            let favoriteGameIDs = try await favoriteGamesStore.fetchFavoriteGameIDs()
            games = applyFavoriteState(to: games, favoriteGameIDs: favoriteGameIDs)
            onStateChange?(.success(games))
        } catch {
            onStateChange?(.error(error.localizedDescription))
        }
    }

    private func normalizedSearchQuery(from searchQuery: String?) -> String? {
        guard let searchQuery = searchQuery?.trimmingCharacters(in: .whitespacesAndNewlines),
              !searchQuery.isEmpty else {
            return nil
        }

        return searchQuery
    }

    private func applyFavoriteState(to games: [GameItem], favoriteGameIDs: Set<String>) -> [GameItem] {
        games.map { game in
            game.updatingFavorite(to: favoriteGameIDs.contains(game.id))
        }
    }
}
