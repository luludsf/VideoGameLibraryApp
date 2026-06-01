//
//  GameListRequestError.swift
//  VideoGameLibraryApp
//
//  Created by Luana Duarte on 31/05/26.
//

import Foundation
import NetworkingKit

public enum GameListRequestError: LocalizedError {
    case invalidResponse
    case requestFailed(statusCode: Int)
    case invalidRequest
    case invalidBody
    case transport(Error)
    case decoding(Error)

    init(networkingError: NetworkingError) {
        switch networkingError {
        case .invalidURL:
            self = .invalidRequest
        case .invalidResponse:
            self = .invalidResponse
        case .httpError(let statusCode):
            self = .requestFailed(statusCode: statusCode)
        case .invalidBodyData:
            self = .invalidBody
        case .decodingFailed(let error):
            self = .decoding(error)
        case .requestFailed(let error):
            self = .transport(error)
        case .noInternetConnection:
            self = .transport(URLError(.notConnectedToInternet))
        case .timeout:
            self = .transport(URLError(.timedOut))
        case .cancelled:
            self = .transport(URLError(.cancelled))
        }
    }
    
    public var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "The API response came in an invalid format."
        case .requestFailed(let statusCode):
            return "The IGDB API returned error \(statusCode)."
        case .invalidRequest:
            return "Unable to build the API request."
        case .invalidBody:
            return "Unable to serialize the request body."
        case .transport(let error):
            return error.localizedDescription
        case .decoding:
            return "Unable to parse the API response."
        }
    }
}
