//
//  RootRouter.swift
//  Acty
//
//  Created by Sebin Kwon on 5/25/25.
//

import SwiftUI

final class RootRouter: ObservableObject {
    @Published var currentFlow: RootFlow = .splash
}

enum RootFlow: String {
    case splash, auth, main
}
