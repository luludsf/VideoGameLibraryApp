//
//  IGDBGamesRequest.swift
//  VideoGameLibraryApp
//
//  Created by Luana Duarte on 31/05/26.
//

import Foundation
import NetworkingKit

struct IGDBGamesRequest: Request {
    let host = "api.igdb.com"
    let scheme = "https"
    let version = "v4"
    let path = "/games"
    let method: HTTPMethod = .post
    
    let headers: [String: String]? = [
        "Client-ID": AppConfig.clientId,
        "Authorization": "Bearer \(AppConfig.accessToken)",
        "Content-Type": "text/plain"
    ]

    let rawBody: Data?

    init(searchQuery: String? = nil, offset: Int, limit: Int) {
        let query: String
        if let searchQuery, !searchQuery.isEmpty {
            let escapedSearchQuery = Self.escapeSearchQuery(searchQuery)
            query = """
            fields name,cover.image_id,summary,rating,total_rating,platforms.name;
            search "\(escapedSearchQuery)";
            where version_parent = null;
            offset \(offset);
            limit \(limit);
            """
        } else {
            query = """
            fields name,cover.image_id,summary,rating,total_rating,platforms.name;
            sort total_rating_count desc;
            offset \(offset);
            limit \(limit);
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
