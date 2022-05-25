//
//  EventLoopGroupConnectionPool+Concurrency.swift
//  
//
//  Created by Johan Carlberg on 2021-12-20.
//

import Vapor

let poolingEventLoopGroup = MultiThreadedEventLoopGroup (numberOfThreads: 2)

extension EventLoopGroupConnectionPool {
    public func withConnection<Result>(
        logger: Logger? = nil,
        on eventLoop: EventLoop? = nil,
        _ closure: @escaping (Source.Connection) async throws -> Result
    ) async throws -> Result {
        let eventLoop = eventLoop ?? self.eventLoopGroup.next()
        logger?.trace ("Requesting connection on \(eventLoop)")
        let result = self.withConnection (logger: logger, on: eventLoop) { connection -> EventLoopFuture<Result> in
            let innerEventLoop = poolingEventLoopGroup.next()
            logger?.trace ("Making promise on \(innerEventLoop)")
            let promise = innerEventLoop.makePromise (of: Result.self)

            Task.detached (priority: .background) {
                do {
                    logger?.trace ("Will run closure")
                    await promise.succeed (try closure (connection))
                    logger?.trace ("Did run closure")
                } catch {
                    logger?.trace ("Closure failed with \(error)")
                    promise.fail (error)
                }
            }

            logger?.trace ("Returning future")
            return promise.futureResult
        }

        logger?.trace ("Waiting for future")
        return try result.wait()
    }
}
