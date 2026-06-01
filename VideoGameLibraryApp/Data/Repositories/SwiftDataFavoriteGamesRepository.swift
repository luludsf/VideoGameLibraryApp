//
//  SwiftDataFavoriteGamesRepository.swift
//  VideoGameLibraryApp
//
//  Created by Luana Duarte on 31/05/26.
//

import Foundation
import SwiftData

actor SwiftDataFavoriteGamesRepository: FavoriteGamesRepositoryProtocol {
    private let modelContainer: ModelContainer

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    func fetchFavoriteGames() throws -> [GameItem] {
        let modelContext = ModelContext(modelContainer)
        let descriptor = FetchDescriptor<FavoriteGameRecord>(
            sortBy: [SortDescriptor(\.favoritedAt, order: .reverse)]
        )

        return try modelContext.fetch(descriptor).map(\.gameItem)
    }

    func fetchFavoriteGameIDs() throws -> Set<String> {
        let modelContext = ModelContext(modelContainer)
        let descriptor = FetchDescriptor<FavoriteGameRecord>()
        return Set(try modelContext.fetch(descriptor).map(\.id))
    }

    func saveFavorite(_ game: GameItem) throws {
        let modelContext = ModelContext(modelContainer)

        if let record = try fetchRecord(gameID: game.id, modelContext: modelContext) {
            record.update(from: game)
        } else {
            modelContext.insert(
                FavoriteGameRecord(
                    id: game.id,
                    title: game.title,
                    imageURLString: game.imageURL?.absoluteString,
                    summary: game.summary,
                    rating: game.rating,
                    platforms: game.platforms
                )
            )
        }

        try saveChangesIfNeeded(modelContext: modelContext)
    }

    func removeFavorite(gameID: String) throws {
        let modelContext = ModelContext(modelContainer)
        guard let record = try fetchRecord(gameID: gameID, modelContext: modelContext) else { return }
        modelContext.delete(record)
        try saveChangesIfNeeded(modelContext: modelContext)
    }

    private func fetchRecord(gameID: String, modelContext: ModelContext) throws -> FavoriteGameRecord? {
        let descriptor = FetchDescriptor<FavoriteGameRecord>()
        return try modelContext.fetch(descriptor).first(where: { $0.id == gameID })
    }

    private func saveChangesIfNeeded(modelContext: ModelContext) throws {
        guard modelContext.hasChanges else { return }
        try modelContext.save()
    }
}
