//
//  PostFeedViewModel.swift
//  ShareTech
//
//  Created by Bhavik Bhatt on 08/02/23.
//

import Foundation
import SwiftUI
import Firebase

class PostFeedViewModel: ObservableObject{
    
    @Published var recentPosts: [Post] = []
    @Published var isFetching: Bool = true
    @Published var paginationDocument: QueryDocumentSnapshot? = nil
    @Published var basedOnUID: Bool = false
//    @Published var uid: String = ""
    
    func fetchPosts(selectedTechnologies: [String], basedOnUID: Bool, uid: String)async{
        
        print("fetch posts function called from postFeedViewModel")
        print("uid is \(uid)")
        do {
            var query: Query!
                
                if let paginatedDocument = paginationDocument{
                    if selectedTechnologies.count > 0{
                        query = Firestore.firestore().collection("Posts")
                            .whereField("relatedTechnologies", arrayContainsAny: selectedTechnologies)
                            .order(by: "publishedDate", descending: true)
                            .start(afterDocument: paginatedDocument)
                            .limit(to: 20)
                    }else{
                        query = Firestore.firestore().collection("Posts")
                            .order(by: "publishedDate", descending: true)
                            .start(afterDocument: paginatedDocument)
                            .limit(to: 20)
                    }
                }else{
                    if selectedTechnologies.count > 0{
                        query = Firestore.firestore().collection("Posts")
                            .whereField("relatedTechnologies", arrayContainsAny: selectedTechnologies)
                            .order(by: "publishedDate", descending: true)
                            .limit(to: 20)
                    }else{
                        query = Firestore.firestore().collection("Posts")
                            .order(by: "publishedDate", descending: true)
                            .limit(to: 20)
                    }
                }
                
                let docs = try await query.getDocuments()
                let fetchedPosts = docs.documents.compactMap { doc -> Post? in
                    try? doc.data(as: Post.self)
                }
                
                await MainActor.run(body: {
                    recentPosts.append(contentsOf: fetchedPosts)
                    paginationDocument = docs.documents.last
                    isFetching = false
                   
                })
   
        } catch  {
            print(error.localizedDescription)
        }
    }
}
