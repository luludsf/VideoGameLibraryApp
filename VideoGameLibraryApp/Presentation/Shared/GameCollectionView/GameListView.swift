//
//  GameListView.swift
//  VideoGameLibraryApp
//
//  Created by Luana Duarte on 30/05/26.
//

import UIKit

final class GameListView: UIView {
        
    var onFavoriteToggleRequested: ((GameItem) -> Void)?
    
    // MARK: - UI Components
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.register(GameCell.self, forCellWithReuseIdentifier: GameCell.identifier)
        collectionView.backgroundColor = .systemBackground
        return collectionView
    }()
    
    private var dataSource: UICollectionViewDiffableDataSource<GameListSection, GameItem>?
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
        setupDataSource()
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
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    // MARK: - Data Source Setup
    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<GameListSection, GameItem>(collectionView: collectionView) { [weak self] collectionView, indexPath, item in
            guard let self = self,
                  let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GameCell.identifier, for: indexPath) as? GameCell else {
                return UICollectionViewCell()
            }
            
            cell.configure(with: item) { [weak self] in
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
}
