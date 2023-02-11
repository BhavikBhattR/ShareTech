//
//  Message.swift
//  ShareTech
//
//  Created by Bhavik Bhatt on 11/02/23.
//

import Foundation
import FirebaseFirestoreSwift

struct Message: Identifiable, Codable{
    let fromId, toId, msg: String
    let timestamp: Date
    
    @DocumentID var id: String?
    

}
