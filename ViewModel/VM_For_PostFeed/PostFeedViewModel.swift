//
//  PostFeedViewModel.swift
//  ShareTech
//
//  Created by Bhavik Bhatt on 08/02/23.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseFirestoreSwift




class PostFeedViewModel: ObservableObject{
    
    @Published var recentPosts: [Post] = []
    @Published var isFetching: Bool = true
    @Published var basedOnUID: Bool = false
    @Published var paginationDocument: QueryDocumentSnapshot? = nil
    @Published  var messageOnSwipe: String = ""
    @Published  var showSwipeEffect: Bool = false
    @Published var color = Color.red
    var listener: ListenerRegistration?
    var fetchedPosts: [Post] = []
//    @Published var uid: String = ""
    
    func fetchPosts(selectedTechnologies: [String], basedOnUID: Bool, uid: String)async{
        
        print("fetch posts function called from postFeedViewModel")
        print("uid is \(uid)")
     
                    
            var query: Query!
            
            if selectedTechnologies.count > 0{
                query =  Firestore.firestore().collection("Posts")
                    .whereField("relatedTechnologies", arrayContainsAny: selectedTechnologies)
                    .order(by: "publishedDate", descending: true)
            }else{
                query = Firestore.firestore().collection("Posts")
                    .order(by: "publishedDate", descending: true)
            }
            
                  listener =  query
                            .addSnapshotListener{ querySnapshot, error in
                                if let error = error{
                                    print(error)
                                    return
                                }
                                
                                querySnapshot?.documentChanges.forEach({ change in
                                    if change.type == .added{
                                        Task{
                                            do{
                                                let post = try change.document.data(as: Post.self)
                                                DispatchQueue.main.async {
                                                    self.recentPosts.insert(post!, at: 0)
                                                    self.isFetching = false
                                                }
                                                
                                            }
                                            catch{
                                                print(error)
                                            }
                                            
                                        }
                                    }
                                    print("listening......")
                                })
                                
                            }
                    
           
        
        }
    }

