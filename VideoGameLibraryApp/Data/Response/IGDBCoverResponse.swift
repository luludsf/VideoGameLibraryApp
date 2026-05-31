//
//  IGDBCoverResponse.swift
//  VideoGameLibraryApp
//
//  Created by Luana Duarte on 31/05/26.
//

import Foundation

public struct IGDBCoverResponse: Decodable {
    let imageId: String?
    let id: Int?
    
    var imageURL: URL? {
        guard let imageId else { return nil }
        return URL(string: "https://images.igdb.com/igdb/image/upload/t_cover_big/\(imageId).jpg")
    }
}
