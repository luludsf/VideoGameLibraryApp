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
            return "A resposta da API veio em um formato invalido."
        case .requestFailed(let statusCode):
            return "A API IGDB retornou erro \(statusCode)."
        case .invalidRequest:
            return "Nao foi possivel montar a requisicao da API."
        case .invalidBody:
            return "Nao foi possivel serializar o corpo da requisicao."
        case .transport(let error):
            return error.localizedDescription
        case .decoding:
            return "Nao foi possivel interpretar a resposta da API."
        }
    }
}
