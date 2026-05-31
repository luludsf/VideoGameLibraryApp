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
    
    private var games: [GameItem] = []
    private let fetchGamesUseCase: FetchGamesUseCase

    init(fetchGamesUseCase: FetchGamesUseCase) {
        self.fetchGamesUseCase = fetchGamesUseCase
    }
    
    func fetchGames() async {
        onStateChange?(.loading)

        do {
            let fetchedGames = try await self.fetchGamesUseCase.execute()
            self.games = fetchedGames

            if fetchedGames.isEmpty {
                self.onStateChange?(.empty)
            } else {
                self.onStateChange?(.success(fetchedGames))
            }
        } catch {
            self.onStateChange?(.error(error.localizedDescription))
        }
    }
    
    func toggleFavorite(for item: GameItem) {
        self.games = self.games.map { game in
            if game.id == item.id {
                return GameItem(id: game.id, title: game.title, imageURL: game.imageURL, isFavorite: !game.isFavorite)
            }
            return game
        }
        
        onStateChange?(.success(self.games))
    }
}
