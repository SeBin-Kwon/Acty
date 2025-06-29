//
//  ChatEndPoint.swift
//  Acty
//
//  Created by Sebin Kwon on 6/29/25.
//

import Foundation
import Alamofire

enum ChatEndPoint: EndPoint {
    case getChats
    
    var path: String {
        switch self {
        case .getChats: baseURL + "/chats"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getChats: .get
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .getChats: nil
        }
    }
    
    var encoding: ParameterEncoding {
        switch self {
        case .getChats:
            return URLEncoding(destination: .queryString)
        }
    }
    
    var isAuthRequired: Bool {
        true
    }
}


