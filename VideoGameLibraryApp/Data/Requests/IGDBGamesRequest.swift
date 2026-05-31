//
//  IGDBGamesRequest.swift
//  VideoGameLibraryApp
//
//  Created by Luana Duarte on 31/05/26.
//

import Foundation
import NetworkingKit

public struct IGDBGamesRequest: Request {
    public let host = "api.igdb.com"
    public let scheme = "https"
    public let version = "v4"
    public let path = "/games"
    public let method: HTTPMethod = .post
    
    public let headers: [String: String]? = [
        "Client-ID": AppConfig.clientId,
        "Authorization": "Bearer \(AppConfig.accessToken)",
        "Content-Type": "text/plain"
    ]
    
    public let rawBody = """
    fields name,cover.image_id;
    sort total_rating_count desc;
    limit 105;
    """.data(using: .utf8)
}
