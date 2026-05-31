//
//  AppCoordinator.swift
//  VideoGameLibraryApp
//
//  Created by Luana Duarte on 31/05/26.
//

import UIKit

final class AppCoordinator: Coordinator {
    private let gamesCoordinator: GamesCoordinator

    init(gamesCoordinator: GamesCoordinator) {
        self.gamesCoordinator = gamesCoordinator
    }

    func start() -> UIViewController {
        gamesCoordinator.start()
    }
}
