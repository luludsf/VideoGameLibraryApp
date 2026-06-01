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

    public let rawBody: Data?

    public init(searchQuery: String? = nil) {
        let query: String
        if let searchQuery, !searchQuery.isEmpty {
            let escapedSearchQuery = Self.escapeSearchQuery(searchQuery)
            query = """
            fields name,cover.image_id,summary,rating,total_rating,platforms.name;
            search "\(escapedSearchQuery)";
            where version_parent = null;
            limit 50;
            """
        } else {
            query = """
            fields name,cover.image_id,summary,rating,total_rating,platforms.name;
            sort total_rating_count desc;
            limit 105;
            """
        }

        self.rawBody = query.data(using: .utf8)
    }

    private static func escapeSearchQuery(_ query: String) -> String {
        query
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
    }
}
