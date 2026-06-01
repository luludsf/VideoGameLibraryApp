//
//  GameListViewModel.swift
//  VideoGameLibraryApp
//
//  Created by Luana Duarte on 30/05/26.
//

import Foundation

@MainActor
final class GameListViewModel {
    var onStateChange: ((ScreenState<GameItem>) -> Void)?
    var onPaginationLoadingStateChange: ((Bool) -> Void)?
    var onPaginationError: ((String) -> Void)?
    
    private let pageSize = 25
    private var games: [GameItem] = []
    private var lastLoadedSearchQuery: String?
    private var hasLoadedFirstPage = false
    private var nextOffset: Int?
    private var isLoadingNextPage = false
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
        guard shouldFetchFirstPage(for: normalizedSearchQuery) else { return }

        games = []
        nextOffset = nil
        onStateChange?(.loading)

        do {
            let firstPage = try await fetchPage(searchQuery: normalizedSearchQuery, offset: 0)
            games = firstPage.items
            nextOffset = firstPage.nextOffset
            lastLoadedSearchQuery = normalizedSearchQuery
            hasLoadedFirstPage = true

            if games.isEmpty {
                onStateChange?(.empty)
            } else {
                onStateChange?(.success(games))
            }
        } catch {
            nextOffset = nil
            onStateChange?(.error(error.localizedDescription))
        }
    }

    func loadNextPage() async {
        guard let nextOffset,
              !games.isEmpty,
              !isLoadingNextPage else {
            return
        }

        isLoadingNextPage = true
        onPaginationLoadingStateChange?(true)

        defer {
            isLoadingNextPage = false
            onPaginationLoadingStateChange?(false)
        }

        do {
            let nextPage = try await fetchPage(searchQuery: lastLoadedSearchQuery, offset: nextOffset)
            appendPageItems(nextPage.items)
            self.nextOffset = nextPage.nextOffset
            onStateChange?(.success(games))
        } catch {
            onPaginationError?(error.localizedDescription)
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

    private func shouldFetchFirstPage(for searchQuery: String?) -> Bool {
        guard hasLoadedFirstPage else { return true }
        return searchQuery != lastLoadedSearchQuery
    }

    private func fetchPage(searchQuery: String?, offset: Int) async throws -> GamesPage {
        let page = try await fetchGamesUseCase.execute(
            searchQuery: searchQuery,
            offset: offset,
            limit: pageSize
        )
        let favoriteGameIDs = try await favoriteGamesStore.fetchFavoriteGameIDs()
        return GamesPage(
            items: applyFavoriteState(to: page.items, favoriteGameIDs: favoriteGameIDs),
            nextOffset: page.nextOffset
        )
    }

    private func appendPageItems(_ newItems: [GameItem]) {
        let existingIDs = Set(games.map(\.id))
        let uniqueNewItems = newItems.filter { !existingIDs.contains($0.id) }
        games.append(contentsOf: uniqueNewItems)
    }

    private func applyFavoriteState(to games: [GameItem], favoriteGameIDs: Set<String>) -> [GameItem] {
        games.map { game in
            game.updatingFavorite(to: favoriteGameIDs.contains(game.id))
        }
    }
}
