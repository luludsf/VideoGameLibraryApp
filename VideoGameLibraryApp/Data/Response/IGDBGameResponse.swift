//
//  IGDBGameResponse.swift
//  VideoGameLibraryApp
//
//  Created by Luana Duarte on 31/05/26.
//

import Foundation

public struct IGDBGameResponse: Decodable {
    let id: Int
    let name: String
    let cover: IGDBCoverResponse?
}


