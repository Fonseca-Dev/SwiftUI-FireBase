//
//  File.swift
//  iChat
//
//  Created by Kaue Rocha da Fonseca on 16/05/26.
//

import Foundation

struct Contact : Hashable {
    let uuid:String
    let name:String
    let profileUrl:String
    var lastMessage:String?
    var timestamp:UInt?
    
    init(uuid: String, name: String, profileUrl: String, lastMessage: String?, timestamp: UInt?) {
        self.uuid = uuid
        self.name = name
        self.profileUrl = profileUrl
        self.lastMessage = lastMessage
        self.timestamp = timestamp
    }
    
    init(uuid: String, name: String, profileUrl: String) {
        self.uuid = uuid
        self.name = name
        self.profileUrl = profileUrl
    }
}
