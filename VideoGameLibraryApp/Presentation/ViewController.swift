//
//  ViewController.swift
//  VideoGameLibraryApp
//
//  Created by Luana Duarte on 30/05/26.
//

import UIKit

class ViewController: UIViewController {
    
    private let listView = GameListView()
    
    override func loadView() {
        view = listView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        let games: [GameItem] = [
            GameItem(id: "1020", title: "Grand Theft Auto V", imageURL: URL(string: "https://images.igdb.com/igdb/image/upload/t_cover_big/co2lbd.jpg"), isFavorite: false),
            GameItem(id: "1942", title: "The Witcher 3: Wild Hunt", imageURL: URL(string: "https://images.igdb.com/igdb/image/upload/t_cover_big/coaarl.jpg"), isFavorite: false),
            GameItem(id: "72", title: "Portal 2", imageURL: URL(string: "https://images.igdb.com/igdb/image/upload/t_cover_big/co1rs4.jpg"), isFavorite: false),
            GameItem(id: "472", title: "The Elder Scrolls V: Skyrim", imageURL: URL(string: "https://images.igdb.com/igdb/image/upload/t_cover_big/cobt0i.jpg"), isFavorite: false),
            GameItem(id: "732", title: "Grand Theft Auto: San Andreas", imageURL: URL(string: "https://images.igdb.com/igdb/image/upload/t_cover_big/co2lb9.jpg"), isFavorite: false)
        ]
        
        self.listView.update(with: games)
    }


}
