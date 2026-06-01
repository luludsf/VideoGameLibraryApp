//
//  FavoriteGameRecord.swift
//  VideoGameLibraryApp
//
//  Created by Luana Duarte on 31/05/26.
//

import Foundation
import SwiftData

@Model
final class FavoriteGameRecord {
    @Attribute(.unique) var id: String
    var title: String
    var imageURLString: String?
    var summary: String?
    var rating: Double?
    var platformsString: String
    var favoritedAt: Date

    init(
        id: String,
        title: String,
        imageURLString: String?,
        summary: String? = nil,
        rating: Double? = nil,
        platforms: [String] = [],
        favoritedAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.imageURLString = imageURLString
        self.summary = summary
        self.rating = rating
        self.platformsString = platforms.joined(separator: " | ")
        self.favoritedAt = favoritedAt
    }

    var gameItem: GameItem {
        GameItem(
            id: id,
            title: title,
            imageURL: imageURLString.flatMap(URL.init(string:)),
            summary: summary,
            rating: rating,
            platforms: platforms,
            isFavorite: true
        )
    }

    func update(from game: GameItem) {
        title = game.title
        imageURLString = game.imageURL?.absoluteString
        summary = game.summary
        rating = game.rating
        platformsString = game.platforms.joined(separator: " | ")
        favoritedAt = .now
    }

    private var platforms: [String] {
        guard !platformsString.isEmpty else { return [] }
        return platformsString
            .components(separatedBy: " | ")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
}
