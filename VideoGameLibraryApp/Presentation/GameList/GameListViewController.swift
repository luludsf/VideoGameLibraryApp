//
//  GameListViewController.swift
//  VideoGameLibraryApp
//
//  Created by Luana Duarte on 30/05/26.
//

import UIKit

final class GameListViewController: UIViewController {
    
    var onGameSelected: ((GameItem) -> Void)?

    private let gameListView: GameListScreenView
    private let viewModel: GameListViewModel
    private var debounceTask: Task<Void, Never>?
    private var fetchTask: Task<Void, Never>?
    private var paginationTask: Task<Void, Never>?
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = LocalizedStrings.searchGamesPlaceholder
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchBar.delegate = self
        return searchController
    }()
    
    init(viewModel: GameListViewModel, imageLoader: ImageLoading) {
        self.gameListView = GameListScreenView(imageLoader: imageLoader)
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func loadView() {
        view = gameListView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = LocalizedStrings.gamesScreenTitle
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
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
        paginationTask?.cancel()
    }
    
    private func setupBindings() {
        gameListView.onFavoriteToggleRequested = { [weak self] item in
            Task { await self?.viewModel.toggleFavorite(for: item) }
        }
        gameListView.onGameSelected = { [weak self] item in
            self?.onGameSelected?(item)
        }
        gameListView.onPaginationThresholdReached = { [weak self] in
            self?.loadNextPage()
        }
        
        viewModel.onStateChange = { [weak self] state in
            guard let self = self else { return }
            switch state {
            case .loading:
                self.gameListView.setPaginationLoading(false)
                self.gameListView.showLoading()
            case .empty:
                self.gameListView.setPaginationLoading(false)
                self.gameListView.update(with: [])
                self.gameListView.showMessage(LocalizedStrings.noGamesFound)
            case .success(let items):
                self.gameListView.hideFeedback()
                self.gameListView.setPaginationLoading(false)
                self.gameListView.update(with: items)
            case .error(let message):
                self.gameListView.setPaginationLoading(false)
                self.gameListView.update(with: [])
                self.gameListView.showMessage(message)
            }
        }

        viewModel.onPaginationLoadingStateChange = { [weak self] isLoading in
            self?.gameListView.setPaginationLoading(isLoading)
        }

        viewModel.onPaginationError = { [weak self] message in
            self?.presentPaginationError(message: message)
        }
    }

    private func performFetch(searchQuery: String?) {
        fetchTask?.cancel()
        paginationTask?.cancel()
        fetchTask = Task { [weak self] in
            guard let self = self else { return }
            await self.viewModel.fetchGames(searchQuery: searchQuery)
        }
    }

    private func loadNextPage() {
        guard paginationTask == nil else { return }

        paginationTask = Task { [weak self] in
            guard let self = self else { return }
            defer { self.paginationTask = nil }
            await self.viewModel.loadNextPage()
        }
    }

    private func presentPaginationError(message: String) {
        guard presentedViewController == nil else { return }

        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(
            UIAlertAction(title: LocalizedStrings.okActionTitle, style: .default)
        )
        present(alertController, animated: true)
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
