//
//  GameListViewController.swift
//  VideoGameLibraryApp
//
//  Created by Luana Duarte on 30/05/26.
//

import UIKit

final class GameListViewController: UIViewController {
    
    var onGameSelected: ((GameItem) -> Void)?

    private let listView: GameListView
    private let viewModel: GameListViewModel
    private var debounceTask: Task<Void, Never>?
    private var fetchTask: Task<Void, Never>?
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private let messageLabel = UILabel()
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search games"
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchBar.delegate = self
        return searchController
    }()
    
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
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        setupFeedbackViews()
        setupBindings()
        performFetch(searchQuery: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task { await viewModel.refreshFavoriteStates() }
    }

    deinit {
        debounceTask?.cancel()
        fetchTask?.cancel()
    }
    
    private func setupBindings() {
        listView.onFavoriteToggleRequested = { [weak self] item in
            Task { await self?.viewModel.toggleFavorite(for: item) }
        }
        listView.onGameSelected = { [weak self] item in
            self?.onGameSelected?(item)
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
                self.hideMessage()
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
        hideMessage()
        loadingIndicator.startAnimating()
    }

    private func hideLoadingIndicator() {
        loadingIndicator.stopAnimating()
    }

    private func showEmptyState() {
        messageLabel.text = "No games found."
        messageLabel.isHidden = false
    }

    private func showErrorMessage(message: String) {
        messageLabel.text = message
        messageLabel.isHidden = false
    }

    private func hideMessage() {
        messageLabel.isHidden = true
    }

    private func performFetch(searchQuery: String?) {
        fetchTask?.cancel()
        fetchTask = Task { [weak self] in
            guard let self = self else { return }
            await self.viewModel.fetchGames(searchQuery: searchQuery)
        }
    }

    private func scheduleSearch(for searchQuery: String?) {
        debounceTask?.cancel()
        debounceTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }
            self?.performFetch(searchQuery: searchQuery)
        }
    }
}

extension GameListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        scheduleSearch(for: searchController.searchBar.text)
    }
}

extension GameListViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        performFetch(searchQuery: nil)
    }
}
