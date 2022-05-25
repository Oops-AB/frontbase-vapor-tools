//
//  FrontbaseConnectionSource+Storage.swift
//  
//
//  Created by Johan Carlberg on 2022-05-23.
//

import Frontbase
import Vapor
import ConnectionPoolConcurrency

public protocol FrontbaseConnectionPoolKey: StorageKey where Value == EventLoopGroupConnectionPool<FrontbaseConnectionSource> {}

public extension FrontbaseConnectionSource {
    func use<Key: FrontbaseConnectionPoolKey> (application: Application, key: Key.Type, maxConnectionsPerEventLoop: Int, logger: Logger, on eventLoopGroup: EventLoopGroup) {
        let pool = EventLoopGroupConnectionPool (source: self, maxConnectionsPerEventLoop: maxConnectionsPerEventLoop, logger: logger, on: eventLoopGroup)
        application.storage.set (key, to: pool, onShutdown: { $0.shutdown() })
    }
}

public extension Request {
    struct NoDatabasePoolError: Error {
    }

    func withConnection<Key: FrontbaseConnectionPoolKey, Result> (_ databaseKey: Key.Type, closure: @escaping (FrontbaseConnection) -> EventLoopFuture<Result>) -> EventLoopFuture<Result> {
        guard let pool = application.storage[databaseKey] else {
            return eventLoop.makeFailedFuture (NoDatabasePoolError())
        }

        return pool.withConnection (closure)
    }

    func withConnection<Key: FrontbaseConnectionPoolKey, Result> (_ databaseKey: Key.Type, closure: @escaping (FrontbaseConnection) async throws -> Result) async throws -> Result {
        guard let pool = application.storage[databaseKey.self] else {
            throw NoDatabasePoolError()
        }

        return try await pool.withConnection (closure)
    }
}
