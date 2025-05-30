//
//  PaperLogy.swift
//  Acty
//
//  Created by Sebin Kwon on 5/22/25.
//

import SwiftUI

enum PaperLogy: ActyFontConvertible {
    case title1
    case body1
    case caption1
    case custom(_ weight: PaperLogyWeight, _ size: CGFloat)
    
    private var name: String {
        switch self {
        case .title1, .body1, .caption1:
            return "Paperlogy-9Black"
        case let .custom(weight, _):
            return "Paperlogy-\(weight.number)\(weight.rawValue)"
        }
    }
    
    private var size: CGFloat {
        switch self {
        case .title1: return 26
        case .body1: return 22
        case .caption1: return 14
        case let .custom(_, size):
            return size
        }
    }
    
    var font: Font {
        return .custom(name, size: size)
    }
    
    var uiFont: UIFont? {
        return UIFont(name: name, size: size)
    }
    
    var height: CGFloat {
        switch self {
        case .title1: return 32
        case .body1: return 20
        case .caption1: return 14
        case let .custom(_, size):
            return size
        }
    }
    
    var kerning: CGFloat {
        return 0
    }
    
}

enum PaperLogyWeight: String {
    case Thin, ExtraLight, Light, Regular, Medium, Semibold, Bold, ExtraBold, Black
    var number: Int {
        switch self {
        case .Thin: 1
        case .ExtraLight: 2
        case .Light: 3
        case .Regular: 4
        case .Medium: 5
        case .Semibold: 6
        case .Bold: 7
        case .ExtraBold: 8
        case .Black: 9
        }
    }
}
