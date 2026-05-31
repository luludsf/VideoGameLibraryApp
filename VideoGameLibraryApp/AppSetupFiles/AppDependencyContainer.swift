//
//  AppDependencyContainer.swift
//  VideoGameLibraryApp
//
//  Created by Luana Duarte on 31/05/26.
//

import UIKit
import NetworkingKit

final class AppDependencyContainer: ViewControllerFactoryProtocol {
    private lazy var networking: Networking = URLSessionClient()
    private lazy var imageLoader: ImageLoading = ImageLoader()

    func makeAppCoordinator() -> AppCoordinator {
        AppCoordinator(gamesCoordinator: makeGamesCoordinator())
    }

    func makeGamesCoordinator() -> GamesCoordinator {
        GamesCoordinator(factory: self)
    }

    func makeGameListViewController() -> GameListViewController {
        let repository = IGDBGameRepository(networking: networking)
        let fetchGamesUseCase = DefaultFetchGamesUseCase(repository: repository)
        let viewModel = GameListViewModel(fetchGamesUseCase: fetchGamesUseCase)

        return GameListViewController(
            viewModel: viewModel,
            imageLoader: imageLoader
        )
    }

    func makeFavoritesViewController() -> UIViewController {
        FavoritesPlaceholderViewController()
    }

    func makeGameDetailViewController(for game: GameItem) -> UIViewController {
        GameDetailPlaceholderViewController(game: game)
    }
}
