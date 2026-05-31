//
//  GamesCoordinator.swift
//  VideoGameLibraryApp
//
//  Created by Luana Duarte on 31/05/26.
//

import UIKit

final class GamesCoordinator: Coordinator {
    private let factory: ViewControllerFactoryProtocol
    private let tabBarController = UITabBarController()
    private let gameListNavigationController = UINavigationController()
    private let favoritesNavigationController = UINavigationController()

    init(factory: ViewControllerFactoryProtocol) {
        self.factory = factory
    }

    func start() -> UIViewController {
        let gameListViewController = factory.makeGameListViewController()
        gameListViewController.onGameSelected = { [weak self] game in
            self?.showGameDetail(for: game, from: self?.gameListNavigationController)
        }

        let favoritesViewController = factory.makeFavoritesViewController()

        gameListNavigationController.setViewControllers([gameListViewController], animated: false)
        gameListNavigationController.tabBarItem = UITabBarItem(
            title: "Jogos",
            image: UIImage(systemName: "magnifyingglass"),
            selectedImage: UIImage(systemName: "magnifyingglass")
        )

        favoritesNavigationController.setViewControllers([favoritesViewController], animated: false)
        favoritesNavigationController.tabBarItem = UITabBarItem(
            title: "Favoritos",
            image: UIImage(systemName: "heart"),
            selectedImage: UIImage(systemName: "heart.fill")
        )

        tabBarController.viewControllers = [
            gameListNavigationController,
            favoritesNavigationController
        ]

        return tabBarController
    }

    func showGameDetail(for game: GameItem, from navigationController: UINavigationController?) {
        guard let navigationController = navigationController else { return }
        let detailViewController = factory.makeGameDetailViewController(for: game)
        navigationController.pushViewController(detailViewController, animated: true)
    }
}
