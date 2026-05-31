import Foundation

public protocol Request {
    var host: String { get }
    var scheme: String { get }
    var version: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var bodyParams: [String: Any?]? { get }
    var queryParams: [String: String]? { get }
}

extension Request {
    var resolvedPath: String {
        let normalizedVersion = version.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let normalizedPath = path.hasPrefix("/") ? path : "/" + path

        guard !normalizedVersion.isEmpty else {
            return normalizedPath
        }

        return "/" + normalizedVersion + normalizedPath
    }
}
