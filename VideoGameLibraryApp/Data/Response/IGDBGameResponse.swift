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
    let rating: Double?
    let summary: String?
    let totalRating: Double?
    let platforms: [IGDBPlatformResponse]?

    init(
        id: Int,
        name: String,
        cover: IGDBCoverResponse?,
        rating: Double? = nil,
        summary: String? = nil,
        totalRating: Double? = nil,
        platforms: [IGDBPlatformResponse]? = nil
    ) {
        self.id = id
        self.name = name
        self.cover = cover
        self.rating = rating
        self.summary = summary
        self.totalRating = totalRating
        self.platforms = platforms
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case cover
        case rating
        case summary
        case totalRating = "total_rating"
        case platforms
    }
}

struct IGDBPlatformResponse: Decodable {
    let name: String
}
