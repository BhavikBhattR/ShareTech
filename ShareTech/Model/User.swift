//
//  User.swift
//  SwiftuiSocialMediaProject
//
//  Created by Bhavik Bhatt on 05/02/23.
//

import Foundation
import FirebaseFirestoreSwift

struct User: Codable, Identifiable{
    
    @DocumentID var id: String?
    var Username: String
    var userBio: String
    var userBioLink: String
    var userUID: String
    var email: String 
    var profilePicURL: URL
    
    enum CodingKeys: CodingKey{
        case id
        case Username
        case userBio
        case userBioLink
        case userUID
        case email
        case profilePicURL
    }
}
