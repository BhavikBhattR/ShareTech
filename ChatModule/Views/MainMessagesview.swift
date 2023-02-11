//
//  MainMessagesview.swift
//  ShareTech
//
//  Created by Bhavik Bhatt on 11/02/23.
//

import SwiftUI
import Firebase
import FirebaseAuth
import SDWebImageSwiftUI


struct MainMessagesview: View {
    
    @StateObject var vmOfMainMessage = MainMessagesViewModel()
    @StateObject var PtoPmessageViewModel = PtoPMessageViewModel(receiver: nil)
    
    
    var body: some View {
        NavigationStack{
            customeNavBar
                .hAligned(alignment: .center)
                .background(.black.opacity(0.8))
            allMessages
                .navigationDestination(isPresented: $vmOfMainMessage.showPtoPMessageScreen, destination:{ PtoPMessageView(vm: PtoPmessageViewModel)
                })
            newMessageButton
              
        }
    }
    
  
}

struct MainMessagesview_Previews: PreviewProvider {
    static var previews: some View {
        MainMessagesview()
    }
}

extension MainMessagesview{
    
    private var customeNavBar: some View{
        HStack(spacing: 16){
            //vmOfMainMessage.imageURL ??
            WebImage(url: vmOfMainMessage.currentUser?.profilePicURL)
                .resizable()
                .scaledToFill()
                .clipped()
                .frame(width: 60, height: 60)
                .cornerRadius(50)
                .overlay {
                    RoundedRectangle(cornerRadius: 50)
                        .stroke(style: StrokeStyle(lineWidth: 2))
                        .shadow(color: .white,radius: 2)
                }
            // vmOfMainMessage.userName
            Text(vmOfMainMessage.currentUser?.Username ?? "Usename not found" )
                .foregroundColor(.white)
        }
        .padding()
   
    }
    
    
    private func returnRowOfUser(recentMessage: RecentMessage) -> some View{
        VStack{
          
            HStack(spacing: 16){
                

                WebImage(url: URL(string: recentMessage.imageURLOfOtherPerson ))
                    .resizable()
                    .scaledToFill()
                    .clipped()
                    .frame(width: 50, height: 50)
                    .cornerRadius(50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 50)
                            .stroke(style: StrokeStyle(lineWidth: 1))
                    )
                    

                VStack(alignment: .leading){
                    Text(recentMessage.userNameOfOtherPerson )
                        .font(.system(size: 16))
                        .fontWeight(.bold)
                        .foregroundColor(Color.black)
                    Text(recentMessage.msg)
                        .font(.system(size: 14))
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                }

                Spacer()

                Text(recentMessage.timeAgo)
                    .font(.system(size: 14))
                    .fontWeight(.semibold)
                    .foregroundColor(Color.black)

            }
            
            Divider()
        }
        .padding(.horizontal)
    }
    
    private var allMessages: some View{
        ScrollView{
            ScrollViewReader{ proxy in
                ForEach(vmOfMainMessage.allRecentMessages){recentMessage in
                    Button{
                        let otherUserID = Auth.auth().currentUser?.uid == recentMessage.fromId ? recentMessage.toId : recentMessage.fromId
//                        let userName = recentMessage.userNameOfOtherPerson
//                        let imageURL = recentMessage.imageURLOfOtherPerson
                        let _ = vmOfMainMessage.getSelectedUser(selectedUserId: otherUserID) { selectedUser in
                            vmOfMainMessage.selectedChatUser = selectedUser
                            self.PtoPmessageViewModel.receiver = vmOfMainMessage.selectedChatUser
                            self.PtoPmessageViewModel.getAllMessages()
                            vmOfMainMessage.showPtoPMessageScreen.toggle()
                        }
                    }label:{
                        returnRowOfUser(recentMessage: recentMessage)
                    }
                }
                .padding(.bottom, 50)
                .navigationDestination(isPresented: $vmOfMainMessage.showPtoPMessageScreen) {
                        PtoPMessageView(vm: PtoPmessageViewModel)
                    }
            }
            .padding(.top)
        }
        .refreshable {
            vmOfMainMessage.allRecentMessages = []
            vmOfMainMessage.fetchRecentMesages()
        }
    }
    
    private var newMessageButton: some View{
        Button {
            vmOfMainMessage.showNewMessageScreen.toggle()
        } label: {
            HStack{
                Spacer()
                Text("+ new message")
                Spacer()
            }
            .padding(.vertical)
            .background(Color.black.opacity(0.6))
            .cornerRadius(10)
            .padding(.horizontal)
            .shadow(color: Color.black.opacity(0.6), radius: 2)
            .foregroundColor(.white)
            .font(.headline)
            .fullScreenCover(isPresented: $vmOfMainMessage.showNewMessageScreen) {
                NewMessageScreen(isUserSelectedForChat: { user in
                    vmOfMainMessage.selectedChatUser = user
                    self.PtoPmessageViewModel.receiver = user
                    self.PtoPmessageViewModel.getAllMessages()
                    vmOfMainMessage.showPtoPMessageScreen = true
                    vmOfMainMessage.showNewMessageScreen = false
                })
            }
        }
        .padding(.bottom)
    }
    
}
