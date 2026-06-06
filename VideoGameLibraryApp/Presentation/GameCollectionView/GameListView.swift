//
//  GameListView.swift
//  VideoGameLibraryApp
//
//  Created by Luana Duarte on 30/05/26.
//

import UIKit

final class GameListView: UIView {
        
    var onFavoriteToggleRequested: ((GameItem) -> Void)?
    var onGameSelected: ((GameItem) -> Void)?
    var onPaginationThresholdReached: (() -> Void)?
    private let imageLoader: ImageLoadingProtocol
    private let paginationTriggerDistance = 5
    
    // MARK: - UI Components
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.register(GameCell.self, forCellWithReuseIdentifier: GameCell.identifier)
        collectionView.backgroundColor = .systemBackground
        return collectionView
    }()
    
    private var dataSource: UICollectionViewDiffableDataSource<GameListSection, GameItem>?
    
    private let paginationActivityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()
    
    // MARK: - Init
    init(frame: CGRect = .zero, imageLoader: ImageLoadingProtocol) {
        self.imageLoader = imageLoader
        super.init(frame: frame)
        setupConstraints()
        setupDataSource()
        collectionView.delegate = self
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Layout Setup (Modern List Pattern)
    private func createLayout() -> UICollectionViewLayout {
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.showsSeparators = false
        return UICollectionViewCompositionalLayout.list(using: config)
    }
    
    private func setupConstraints() {
        addSubview(collectionView)
        addSubview(paginationActivityIndicator)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        paginationActivityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            paginationActivityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            paginationActivityIndicator.bottomAnchor.constraint(
                equalTo: safeAreaLayoutGuide.bottomAnchor,
                constant: -12
            )
        ])
    }
    
    // MARK: - Data Source Setup
    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<GameListSection, GameItem>(collectionView: collectionView) { [weak self] collectionView, indexPath, item in
            guard let self = self,
                  let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GameCell.identifier, for: indexPath) as? GameCell else {
                return UICollectionViewCell()
            }
            
            cell.configure(with: item, imageLoader: self.imageLoader) { [weak self] in
                self?.onFavoriteToggleRequested?(item)
            }
            
            return cell
        }
    }
    
    // MARK: - Public API
    func update(with items: [GameItem]) {
        var snapshot = NSDiffableDataSourceSnapshot<GameListSection, GameItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items)
        
        dataSource?.apply(snapshot, animatingDifferences: true)
    }

    func setPaginationLoading(_ isLoading: Bool) {
        if isLoading {
            paginationActivityIndicator.startAnimating()
        } else {
            paginationActivityIndicator.stopAnimating()
        }
    }
}

extension GameListView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource?.itemIdentifier(for: indexPath) else { return }
        collectionView.deselectItem(at: indexPath, animated: true)
        onGameSelected?(item)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard let itemCount = dataSource?.snapshot().itemIdentifiers.count,
              itemCount > 0 else {
            return
        }

        let thresholdIndex = max(itemCount - paginationTriggerDistance, 0)
        guard indexPath.item >= thresholdIndex else { return }
        onPaginationThresholdReached?()
    }
}
