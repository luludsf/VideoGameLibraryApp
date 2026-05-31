//
//  ViewControllerFactoryProtocol.swift
//  VideoGameLibraryApp
//
//  Created by Luana Duarte on 31/05/26.
//

import UIKit

protocol ViewControllerFactoryProtocol {
    func makeGameListViewController() -> GameListViewController
    func makeFavoritesViewController() -> UIViewController
    func makeGameDetailViewController(for game: GameItem) -> UIViewController
}
