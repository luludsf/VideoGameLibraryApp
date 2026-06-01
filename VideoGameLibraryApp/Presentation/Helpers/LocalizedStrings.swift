//
//  LocalizedStrings.swift
//  VideoGameLibraryApp
//
//  Created by Luana Duarte on 01/06/26.
//

import Foundation

enum LocalizedStrings {
    static let gamesTabTitle = localized("games.tab.title")
    static let favoritesTabTitle = localized("favorites.tab.title")
    static let gamesScreenTitle = localized("games.screen.title")
    static let favoritesScreenTitle = localized("favorites.screen.title")
    static let searchGamesPlaceholder = localized("games.search.placeholder")
    static let noGamesFound = localized("games.empty")
    static let noFavoritedGames = localized("favorites.empty")
    static let favoriteButtonTitle = localized("games.favorite.action")
    static let favoritedButtonTitle = localized("games.favorited.action")
    static let ratingTitle = localized("gameDetail.rating.title")
    static let platformsTitle = localized("gameDetail.platforms.title")
    static let savedToFavorites = localized("gameDetail.favorite.saved")
    static let notInFavorites = localized("gameDetail.favorite.notSaved")
    static let notAvailable = localized("common.notAvailable")
    static let okActionTitle = localized("common.ok")
    static let noSynopsis = localized("gameDetail.summary.empty")
    static let invalidResponseError = localized("errors.gameList.invalidResponse")
    static let requestFailedFormat = localized("errors.gameList.requestFailed")
    static let invalidRequestError = localized("errors.gameList.invalidRequest")
    static let invalidBodyError = localized("errors.gameList.invalidBody")
    static let decodingError = localized("errors.gameList.decoding")

    static func requestFailedMessage(statusCode: Int) -> String {
        String(format: requestFailedFormat, locale: .current, statusCode)
    }

    private static func localized(_ key: String) -> String {
        NSLocalizedString(key, comment: "")
    }
}
