//
//  NewMessageScreen.swift
//  ShareTech
//
//  Created by Bhavik Bhatt on 11/02/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct NewMessageScreen: View {
    
    let isUserSelectedForChat: (User) -> ()
    @Environment(\.dismiss) var dismiss
    @StateObject var vmOfNewMessageScreen = NewMessageScreenViewModel()
    
    
    var body: some View {
        NavigationStack{
                SearchBarView(searchText: $vmOfNewMessageScreen.searchText)
                VStack{
                ScrollView{
                    ForEach(vmOfNewMessageScreen.allUsers, id: \.userUID){ user in
                        
                        Button {
                            print("user selected")
                            
                            dismiss()
                            isUserSelectedForChat(user)
                        } label: {
                            HStack(spacing: 16){
                                WebImage(url: URL(string: user.profilePicURL.absoluteString))
                                    .resizable()
                                    .scaledToFill()
                                    .clipped()
                                    .frame(width: 50, height: 50)
                                    .cornerRadius(50)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 50)
                                            .stroke(style: StrokeStyle(lineWidth: 1))
                                    )
                                Text("\(user.email.replacingOccurrences(of: "@gmail.com", with: ""))")
                                Spacer()
                            }
                            Divider()
                        }
                        .padding(.leading)
                        
                        Divider()
                    }
                }
                .toolbar{
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("cancel", role: .cancel) {
                            dismiss()
                        }
                        .tint(.blue)
                    }
                }
            }
        }
    }
}

struct NewMessageScreen_Previews: PreviewProvider {
    static var previews: some View {
        NewMessageScreen(isUserSelectedForChat: {user in})
    }
}
