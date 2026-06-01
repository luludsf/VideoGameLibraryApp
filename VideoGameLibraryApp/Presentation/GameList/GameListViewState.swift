//
//  GameListViewState.swift
//  VideoGameLibraryApp
//
//  Created by Luana Duarte on 01/06/26.
//

import Foundation

enum GameListViewState: Equatable {
    case loading
    case empty
    case content(items: [GameItem], isLoadingNextPage: Bool, paginationErrorMessage: String?)
    case error(String)
}
