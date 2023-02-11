//
//  NewMessageScreenViewModel.swift
//  ShareTech
//
//  Created by Bhavik Bhatt on 11/02/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Firebase
import FirebaseAuth
import Combine

class NewMessageScreenViewModel: ObservableObject{
    
    @Published var allUsers: [User] = []
    @Published var searchText: String = ""
    var anyCancellabels = Set<AnyCancellable>()
    
    init(){
        getAllUsers()
        addSubscriber()
    }
    
    func addSubscriber(){
        $searchText
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .sink { str in
                if str.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty{
                    
                }else{
                    Task{
                        await self.getFilteredUsers()
                    }
                }
            }
            .store(in: &anyCancellabels)
    }
    
    func getFilteredUsers()async{
        Task{
            await MainActor.run {
                self.allUsers = []
            }
                let documents = try? await Firestore.firestore().collection("Users")
                .whereField("Username", isGreaterThanOrEqualTo: searchText)
                .whereField("Username", isLessThanOrEqualTo: "\(searchText)\u{f8ff}")
                .getDocuments()
            
            documents?.documents.forEach({ queryDocument in
               let user = try? queryDocument.data(as: User.self)
              
                if user?.userUID == Auth.auth().currentUser?.uid{
                    
                }else{
                    Task{
                        await MainActor.run(body: {
                            self.allUsers.append(user ?? User(Username: "", userBio: "", userBioLink: "", userUID: "", email: "", profilePicURL: URL(string: "")!))
                        })
                    }
                }
            })
        }
    }
    
    func getAllUsers(){
       Firestore.firestore().collection("Users").getDocuments { querySnapshot, error in
            
            if let error = error{
                print("couldn't fetch all users: \(error)")
            }
            
            guard let querySnapshot = querySnapshot else { return }
            
            querySnapshot.documents.forEach({ snapshot in
                let chatUser = try? snapshot.data(as: User.self)
                
                if chatUser?.userUID == Auth.auth().currentUser?.uid{
                    
                }else{
                    
                    Task{
                        await MainActor.run(body: {
                            self.allUsers.append(chatUser ?? User(Username: "", userBio: "", userBioLink: "", userUID: "", email: "", profilePicURL: URL(string: "")!))
                        })
                    }
                }
            })
        }
    }
    
}
