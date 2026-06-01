//
//  AppDependencyContainer.swift
//  VideoGameLibraryApp
//
//  Created by Luana Duarte on 31/05/26.
//

import UIKit
import NetworkingKit
import SwiftData

final class AppDependencyContainer: ViewControllerFactoryProtocol {
    private lazy var networking: Networking = URLSessionClient()
    private lazy var imageLoader: ImageLoading = ImageLoader()
    private lazy var favoriteGamesModelContainer: ModelContainer = makeFavoriteGamesModelContainer()
    private lazy var favoriteGamesRepository: FavoriteGamesRepository = SwiftDataFavoriteGamesRepository(
        modelContainer: favoriteGamesModelContainer
    )
    private lazy var favoriteGamesStore: FavoriteGamesStore = DefaultFavoriteGamesStore(
        repository: favoriteGamesRepository
    )

    func makeAppCoordinator() -> AppCoordinator {
        AppCoordinator(gamesCoordinator: makeGamesCoordinator())
    }

    func makeGamesCoordinator() -> GamesCoordinator {
        GamesCoordinator(factory: self)
    }

    func makeGameListViewController() -> GameListViewController {
        let repository = IGDBGameRepository(networking: networking)
        let fetchGamesUseCase = DefaultFetchGamesUseCase(repository: repository)
        let viewModel = GameListViewModel(
            fetchGamesUseCase: fetchGamesUseCase,
            favoriteGamesStore: favoriteGamesStore
        )

        return GameListViewController(
            viewModel: viewModel,
            imageLoader: imageLoader
        )
    }

    func makeFavoritesViewController() -> FavoritesViewController {
        let viewModel = FavoritesViewModel(favoriteGamesStore: favoriteGamesStore)
        return FavoritesViewController(
            viewModel: viewModel,
            imageLoader: imageLoader
        )
    }

    func makeGameDetailViewController(for game: GameItem) -> UIViewController {
        GameDetailViewController(
            game: game,
            imageLoader: imageLoader
        )
    }

    private func makeFavoriteGamesModelContainer() -> ModelContainer {
        do {
            return try ModelContainer(
                for: FavoriteGameRecord.self
            )
        } catch {
            fatalError("Unable to create FavoriteGameRecord ModelContainer: \(error)")
        }
    }
}
