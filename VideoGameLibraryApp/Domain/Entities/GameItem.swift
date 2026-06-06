//
//  GameItem.swift
//  VideoGameLibraryApp
//
//  Created by Luana Duarte on 30/05/26.
//

import Foundation

nonisolated struct GameItem: Hashable, Sendable {
    let id: String
    let title: String
    let imageURL: URL?
    let summary: String?
    let rating: Double?
    let platforms: [String]
    let isFavorite: Bool

    init(
        id: String,
        title: String,
        imageURL: URL?,
        summary: String? = nil,
        rating: Double? = nil,
        platforms: [String] = [],
        isFavorite: Bool
    ) {
        self.id = id
        self.title = title
        self.imageURL = imageURL
        self.summary = summary
        self.rating = rating
        self.platforms = platforms
        self.isFavorite = isFavorite
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(isFavorite)
    }

    func updatingFavorite(to isFavorite: Bool) -> GameItem {
        GameItem(
            id: id,
            title: title,
            imageURL: imageURL,
            summary: summary,
            rating: rating,
            platforms: platforms,
            isFavorite: isFavorite
        )
    }
}
