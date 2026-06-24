//
//  ClipBoardItem.swift
//  ClipBoard
//
//  Created by Phan Trong Nguyen on 24/6/26.
//


import SwiftData
import Foundation

enum ClipBoardContentType: String, Codable {
    case text, image, file
}

@Model
class ClipBoardItem {
    var id: UUID
    var content: String
    var contentType: ClipBoardContentType
    var imageData: Data?
    var isPinned: Bool
    var createdAt: Date
    var appSource: String?
    
    init(
        content: String,
        contentType: ClipBoardContentType = .text,
        imageData: Data? = nil,
        isPinned: Bool = false,
        appSource: String? = nil
    ) {
        self.id = UUID()
        self.content = content
        self.contentType = contentType
        self.imageData = imageData
        self.isPinned = isPinned
        self.createdAt = Date()
        self.appSource = appSource
    }
}
