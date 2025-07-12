//
//  Int+Extension.swift
//  Acty
//
//  Created by Sebin Kwon on 7/12/25.
//

import Foundation

extension Int {
    var formattedWithComma: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
