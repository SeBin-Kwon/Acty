//
//  SignUpRequestDTO.swift
//  Acty
//
//  Created by Sebin Kwon on 6/4/25.
//

import Foundation

struct SignUpRequestDTO {
    let email: String
    let password: String
    let nick: String
    let phoneNum: String = ""
    let introduction: String = ""
    let deviceToken: String = ""
}
