import Foundation

public final class URLSessionClient: Networking {
    private let session: URLSession
    private let decoder: JSONDecoder
    private let timeoutInterval: TimeInterval

    public init(
        session: URLSession = {
            let configuration = URLSessionConfiguration.default
            configuration.urlCache = URLCache(
                memoryCapacity: 50 * 1024 * 1024,
                diskCapacity: 100 * 1024 * 1024,
                directory: nil
            )
            configuration.requestCachePolicy = .useProtocolCachePolicy
            return URLSession(configuration: configuration)
        }(),
        decoder: JSONDecoder = {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return decoder
        }(),
        timeoutInterval: TimeInterval = 10
    ) {
        self.session = session
        self.decoder = decoder
        self.timeoutInterval = timeoutInterval
    }

    public func perform<T>(_ request: Request) async throws -> T where T: Decodable {
        let data = try await execute(request)

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkingError.decodingFailed(error)
        }
    }

    private func execute(_ request: Request) async throws -> Data {
        var components = URLComponents()
        components.scheme = request.scheme
        components.host = request.host
        components.path = request.resolvedPath

        if let queryParams = request.queryParams {
            components.queryItems = queryParams.map {
                URLQueryItem(name: $0.key, value: $0.value)
            }
        }

        guard let url = components.url else {
            throw NetworkingError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.timeoutInterval = timeoutInterval
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let headers = request.headers {
            urlRequest.allHTTPHeaderFields = headers
        }

        if let bodyDict = request.bodyParams {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: bodyDict)
                urlRequest.httpBody = jsonData
            } catch {
                throw NetworkingError.invalidBodyData
            }
        }

        do {
            let (data, response) = try await session.data(for: urlRequest)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkingError.invalidResponse
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                throw NetworkingError.httpError(code: httpResponse.statusCode)
            }

            return data
        } catch let error as URLError {
            switch error.code {
            case .notConnectedToInternet:
                throw NetworkingError.noInternetConnection
            case .timedOut:
                throw NetworkingError.timeout
            case .cancelled:
                throw NetworkingError.cancelled
            default:
                throw NetworkingError.requestFailed(error)
            }
        } catch {
            throw error
        }
    }
}
