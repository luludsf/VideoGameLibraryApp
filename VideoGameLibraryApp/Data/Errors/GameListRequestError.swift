//
//  GameListRequestError.swift
//  VideoGameLibraryApp
//
//  Created by Luana Duarte on 31/05/26.
//

import Foundation
import NetworkingKit

enum GameListRequestError: LocalizedError {
    case invalidResponse
    case requestFailed(statusCode: Int)
    case invalidRequest
    case invalidBody
    case network(Error)
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
            self = .network(error)
        case .noInternetConnection:
            self = .network(URLError(.notConnectedToInternet))
        case .timeout:
            self = .network(URLError(.timedOut))
        case .cancelled:
            self = .network(URLError(.cancelled))
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return LocalizedStrings.invalidResponseError
        case .requestFailed(let statusCode):
            return LocalizedStrings.requestFailedMessage(statusCode: statusCode)
        case .invalidRequest:
            return LocalizedStrings.invalidRequestError
        case .invalidBody:
            return LocalizedStrings.invalidBodyError
        case .network(let error):
            return error.localizedDescription
        case .decoding:
            return LocalizedStrings.decodingError
        }
    }
}
