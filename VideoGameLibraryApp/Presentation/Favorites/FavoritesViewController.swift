//
//  FavoritesViewController.swift
//  VideoGameLibraryApp
//
//  Created by Luana Duarte on 31/05/26.
//

import UIKit

final class FavoritesViewController: UIViewController {
    var onGameSelected: ((GameItem) -> Void)?

    private let favoritesView: GameListScreenView
    private let viewModel: FavoritesViewModel

    init(viewModel: FavoritesViewModel, imageLoader: ImageLoadingProtocol) {
        self.favoritesView = GameListScreenView(imageLoader: imageLoader)
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func loadView() {
        view = favoritesView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = LocalizedStrings.favoritesScreenTitle
        setupBindings()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task { await viewModel.fetchFavoriteGames() }
    }

    private func setupBindings() {
        favoritesView.onFavoriteToggleRequested = { [weak self] item in
            Task {
                await self?.viewModel.toggleFavorite(for: item)
            }
        }

        favoritesView.onGameSelected = { [weak self] item in
            self?.onGameSelected?(item)
        }

        viewModel.onStateChange = { [weak self] state in
            guard let self = self else { return }

            switch state {
            case .loading:
                self.favoritesView.showLoading()
            case .empty:
                self.favoritesView.update(with: [])
                self.favoritesView.showFeedback(with: LocalizedStrings.noFavoritedGames)
            case .success(let items):
                self.favoritesView.hideFeedback()
                self.favoritesView.update(with: items)
            case .error(let message):
                self.favoritesView.update(with: [])
                self.favoritesView.showFeedback(with: message)
            }
        }
    }
}
