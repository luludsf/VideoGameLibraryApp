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
    let isFavorite: Bool
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(isFavorite)
    }
}
