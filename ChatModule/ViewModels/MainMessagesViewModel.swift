//
//  MainMessagesViewModel.swift
//  ShareTech
//
//  Created by Bhavik Bhatt on 11/02/23.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift
import Combine

class MainMessagesViewModel: ObservableObject{
    
    @Published var currentUser: User?
    @Published var allRecentMessages: [RecentMessage] = []
    @Published var imageURL: String = ""
    @Published var userName: String = ""
    @Published var selectedChatUser: User?
    @Published var showPtoPMessageScreen: Bool = false
    @Published var showNewMessageScreen: Bool = false
    @Published var searchText: String = ""
    var anyCancellabels = Set<AnyCancellable>()
    
    init(){
        print("init of main message view model is called")
        self.addSubscriber()
        self.fetchCurrentUser()
        self.fetchRecentMesages()
    }
    
    
    var firestoreListener: ListenerRegistration?
    
     func addSubscriber(){
        self.$searchText
            .sink { searchText in
                if searchText.trimmingCharacters(in: .whitespacesAndNewlines).count > 0{
                    self.showNewMessageScreen = true
                }else{
                    self.showNewMessageScreen = false
                }
            }
            .store(in: &anyCancellabels)
            
    }
    
    func fetchCurrentUser(){
 
        
       guard let uid = Auth.auth().currentUser?.uid else {
           print("returned from start")
           return }
        
        Firestore.firestore().collection("Users").document(uid).getDocument(completion: { [weak self] snapshot, error in
           if let error = error {
               print("failed to fetch the current user: \(error)")
               return
           }
           
           guard let snapshot = snapshot else { return }
           
            guard let currentUser = try? snapshot.data(as: User.self) else {
                return }
            
            self?.currentUser = currentUser
           
       })
   }
    
    func fetchRecentMesages(){
        guard let fromID = Auth.auth().currentUser?.uid else { return }
        
        print("fetch recentmsgs called")
        
        
       firestoreListener =  Firestore.firestore().collection("recentMessages")
            .document(fromID)
            .collection("allMessages")
            .order(by: "timestamp")
            .addSnapshotListener ({ querySnapshot, error in
                if let _ = error {
                    print("error getting recent messages")
                    return
                }
                
                
                querySnapshot?.documentChanges.forEach({ change in
                    let documentId = change.document.documentID
    
                    let data = change.document.data()
                    
            
                        if let index =
                            self.allRecentMessages.firstIndex(where: { recentMesage in
                                return recentMesage.id == documentId
                            }){
                            self.allRecentMessages.remove(at: index)
                        }



                    self.getProfilePicAndUsernameOfUsers(id: documentId ,data: data)
                    
                })
            })
        
    }
    
    func getProfilePicAndUsernameOfUsers(id: String ,data: [String: Any]){
        
        print("getting recent message with user's profile pic")
        
        let timestamp = data["timestamp"] as? Timestamp ?? Timestamp()
        let msg = data["msg"] as? String ?? ""
        let fromId = data["fromId"] as? String ?? ""
        let toId = data["toId"] as? String ?? ""
       print(toId)
        
            Firestore.firestore().collection("Users")
                .whereField("userUID", isEqualTo: toId)
                .getDocuments { QuerySnapshot, error in
                    if let error = error{
                        print(error.localizedDescription)
                    }
                    
                    QuerySnapshot?.documents.forEach({ documentSnap in
                        let otherEndUser = documentSnap.data()
                        let imageURL = otherEndUser["profilePicURL"] as? String ?? ""
                        let userName = otherEndUser["Username"] as? String ?? ""
                        
                        print("username: \(userName)")
                        
                        self.allRecentMessages.append(.init(fromId: fromId, toId: toId, msg: msg, imageURLOfOtherPerson: imageURL, userNameOfOtherPerson: userName, timeStamp: timestamp, id: id))
                        
                        print("recent msgs are:")
                        print(self.allRecentMessages)
                        
                        self.allRecentMessages = self.allRecentMessages.sorted(by: {
                            $0.timestampAsDate > $1.timestampAsDate
                           
                        })
                        
                        
                    })
                }
    }
    
    func getSelectedUser(selectedUserId: String, completion: @escaping((_: User?) -> ())){
   
        var selectedUser: User?
        let g = DispatchGroup()
        
          let document =  Firestore.firestore().collection("Users")
            .document(selectedUserId)
        g.enter()
        document.getDocument { documentSnap, error  in
            if let error = error{
                print(error)
                g.leave()
                return
            }else{
                do{
                    selectedUser = try documentSnap?.data(as: User.self)
                    g.leave()
                }catch{
                    print(error)
                    g.leave()
                }
            }
        }
        g.notify(queue: .main){
            completion(selectedUser)
        }
    }
    
}
