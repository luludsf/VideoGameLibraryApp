//
//  GameCell.swift
//  VideoGameLibraryApp
//
//  Created by Luana Duarte on 30/05/26.
//

import UIKit

final class GameCell: UICollectionViewCell {
    static let identifier = String(describing: GameCell.self)

    private enum LayoutMetrics {
        static let posterHeight: CGFloat = 140
        static let posterAspectRatio: CGFloat = 264 / 352
    }
    
    private var imageFetchTask: Task<Void, Never>?
    private var onFavoriteButtonTapped: (() -> Void)?

    private var placeholderImage: UIImage? {
        UIImage(systemName: "gamecontroller.fill")
    }
    
    // MARK: - UI Components
    
    private lazy var cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var rootStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [gameImageView, textStackView])
        stack.axis = .horizontal
        stack.alignment = .top
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var textStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, favoriteButton, UIView()])
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var gameImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .systemGray6
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        var configuration = UIButton.Configuration.plain()
        configuration.imagePadding = 4
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 12, bottom: 10, trailing: 12)
        button.configuration = configuration
        button.tintColor = .systemRed
        button.backgroundColor = .tertiarySystemBackground
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(favoriteTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViewCode()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle & Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        imageFetchTask?.cancel()
        imageFetchTask = nil
        
        gameImageView.image = placeholderImage
        titleLabel.text = nil
        favoriteButton.setImage(nil, for: .normal)
        onFavoriteButtonTapped = nil
    }
    
    // MARK: - Configuration
    func configure(with item: GameItem, imageLoader: ImageLoadingProtocol, onFavorite: @escaping () -> Void) {
        titleLabel.text = item.title
        self.onFavoriteButtonTapped = onFavorite
        
        let iconName = item.isFavorite ? "heart.fill" : "heart"
        favoriteButton.setImage(UIImage(systemName: iconName), for: .normal)
        favoriteButton.setTitle(item.isFavorite ? LocalizedStrings.favoritedButtonTitle : LocalizedStrings.favoriteButtonTitle, for: .normal)
        gameImageView.image = placeholderImage
        
        if let url = item.imageURL {
            imageFetchTask = Task { [weak self] in
                guard let self = self else { return }

                let image = await imageLoader.loadImage(from: url)
                guard !Task.isCancelled else { return }

                self.gameImageView.image = image ?? self.placeholderImage
            }
        }
    }
    
    @objc private func favoriteTapped() {
        onFavoriteButtonTapped?()
    }
    
    // MARK: - Setup View Code
    private func setupViewCode() {
        contentView.backgroundColor = .systemBackground
        contentView.addSubview(cardView)
        cardView.addSubview(rootStackView)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            rootStackView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            rootStackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            rootStackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            rootStackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            
            gameImageView.heightAnchor.constraint(equalToConstant: LayoutMetrics.posterHeight),
            gameImageView.widthAnchor.constraint(equalTo: gameImageView.heightAnchor, multiplier: LayoutMetrics.posterAspectRatio)
        ])
    }
}
