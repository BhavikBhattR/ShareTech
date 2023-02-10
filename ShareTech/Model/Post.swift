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
    var imageURL: [URL] = []
    var imageReferenceID: [String] = []
    var publishedDate: Date = Date()
    var likeIDs: [String] = []
    var dislikedIDs: [String] = []
    
    
    
    // info of who posted
    var userName: String
    var userUID: String
    var userProfileURL: URL
    var relatedTechnologies: [String] = []
    var postTopic: String = ""
    
//    init(postData: [String: Any]){
//        self.text = postData["text"] as! String
//        self.imageURL = postData["imageURL"] as! [URL]
//        self.imageReferenceID = postData["imageReferenceID"] as! [String]
//        self.publishedDate = postData["publishedDate"] as! Date
//        self.likeIDs = postData["likeIDs"] as! [String]
//        self.dislikedIDs = postData["dislikedIDs"] as! [String]
//        self.userName = postData["userName"] as! String
//        self.userUID = postData["userUID"] as! String
//        self.userProfileURL = postData["userProfileURL"] as! URL
//        self.relatedTechnologies = postData["relatedTechnologies"] as! [String]
//        self.postTopic = postData["postTopic"] as! String
//    }
    
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
        case postTopic
        case relatedTechnologies
    }
}
