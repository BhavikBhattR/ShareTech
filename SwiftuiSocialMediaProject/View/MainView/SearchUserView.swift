//
//  SearchUserView.swift
//  SwiftuiSocialMediaProject
//
//  Created by Bhavik Bhatt on 07/02/23.
//

import SwiftUI
import FirebaseFirestore

struct SearchUserView: View {
    @State private var fetchedUsers: [User] = []
    @State private var searchText: String = ""
    @Environment(\.dismiss) var dismiss
    var body: some View {
        List{
            ForEach(fetchedUsers){user in
                NavigationLink {
                    UsefulProfileViewContent(user: user)
                } label: {
                    Text(user.Username)
                        .hAligned(alignment: .leading)
                }

            }
        }
        .navigationTitle("Search User")
        .navigationBarTitleDisplayMode(.inline)
        .listStyle(.plain)
        .searchable(text: $searchText)
//        .onSubmit(of: .search,{
//            Task { await fetchUsers()}
//        })
        .onChange(of: searchText, perform: { newValue in
            if newValue.isEmpty{
                fetchedUsers = []
            }else{
                Task{ await fetchUsers() }
            }
        })
    }
    
    func fetchUsers()async{
        print("fetch users func called")
        do{
            
            
            let documents = try await Firestore.firestore().collection("Users")
                .whereField("Username", isGreaterThanOrEqualTo: searchText)
                .whereField("Username", isLessThanOrEqualTo: "\(searchText)\u{f8ff}")
                .getDocuments()
            let users = try documents.documents.compactMap { doc -> User? in
                try doc.data(as: User.self)
            }
           
            await MainActor.run(body: {
                self.fetchedUsers = users
            })
        }catch{
            print(error.localizedDescription)
        }
        
    }
}

struct SearchUserView_Previews: PreviewProvider {
    static var previews: some View {
        SearchUserView()
    }
}
