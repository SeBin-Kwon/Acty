//
//  mulgyeal.swift
//  Acty
//
//  Created by Sebin Kwon on 5/22/25.
//

import SwiftUI

enum Mulgyeol: FilteeFontConvertible {
    case title1
    case body1
    case caption1
    case custom(_ weight: String, _ size: CGFloat)
    
    private var name: String {
        switch self {
        case .title1, .body1:
            return "Paperlogy"
        case .caption1: return "OTHakgyoansimMulgyeolR"
        case let .custom(weight, _):
            return "OTHakgyoansimMulgyeol\(weight)"
        }
    }
    
    private var size: CGFloat {
        switch self {
        case .title1: return 32
        case .body1: return 20
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

//extension YonderTripsFont {
//    
//    enum Pretendard {
//        case title1
//        case body1
//        case body2
//        case body3
//        case caption1
//        case caption2
//        case caption3
//        
//        var font: Font {
//            switch self {
//            case .title1:
//                return .custom("Pretendard-Bold", size: 20)
//            case .body1:
//                return .custom("Pretendard-Medium", size: 16)
//            case .body2:
//                return .custom("Pretendard-Medium", size: 14)
//            case .body3:
//                return .custom("Pretendard-Medium", size: 13)
//            case .caption1:
//                return .custom("Pretendard-Regular", size: 12)
//            case .caption2:
//                return .custom("Pretendard-Regular", size: 10)
//            case .caption3:
//                return .custom("Pretendard-Regular", size: 8)
//            }
//        }
//    }
//    
//    enum Paperlogy {
//        case slogan1
//        case slogan2
//        case title1
//        case body1
//        case caption1
//        case caption2
//        
//        var font: Font {
//            switch self {
//            case .slogan1:
//                return .custom("Paperlogy-9Black", size: 32)
//            case .slogan2:
//                return .custom("Paperlogy-3Light", size: 16)
//            case .title1:
//                return .custom("Paperlogy-9Black", size: 26)
//            case .body1:
//                return .custom("Paperlogy-9Black", size: 22)
//            case .caption1:
//                return .custom("Paperlogy-9Black", size: 14)
//            case .caption2:
//                return .custom("Paperlogy-8ExtraBold", size: 12)
//            }
//        }
//    }
//}
