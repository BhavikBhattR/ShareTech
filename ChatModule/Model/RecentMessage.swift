//
//  RecentMessage.swift
//  ShareTech
//
//  Created by Bhavik Bhatt on 11/02/23.
//

import Foundation
import FirebaseFirestore
import Firebase
import FirebaseFirestoreSwift


struct RecentMessage: Identifiable, Codable{
    
    let fromId, toId, msg: String
    let imageURLOfOtherPerson: String
    let userNameOfOtherPerson: String
    let timeStamp: Timestamp
    var id: String
    
    var timestampAsDate: Date{
        return timeStamp.dateValue()
    }
    
    var timeAgo: String{
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestampAsDate, relativeTo: Date())
    }
    
}
