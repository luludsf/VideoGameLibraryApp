//
//  GameDetailViewController.swift
//  VideoGameLibraryApp
//
//  Created by Luana Duarte on 31/05/26.
//

import UIKit

final class GameDetailViewController: UIViewController {
    private enum LayoutMetrics {
        static let horizontalPadding: CGFloat = 20
        static let verticalSpacing: CGFloat = 20
        static let coverAspectRatio: CGFloat = 264 / 352
    }

    private let game: GameItem
    private let imageLoader: ImageLoading
    private var imageLoadTask: Task<Void, Never>?

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var contentStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [coverImageView, detailsCardView])
        stack.axis = .vertical
        stack.spacing = LayoutMetrics.verticalSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 18
        imageView.backgroundColor = .secondarySystemBackground
        imageView.image = UIImage(systemName: "gamecontroller.fill")
        imageView.tintColor = .tertiaryLabel
        return imageView
    }()

    private lazy var detailsCardView: UIView = makeCardView()

    private lazy var detailsStackView: UIStackView = {
        let stack = UIStackView(
            arrangedSubviews: [
                titleLabel,
                favoriteStatusLabel,
                makeDetailRow(title: "Nota", value: formattedRating),
                makeDetailRow(title: "Plataformas", value: formattedPlatforms),
                descriptionLabel
            ]
        )
        stack.axis = .vertical
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()

    private let favoriteStatusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()

    init(game: GameItem, imageLoader: ImageLoading) {
        self.game = game
        self.imageLoader = imageLoader
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = game.title
        view.backgroundColor = .systemBackground
        setupViewCode()
        configureContent()
        loadCoverImageIfNeeded()
    }

    deinit {
        imageLoadTask?.cancel()
    }

    private func setupViewCode() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(contentStackView)
        detailsCardView.addSubview(detailsStackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: LayoutMetrics.verticalSpacing),
            contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: LayoutMetrics.horizontalPadding),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -LayoutMetrics.horizontalPadding),
            contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -LayoutMetrics.verticalSpacing),

            coverImageView.widthAnchor.constraint(equalTo: contentStackView.widthAnchor),
            coverImageView.heightAnchor.constraint(equalTo: coverImageView.widthAnchor, multiplier: 1 / LayoutMetrics.coverAspectRatio),

            detailsStackView.topAnchor.constraint(equalTo: detailsCardView.topAnchor, constant: 20),
            detailsStackView.leadingAnchor.constraint(equalTo: detailsCardView.leadingAnchor, constant: 20),
            detailsStackView.trailingAnchor.constraint(equalTo: detailsCardView.trailingAnchor, constant: -20),
            detailsStackView.bottomAnchor.constraint(equalTo: detailsCardView.bottomAnchor, constant: -20)
        ])
    }

    private func configureContent() {
        titleLabel.text = game.title
        favoriteStatusLabel.text = game.isFavorite ? "Salvo nos favoritos" : "Fora dos favoritos"
        descriptionLabel.text = game.summary ?? "Nenhuma sinopse foi disponibilizada para este jogo pela API."
    }

    private func loadCoverImageIfNeeded() {
        guard let imageURL = game.imageURL else { return }

        imageLoadTask = Task { [weak self] in
            guard let self = self else { return }

            let image = await imageLoader.loadImage(from: imageURL)
            guard !Task.isCancelled else { return }

            self.coverImageView.image = image ?? UIImage(systemName: "photo")
        }
    }

    private func makeCardView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 18
        return view
    }

    private func makeDetailRow(title: String, value: String) -> UIStackView {
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        titleLabel.textColor = .secondaryLabel
        titleLabel.text = title.uppercased()

        let valueLabel = UILabel()
        valueLabel.font = .systemFont(ofSize: 17, weight: .medium)
        valueLabel.textColor = .label
        valueLabel.numberOfLines = 0
        valueLabel.text = value

        let stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }

    private var formattedRating: String {
        guard let rating = game.rating else { return "Nao informada" }
        return String(format: "%.1f", rating)
    }

    private var formattedPlatforms: String {
        game.platforms.isEmpty ? "Nao informadas" : game.platforms.joined(separator: ", ")
    }
}
