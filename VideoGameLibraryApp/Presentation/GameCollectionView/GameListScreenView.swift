//
//  GameListScreenView.swift
//  VideoGameLibraryApp
//
//  Created by Luana Duarte on 01/06/26.
//

import UIKit

final class GameListScreenView: UIView {
    var onFavoriteToggleRequested: ((GameItem) -> Void)? {
        get { listView.onFavoriteToggleRequested }
        set { listView.onFavoriteToggleRequested = newValue }
    }

    var onGameSelected: ((GameItem) -> Void)? {
        get { listView.onGameSelected }
        set { listView.onGameSelected = newValue }
    }

    var onPaginationThresholdReached: (() -> Void)? {
        get { listView.onPaginationThresholdReached }
        set { listView.onPaginationThresholdReached = newValue }
    }

    private let listView: GameListView
    private let feedbackView = FeedbackStateView()

    init(frame: CGRect = .zero, imageLoader: ImageLoadingProtocol) {
        self.listView = GameListView(imageLoader: imageLoader)
        super.init(frame: frame)
        backgroundColor = .systemBackground
        setupViewCode()
    }

    required init?(coder: NSCoder) { fatalError() }

    func update(with items: [GameItem]) {
        listView.update(with: items)
    }

    func showLoading() {
        feedbackView.showLoading()
    }

    func showFeedback(with message: String) {
        feedbackView.showMessage(message)
    }

    func hideFeedback() {
        feedbackView.hideLoading()
        feedbackView.hideMessage()
    }

    func setPaginationLoading(_ isLoading: Bool) {
        listView.setPaginationLoading(isLoading)
    }

    private func setupViewCode() {
        addSubview(listView)
        addSubview(feedbackView)

        listView.translatesAutoresizingMaskIntoConstraints = false
        feedbackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            listView.topAnchor.constraint(equalTo: topAnchor),
            listView.leadingAnchor.constraint(equalTo: leadingAnchor),
            listView.trailingAnchor.constraint(equalTo: trailingAnchor),
            listView.bottomAnchor.constraint(equalTo: bottomAnchor),
            feedbackView.topAnchor.constraint(equalTo: topAnchor),
            feedbackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            feedbackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            feedbackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
