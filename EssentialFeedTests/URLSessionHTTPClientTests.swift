//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Roman Kavinskyi on 2/26/23.
//

import XCTest
import EssentialFeed

final class URLSessionHTTPClientTests: XCTestCase {

    func test_getFromURL_resumesDataTaskWithURL() {
        let url = URL(string: "http://any-url.com")!
        let session = MockURLSession()
        let task = MockURLSessionDataTask()
        session.stub(url: url, task: task)
        let sut = URLSessionHTTPClient(session: session)
        sut.get(from: url) { _ in}

        XCTAssertEqual(task.resumeCallCount, 1)
    }

    func test_getFromURL_FailOnRequestError() {
        let url = URL(string: "http://any-url.com")!
        let error = NSError(domain: "any error", code: 1)

        let session = MockURLSession()
        session.stub(url: url, error: error)

        let sut = URLSessionHTTPClient(session: session)

        let expectation = expectation(description: "Wait for completion")

        sut.get(from: url) { result in
            switch result {
            case .failure(let receivedError as NSError):
                XCTAssertEqual(receivedError, error)
            default: XCTFail("Expected failure with error \(error), got \(result) instead")
            }

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)

    }

    // MARK: - Helpers

    private class MockURLSession: HTTPSession {

        private struct Stub {
            let task: HTTPSessionTask
            let error: Error?
        }

        private var stubs = [URL: Stub]()

        func stub(
            url: URL,
            task: HTTPSessionTask = MockURLSessionDataTask(),
            error: Error? = nil
        ) {
            stubs[url] = Stub(task: task, error: error)
        }

        func dataTask(
            with url: URL,
            completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
        ) -> HTTPSessionTask {
            guard let stub = stubs[url] else {
                fatalError("Couldn't file stub for \(url)")
            }

            completionHandler(nil, nil, stub.error)
            return stub.task
        }
    }

    private class MockURLSessionDataTask: HTTPSessionTask {
        var resumeCallCount = 0

        func resume() {
            resumeCallCount += 1
        }
    }
}

protocol HTTPSessionTask {
    func resume()
}

protocol HTTPSession {
    func dataTask(
       with url: URL,
       completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
   ) -> HTTPSessionTask
}

class URLSessionHTTPClient {
    private let session: HTTPSession

    init(session: HTTPSession) {
        self.session = session
    }

    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error {
                completion(.failure(error))
            }
        }.resume()
    }
}
