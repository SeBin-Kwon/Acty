//
//  FlowRouter.swift
//  Acty
//
//  Created by Sebin Kwon on 5/23/25.
//

import Foundation

final class FlowRouter<T: Sendable>: Sendable {
    @MainActor
    private var continuation: AsyncStream<T>.Continuation?
    
    func `switch`(_ flow: T) async {
        await continuation?.yield(flow)
    }
    
    @MainActor
    var stream: AsyncStream<T> {
        return AsyncStream { [weak self] continuation in
            Task { @Sendable in
                self?.continuation = continuation
            }
        }
    }
}
