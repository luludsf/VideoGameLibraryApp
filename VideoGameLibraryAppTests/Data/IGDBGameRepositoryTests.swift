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
                cover: IGDBCoverResponse(imageId: "cover123", id: 10),
                rating: 91.4,
                summary: "Uma aventura epica.",
                totalRating: 90.1,
                platforms: [
                    IGDBPlatformResponse(name: "Nintendo Switch"),
                    IGDBPlatformResponse(name: "Wii U")
                ]
            )
        ]))
        let sut = IGDBGameRepository(networking: networking)

        let page = try await sut.fetchGames(searchQuery: nil, offset: 0, limit: 25)
        let games = page.items

        #expect(networking.performCallCount == 1)
        #expect(games.count == 1)
        #expect(games[0].id == "99")
        #expect(games[0].title == "Zelda")
        #expect(games[0].imageURL?.absoluteString == "https://images.igdb.com/igdb/image/upload/t_cover_big/cover123.jpg")
        #expect(games[0].summary == "Uma aventura epica.")
        #expect(games[0].rating == 91.4)
        #expect(games[0].platforms == ["Nintendo Switch", "Wii U"])
        #expect(games[0].isFavorite == false)
        #expect(page.nextOffset == nil)
    }

    @Test
    func fetchGamesFallsBackToTotalRatingWhenRatingIsMissing() async throws {
        let networking = NetworkingSpy(result: .success([
            IGDBGameResponse(
                id: 12,
                name: "Metroid",
                cover: nil,
                rating: nil,
                summary: nil,
                totalRating: 88.6,
                platforms: nil
            )
        ]))
        let sut = IGDBGameRepository(networking: networking)

        let games = try await sut.fetchGames(searchQuery: nil, offset: 0, limit: 25).items

        #expect(games.count == 1)
        #expect(games[0].rating == 88.6)
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

        let games = try await sut.fetchGames(searchQuery: nil, offset: 0, limit: 25).items

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
            _ = try await sut.fetchGames(searchQuery: nil, offset: 0, limit: 25)
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

    @Test
    func fetchGamesForwardsSearchQueryToRequest() async throws {
        let networking = NetworkingSpy(result: .success([]))
        let sut = IGDBGameRepository(networking: networking)

        _ = try await sut.fetchGames(searchQuery: "Halo", offset: 25, limit: 25)

        let rawBody = String(data: try #require(networking.lastRequest?.rawBody), encoding: .utf8)
        #expect(rawBody?.contains("search \"Halo\";") == true)
        #expect(rawBody?.contains("rating") == true)
        #expect(rawBody?.contains("summary") == true)
        #expect(rawBody?.contains("total_rating") == true)
        #expect(rawBody?.contains("platforms.name") == true)
        #expect(rawBody?.contains("where version_parent = null;") == true)
        #expect(rawBody?.contains("offset 25;") == true)
        #expect(rawBody?.contains("limit 25;") == true)
    }
}
