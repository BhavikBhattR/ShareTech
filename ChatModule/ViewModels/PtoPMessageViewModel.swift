//
//  PtoPMessageViewModel.swift
//  ShareTech
//
//  Created by Bhavik Bhatt on 11/02/23.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

class PtoPMessageViewModel: ObservableObject{
    
    @Published var msg: String = ""
    @Published var chatMessages: [Message] = []
    @Published var count: Int = 0
    var firebaseListener: ListenerRegistration?
    var receiver: User?
    
    init(receiver: User?){
        self.receiver = receiver
        getAllMessages()
      
    }
    
    func getAllMessages(){
        guard let fromId = Auth.auth().currentUser?.uid else { return }
        
        guard let toId = receiver?.id else{
            return
        }
        
        firebaseListener?.remove()
        chatMessages.removeAll()
        
        firebaseListener = Firestore.firestore().collection("messages")
            .document(fromId)
            .collection(toId)
            .order(by: "timestamp")
            .addSnapshotListener({ querySnapshot, error in
                if let error = error{
                    print(error.localizedDescription)
                }
                
                querySnapshot?.documentChanges.forEach({ change in
                    if change.type == .added{
                        do{
                            let msg = try change.document.data(as: Message.self)
                            self.chatMessages.append(msg ?? Message(fromId: "", toId: "", msg: "", timestamp: Timestamp().dateValue()))
                        }catch{
                            print(error)
                        }
                    }
                })
                self.count += 1
            })
    }
    
    func handleSendingMessage(){
        guard let fromId = Auth.auth().currentUser?.uid else {
            print("fromId is nil")
            return
        }
        guard let toId = receiver?.id else {
            print("receiver is nil")
            return
        }
        
        let trimmedMessage = msg.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if(trimmedMessage.isEmpty){
            self.msg = ""
            print("message is empty")
            return
        }
        
        let msgData = Message(fromId: fromId, toId: toId, msg: msg, timestamp: Timestamp().dateValue())
        
        print("msg data is")
        print(msgData)
        
        let senderDocument = Firestore.firestore()
            .collection("messages")
            .document(fromId)
            .collection(toId)
            .document()
        
        try? senderDocument.setData(from: msgData) { error in
            if let error = error{
                print(error)
            }
        }
        
        
        // so that receiver can have his own document for the msgs between him and this user
        let receiverDocument = Firestore.firestore().collection("messages")
            .document(toId)
            .collection(fromId)
            .document()
        
        try? receiverDocument.setData(from: msgData){ error in
            if let error = error {
                print(error)
            }
        }
        
        persistRecentMessageFor2Users(fromId: fromId, toId: toId)
        
        
        
        self.msg = ""
    }
    
    
    // This function is for storing the most recent msg between 2 users
    private func persistRecentMessageFor2Users(fromId: String, toId: String){
        
        let recentMsgDataForSender: [String: Any] = [
            "timestamp": Timestamp(),
            "msg": msg,
            "fromId": fromId,
            "toId": toId
        ]
        
        let Senderdocument = Firestore.firestore().collection("recentMessages")
             .document(fromId)
             .collection("allMessages")
             .document(toId)
         
         
         Senderdocument.setData(recentMsgDataForSender) { error in
             if let error = error{
                 print("error updating recent msgs \(error)")
                 return
             }
         }
         
         // For Receiver
         
         let recentMsgDataForReceiver : [String : Any] = [
             "timestamp": Timestamp(),
             "msg": msg,
             "toId": fromId,
             "fromId": toId
         ]
        
        let ReceiverDocument =  Firestore.firestore().collection("recentMessages")
              .document(toId)
              .collection("allMessages")
              .document(fromId)
          
          
          ReceiverDocument.setData(recentMsgDataForReceiver) { error in
              if let error = error{
                  print("error updating recent msgs \(error)")
                  return
              }
          }
        
        print("data strored for both the users")
    }
    
    
    
}


