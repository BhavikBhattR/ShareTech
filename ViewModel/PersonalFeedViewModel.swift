//
//  PersonalFeedViewModel.swift
//  ShareTech
//
//  Created by Bhavik Bhatt on 08/02/23.
//


import Foundation
import SwiftUI
import Firebase

class PersonalFeedModel: ObservableObject{
    @Published var recentPostsOfOwn: [Post] = []
    @Published var isFetching: Bool = true
    @Published var paginationDocumentForPersonalFeed: QueryDocumentSnapshot? = nil
    @Published var basedOnUID: Bool = false
//    @Published var uid: String = ""
    
    func fetchPosts(selectedTechnologies: [String], basedOnUID: Bool, uid: String)async{
        
        
        print("fetch posts function from personal feed mode called")
       
        do {
            var query: Query!
            
                if selectedTechnologies.count > 0{
                    query = Firestore.firestore().collection("Posts")
                        .whereField("relatedTechnologies", arrayContainsAny: selectedTechnologies)
                        .whereField("userUID", isEqualTo: uid)
                        .order(by: "publishedDate", descending: true)
                }else{
                    query = Firestore.firestore().collection("Posts")
                        .whereField("userUID", isEqualTo: uid)
                        .order(by: "publishedDate", descending: true)
                }
            
            
            
//                query = Firestore.firestore().collection("Posts")
//                    .whereField("userUID", isEqualTo: uid)
//                    .order(by: "publishedDate", descending: true)
//                    .limit(to: 20)
                let docs = try await query.getDocuments()
                let fetchedPosts = docs.documents.compactMap { doc -> Post? in
                    try? doc.data(as: Post.self)
                    
                }
                await MainActor.run(body: {
                    recentPostsOfOwn.append(contentsOf: fetchedPosts)
                    paginationDocumentForPersonalFeed = docs.documents.last
                    isFetching = false
                })

        } catch  {
            print(error.localizedDescription)
        }
    }
}

