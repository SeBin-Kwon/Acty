//
//  ActyFontConvertible.swift
//  Acty
//
//  Created by Sebin Kwon on 5/22/25.
//

import SwiftUI

protocol FilteeFontConvertible {
    var font: Font { get }
    var uiFont: UIFont? { get }
    var height: CGFloat { get }
    var kerning: CGFloat { get }
}
