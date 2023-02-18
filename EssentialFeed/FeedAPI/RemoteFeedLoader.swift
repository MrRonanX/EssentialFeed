//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Roman Kavinskyi on 2/13/23.
//

import Foundation

public typealias HTTPClientResult = Result<(Data, HTTPURLResponse), Error>
public typealias ClientLoadResult = Result<[FeedItem], RemoteFeedLoader.Error>

public protocol HTTPClient {
    func get(from url: URL?, completion: @escaping (HTTPClientResult) -> Void)
}

public final class RemoteFeedLoader {
    private let url: URL?
    private let client: HTTPClient

    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

    public init(client: HTTPClient, url: URL?) {
        self.client = client
        self.url = url
    }

    public func load(completion: @escaping (ClientLoadResult) -> Void) {
        client.get(from: url) { result in

            switch result {
            case let .success((data, response)):
                if let items = try? FeedItemsMapper.map(data, response) {
                    completion(.success(items))
                } else {
                    completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}

private class FeedItemsMapper {

    struct Root: Decodable {
        let items: [Item]
    }

    struct Item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL

        var item: FeedItem {
            return FeedItem(
                id: id,
                description: description,
                location: location,
                imageURL: image
            )
        }
    }

    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedItem] {
        guard response.statusCode == 200 else {
            throw RemoteFeedLoader.Error.invalidData
        }

        let root = try JSONDecoder().decode(Root.self, from: data)
        return root.items.map { $0.item }
    }
}


