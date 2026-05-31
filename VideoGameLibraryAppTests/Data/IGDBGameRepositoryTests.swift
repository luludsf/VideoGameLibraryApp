//
//  IGDBGameRepositoryTests.swift
//  VideoGameLibraryAppTests
//
//  Created by Luana Duarte on 31/05/26.
//

import Foundation
import Testing
import NetworkingKit
@testable import VideoGameLibraryApp

@MainActor
struct IGDBGameRepositoryTests {
    @Test
    func fetchGamesMapsResponseIntoDomainItems() async throws {
        let networking = NetworkingSpy(result: .success([
            IGDBGameResponse(
                id: 99,
                name: "Zelda",
                cover: IGDBCoverResponse(imageId: "cover123", id: 10)
            )
        ]))
        let sut = IGDBGameRepository(networking: networking)

        let games = try await sut.fetchGames()

        #expect(networking.performCallCount == 1)
        #expect(games.count == 1)
        #expect(games[0].id == "99")
        #expect(games[0].title == "Zelda")
        #expect(games[0].imageURL?.absoluteString == "https://images.igdb.com/igdb/image/upload/t_cover_big/cover123.jpg")
        #expect(games[0].isFavorite == false)
    }

    @Test
    func fetchGamesMapsNilImageURLWhenResponseHasNoCoverImageId() async throws {
        let networking = NetworkingSpy(result: .success([
            IGDBGameResponse(
                id: 11,
                name: "Celeste",
                cover: IGDBCoverResponse(imageId: nil, id: 44)
            )
        ]))
        let sut = IGDBGameRepository(networking: networking)

        let games = try await sut.fetchGames()

        #expect(games.count == 1)
        #expect(games[0].id == "11")
        #expect(games[0].title == "Celeste")
        #expect(games[0].imageURL == nil)
    }

    @Test
    func fetchGamesMapsNetworkingErrorsToTheExpectedCase() async {
        let networking = NetworkingSpy(result: .failure(NetworkingError.httpError(code: 401)))
        let sut = IGDBGameRepository(networking: networking)

        do {
            _ = try await sut.fetchGames()
            Issue.record("Expected fetchGames to throw")
        } catch let error as GameListRequestError {
            if case .requestFailed(let statusCode) = error {
                #expect(statusCode == 401)
            } else {
                Issue.record("Expected GameListRequestError.requestFailed(statusCode:)")
            }
        } catch {
            Issue.record("Expected GameListRequestError, got \(error)")
        }
    }
}
