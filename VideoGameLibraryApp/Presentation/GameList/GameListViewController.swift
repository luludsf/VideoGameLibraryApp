//
//  GameListViewController.swift
//  VideoGameLibraryApp
//
//  Created by Luana Duarte on 30/05/26.
//

import UIKit

final class GameListViewController: UIViewController {
    
    private let listView: GameListView
    private let viewModel: GameListViewModel
    private var fetchTask: Task<Void, Never>?
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private let messageLabel = UILabel()
    
    init(viewModel: GameListViewModel, imageLoader: ImageLoading) {
        self.listView = GameListView(imageLoader: imageLoader)
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func loadView() {
        view = listView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Games"
        setupFeedbackViews()
        setupBindings()
        fetchTask = Task { [weak self] in
            guard let self = self else { return }
            await self.viewModel.fetchGames()
        }
    }

    deinit {
        fetchTask?.cancel()
    }
    
    private func setupBindings() {
        listView.onFavoriteToggleRequested = { [weak self] item in
            self?.viewModel.toggleFavorite(for: item)
        }
        
        viewModel.onStateChange = { [weak self] state in
            guard let self = self else { return }
            switch state {
            case .loading:
                self.showLoadingIndicator()
            case .empty:
                self.hideLoadingIndicator()
                self.showEmptyState()
            case .success(let items):
                self.hideLoadingIndicator()
                self.listView.update(with: items)
            case .error(let message):
                self.hideLoadingIndicator()
                self.showErrorMessage(message: message)
            }
        }
    }
    
    private func setupFeedbackViews() {
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true
        view.addSubview(loadingIndicator)

        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.textAlignment = .center
        messageLabel.textColor = .secondaryLabel
        messageLabel.numberOfLines = 0
        messageLabel.isHidden = true
        view.addSubview(messageLabel)

        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            messageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            messageLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            messageLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24)
        ])
    }

    private func showLoadingIndicator() {
        messageLabel.isHidden = true
        loadingIndicator.startAnimating()
    }

    private func hideLoadingIndicator() {
        loadingIndicator.stopAnimating()
    }

    private func showEmptyState() {
        messageLabel.text = "Nenhum jogo encontrado."
        messageLabel.isHidden = false
    }

    private func showErrorMessage(message: String) {
        messageLabel.text = message
        messageLabel.isHidden = false
    }
}
