import Foundation

public enum NetworkingError: Error {
    case invalidURL
    case requestFailed(URLError)
    case invalidResponse
    case invalidResponseData
    case decodingFailed(Error)
    case invalidBodyData
    case noInternetConnection
    case timeout
    case cancelled
    case httpError(code: Int)
}
