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
    var favoritedAt: Date

    init(
        id: String,
        title: String,
        imageURLString: String?,
        favoritedAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.imageURLString = imageURLString
        self.favoritedAt = favoritedAt
    }

    var gameItem: GameItem {
        GameItem(
            id: id,
            title: title,
            imageURL: imageURLString.flatMap(URL.init(string:)),
            isFavorite: true
        )
    }

    func update(from game: GameItem) {
        title = game.title
        imageURLString = game.imageURL?.absoluteString
        favoritedAt = .now
    }
}
