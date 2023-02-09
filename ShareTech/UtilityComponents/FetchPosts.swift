//
//  FetchPosts.swift
//  ShareTech
//
//  Created by Bhavik Bhatt on 08/02/23.
//

import Foundation
import SwiftUI
import Firebase
/*
 vm.selecttedTechnologies (will get this data from environment),
 BaSEDonUID (fixed),
 uid (fixed),
 recentPosts (inout)
 paginationDocument (inout),
 isFetching (inout)
 */

class FetchPosts{
    
    @EnvironmentObject static var vm: TechnologyPickerViewModel
    
    public static func fetchPosts(basedOnUID: Bool, uid: String, recentPosts: inout [Post], paginationDocument: inout QueryDocumentSnapshot?, isFetching: inout Bool)async{
         
            do {
                var query: Query!
      
                if let paginationDocument{
                    if await vm.selectedTechnologies.count > 0{
                        query = await Firestore.firestore().collection("Posts")
                            .whereField("relatedTechnologies", arrayContainsAny: vm.selectedTechnologies)
                            .order(by: "publishedDate", descending: true)
                            .start(afterDocument: paginationDocument)
                            .limit(to: 20)
                    }else{
                        query = Firestore.firestore().collection("Posts")
                            .order(by: "publishedDate", descending: true)
                            .start(afterDocument: paginationDocument)
                            .limit(to: 20)
                    }
                }else{
                    if await vm.selectedTechnologies.count > 0{
                        query = await Firestore.firestore().collection("Posts")
                            .whereField("relatedTechnologies", arrayContainsAny: vm.selectedTechnologies)
                            .order(by: "publishedDate", descending: true)
                            .limit(to: 20)
                    }else{
                        query = Firestore.firestore().collection("Posts")
                            .order(by: "publishedDate", descending: true)
                            .limit(to: 20)
                    }
                }

                if basedOnUID{
                    query = query
                        .whereField("userUID", isEqualTo: uid)
                }
                
                let docs = try await query.getDocuments()
                let fetchedPosts = docs.documents.compactMap { doc -> Post? in
                    try? doc.data(as: Post.self)
                }
                
    
                    for fetchedPost in fetchedPosts {
                        recentPosts.append(fetchedPost)
                    }
//                    recentPosts.append(contentsOf: fetchedPosts)
                    paginationDocument = docs.documents.last
                    isFetching = false
                
                
            } catch  {
                print(error.localizedDescription)
            }
        }
}
