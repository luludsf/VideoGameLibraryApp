//
//  NetworkingSpy.swift
//  VideoGameLibraryAppTests
//
//  Created by Luana Duarte on 31/05/26.
//

import Foundation
import NetworkingKit
@testable import VideoGameLibraryApp

final class NetworkingSpy: Networking {
    var performCallCount = 0
    var result: Result<[IGDBGameResponse], Error>

    init(result: Result<[IGDBGameResponse], Error>) {
        self.result = result
    }

    func perform<T>(_ request: Request) async throws -> T where T: Decodable {
        performCallCount += 1
        return try result.get() as! T
    }
}
