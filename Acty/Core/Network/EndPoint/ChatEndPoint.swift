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
    case sendChat(String, ChatRequestDTO)
    case getChatHistory(String, String)
    case uploadChatFiles(String, [Data])
    
    var path: String {
        switch self {
        case .getChats: baseURL + "/chats"
        case .createChats: baseURL + "/chats"
        case .sendChat(let id, _), .getChatHistory(let id, _): baseURL + "/chats/" + id
        case .uploadChatFiles(let id, _): baseURL + "/chats/" + id + "/files"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getChats, .getChatHistory: .get
        case .createChats, .sendChat, .uploadChatFiles: .post
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .getChats: nil
        case .createChats(let id): ["opponent_id": id]
        case .sendChat(_, let message): ["content": message.content, "files": message.files]
        case .getChatHistory(let id, let date): ["room_id": id, "next": date]
        case .uploadChatFiles: nil
        }
    }
    
    var encoding: ParameterEncoding {
        switch self {
        case .getChats, .getChatHistory:
            return URLEncoding(destination: .queryString)
        case .createChats, .sendChat, .uploadChatFiles:
            return JSONEncoding.default
        }
    }
    
    var isAuthRequired: Bool {
        true
    }
}


