//
//  AppDependencyContainer.swift
//  VideoGameLibraryApp
//
//  Created by Luana Duarte on 31/05/26.
//

import UIKit
import NetworkingKit

final class AppDependencyContainer {
    private lazy var networking: Networking = URLSessionClient()
    private lazy var imageLoader: ImageLoading = ImageLoader()

    func makeGameListViewController() -> UIViewController {
        let repository = IGDBGameRepository(networking: networking)
        let fetchGamesUseCase = DefaultFetchGamesUseCase(repository: repository)
        let viewModel = GameListViewModel(fetchGamesUseCase: fetchGamesUseCase)

        return GameListViewController(
            viewModel: viewModel,
            imageLoader: imageLoader
        )
    }
}
