//
//  GameDetailViewController.swift
//  VideoGameLibraryApp
//
//  Created by Luana Duarte on 31/05/26.
//

import UIKit

final class GameDetailViewController: UIViewController {
    private let game: GameItem
    private let gameDetailView = GameDetailView()
    private let imageLoader: ImageLoading
    private var imageLoadTask: Task<Void, Never>?

    init(game: GameItem, imageLoader: ImageLoading) {
        self.game = game
        self.imageLoader = imageLoader
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func loadView() {
        view = gameDetailView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = game.title
        gameDetailView.configure(with: game)
        loadCoverImageIfNeeded()
    }

    deinit {
        imageLoadTask?.cancel()
    }

    private func loadCoverImageIfNeeded() {
        guard let imageURL = game.imageURL else { return }

        imageLoadTask = Task { [weak self] in
            guard let self = self else { return }

            let image = await imageLoader.loadImage(from: imageURL)
            guard !Task.isCancelled else { return }

            self.gameDetailView.updateCoverImage(image)
        }
    }
}
