//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Roman Kavinskyi on 2/19/23.
//

import Foundation

final class FeedItemsMapper {

    struct Root: Decodable {
        let items: [Item]

        var feed: [FeedItem] {
            items.map { $0.item }
        }
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

    private static var OK_200: Int { 200 }

    static func map(_ data: Data, from response: HTTPURLResponse) -> ClientLoadResult {
        guard response.statusCode == OK_200,
            let root = try? JSONDecoder().decode(Root.self, from: data) else {
            return .failure(.invalidData)
        }

        return .success(root.feed)
    }
}
