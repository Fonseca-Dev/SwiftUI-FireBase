//
//  Message.swift
//  iChat
//
//  Created by Kaue Rocha da Fonseca on 16/05/26.
//

import Foundation

struct Message : Hashable {
    let uuid: String
    let text: String
    let isMe: Bool
    let timestamp: UInt
}
