//
//  HTTPClientProtocol.swift
//  EssentialFeed
//
//  Created by Roman Kavinskyi on 2/19/23.
//

import Foundation

public typealias HTTPClientResult = Result<(Data, HTTPURLResponse), Error>
public typealias ClientLoadResult = Result<[FeedItem], RemoteFeedLoader.Error>

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
