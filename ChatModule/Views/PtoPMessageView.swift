//
//  PtoPMessageView.swift
//  ShareTech
//
//  Created by Bhavik Bhatt on 11/02/23.
//

import SwiftUI
import FirebaseAuth
import Firebase

struct PtoPMessageView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var vm: PtoPMessageViewModel
    @FocusState var showKeyboard: Bool 
    var body: some View {
        VStack{
            customNavBar
            allMessages
            bottombar
        }.toolbar(.hidden, for: .navigationBar)
    }
}

private struct DescriptionPlaceholder: View {
    var body: some View {
        HStack {
            Text("Type your msg here")
                .foregroundColor(Color(.gray))
                .font(.system(size: 17))
                .padding(.leading, 2)
                .padding(.top, -4)
            Spacer()
        }
    }
}

extension PtoPMessageView{
    
    private var customNavBar: some View{
            HStack{
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding(4)
                }

                Spacer()
        
                    Text("\(vm.receiver?.Username ?? "")")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                Spacer()
                
                
            }
            .padding()
            .background(Color.black.opacity(0.8))
    }
    
    private var allMessages: some View{
        

                ScrollView{
                    ScrollViewReader{ proxy in
                        VStack{
                            ForEach(vm.chatMessages) { chatMessage in
                                HStack{
                                    if chatMessage.fromId == Auth.auth().currentUser?.uid{
                                        Spacer()
                                        Text(chatMessage.msg)
                                            .padding()
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .background(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(Color(red: 159/255, green: 159/255, blue: 159/255))
                                            )
                                    }else{
                                        Text(chatMessage.msg)
                                            .padding()
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .background(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(Color(red: 0/255, green: 150/255, blue: 255/255))
                                                )
                                        Spacer()
                                    }
                                }
                                .padding([.trailing, .top, .leading, .bottom])
                            }
                            HStack {
                                
                            }.id("check")
                        
                        }.onReceive(vm.$count) { _ in
                            
                            withAnimation(.easeOut){
                                proxy.scrollTo("check")
                            }
                        }
                    }
                }
              
                .background(Color.white)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var bottombar: some View{
        HStack(spacing: 16){
            Image(systemName: "photo.on.rectangle")
                .padding([.leading,.trailing])
                .font(.system(size: 30))
                .foregroundColor(Color.black.opacity(0.8))
            
            ZStack{
                    DescriptionPlaceholder()
                TextEditor(text: $vm.msg)
                    .keyboardType(.default)
                    .focused($showKeyboard)
                    .opacity(vm.msg.isEmpty ? 0.5 : 1)
                }
                .frame(height: 40)
            
               

            .frame(height: 40)

            Button {
                vm.handleSendingMessage()
                showKeyboard = false
            } label: {
                Text("send")
                    .padding([.horizontal, .vertical])
                    .background(.black.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.trailing)
            

        }
        .padding(1)
    }

    
}

struct PtoPMessageView_Previews: PreviewProvider {
    static var previews: some View {
        PtoPMessageView(vm: PtoPMessageViewModel(receiver: User(Username: "", userBio: "", userBioLink: "", userUID: "", email: "", profilePicURL: URL(string: "https://firebasestorage.googleapis.com:443/v0/b/techshare-69430.appspot.com/o/Profile_Images%2F5bQx0b3X9rPiAuNgkXAP72OhwCn2?alt=media&token=e271bbac-fe41-4d31-b4a1-269d4e201a92")!)))
    }
}
