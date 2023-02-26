//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Roman Kavinskyi on 2/12/23.
//

import Foundation

protocol FeedLoader {
    func load(completion: @escaping (ClientLoadResult) -> Void)
}

