//
//  Post.swift
//  SwiftuiSocialMediaProject
//
//  Created by Bhavik Bhatt on 06/02/23.
//

import Foundation
import FirebaseFirestoreSwift

struct Post: Codable, Identifiable, Equatable, Hashable{
    @DocumentID var id: String?
    
    
    // basic post content info
    var text: String
    var imageURL: URL?
    var imageReferenceID: String = ""
    var publishedDate: Date = Date()
    var likeIDs: [String] = []
    var dislikedIDs: [String] = []
    
    
    // info of who posted
    var userName: String
    var userUID: String
    var userProfileURL: URL
    
    enum CodingKeys: CodingKey{
        case id
        case text
        case imageURL
        case imageReferenceID
        case publishedDate
        case likeIDs
        case dislikedIDs
        case userName
        case userUID
        case userProfileURL
    }
}
