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
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }

            switch result {
            case let .success((data, response)):
                completion(FeedItemsMapper.map(data, from: response))
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}
