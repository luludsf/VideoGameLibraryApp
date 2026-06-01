//
//  GameDetailView.swift
//  VideoGameLibraryApp
//
//  Created by Luana Duarte on 01/06/26.
//

import UIKit

final class GameDetailView: UIView {
    private enum LayoutMetrics {
        static let horizontalPadding: CGFloat = 20
        static let verticalSpacing: CGFloat = 20
        static let coverAspectRatio: CGFloat = 264 / 352
    }

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
                makeDetailRow(title: LocalizedStrings.ratingTitle, valueLabel: ratingValueLabel),
                makeDetailRow(title: LocalizedStrings.platformsTitle, valueLabel: platformsValueLabel),
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

    private let ratingValueLabel = GameDetailView.makeValueLabel()
    private let platformsValueLabel = GameDetailView.makeValueLabel()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        setupViewCode()
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(with game: GameItem) {
        titleLabel.text = game.title
        favoriteStatusLabel.text = game.isFavorite ? LocalizedStrings.savedToFavorites : LocalizedStrings.notInFavorites
        ratingValueLabel.text = game.rating.map { String(format: "%.1f", $0) } ?? LocalizedStrings.notAvailable
        platformsValueLabel.text = game.platforms.isEmpty ? LocalizedStrings.notAvailable : game.platforms.joined(separator: ", ")
        descriptionLabel.text = game.summary ?? LocalizedStrings.noSynopsis
        coverImageView.image = UIImage(systemName: "gamecontroller.fill")
    }

    func updateCoverImage(_ image: UIImage?) {
        coverImageView.image = image ?? UIImage(systemName: "photo")
    }

    private func setupViewCode() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(contentStackView)
        detailsCardView.addSubview(detailsStackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
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

    private func makeCardView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 18
        return view
    }

    private func makeDetailRow(title: String, valueLabel: UILabel) -> UIStackView {
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        titleLabel.textColor = .secondaryLabel
        titleLabel.text = title.uppercased()

        let stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }

    private static func makeValueLabel() -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }
}
