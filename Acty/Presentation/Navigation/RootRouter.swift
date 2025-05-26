//
//  RootFlow.swift
//  Acty
//
//  Created by Sebin Kwon on 5/25/25.
//

import SwiftUI

enum RootFlow: Sendable {
    case splash
    case auth
    case main
}

extension FlowRouter: EnvironmentKey where T == RootFlow {
    static let defaultValue: FlowRouter<RootFlow> = FlowRouter()
}

extension EnvironmentValues {
    var rootRouter: FlowRouter<RootFlow> {
        get { self[FlowRouter<RootFlow>.self] }
        set { self[FlowRouter<RootFlow>.self] = newValue }
    }
}
