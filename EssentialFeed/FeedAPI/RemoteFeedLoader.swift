//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Roman Kavinskyi on 2/13/23.
//

import Foundation

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
                completion(self.map(data, from: response))
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }

    private func map(_ data: Data, from response: HTTPURLResponse) -> ClientLoadResult {
        if let items = try? FeedItemsMapper.map(data, response) {
            return .success(items)
        } else {
            return .failure(.invalidData)
        }
    }
}
