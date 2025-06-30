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
    case createChats(String)
    case sendChat(String)
    
    var path: String {
        switch self {
        case .getChats: baseURL + "/chats"
        case .createChats: baseURL + "/chats"
        case .sendChat(let id): baseURL + "/chats" + id
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getChats: .get
        case .createChats, .sendChat: .post
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .getChats, .createChats: nil
        case .sendChat(let id): ["room_id": id]
        }
    }
    
    var encoding: ParameterEncoding {
        switch self {
        case .getChats:
            return URLEncoding(destination: .queryString)
        case .createChats, .sendChat:
            return JSONEncoding.default
        }
    }
    
    var isAuthRequired: Bool {
        true
    }
}


