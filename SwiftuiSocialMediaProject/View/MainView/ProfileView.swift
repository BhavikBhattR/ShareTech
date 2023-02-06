//
//  ProfileView.swift
//  SwiftuiSocialMediaProject
//
//  Created by Bhavik Bhatt on 06/02/23.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct ProfileView: View {
    
    @State private var myProfile: User?
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var isLoading: Bool = false
    @AppStorage("log_status") var logStatus: Bool = true
    
    var body: some View {
        NavigationStack{
            VStack{
                if let myProfile{
                    UsefulProfileViewContent(user: myProfile)
                        .refreshable {
                            // refresh the user data
                            self.myProfile = nil
                            /*
                             set myProfile to nil, coz in fetchUserData() we added logic that if myProfile is not nil, user data will not be fetched
                             */
                            await fetchUserData()
                        }
                }else{
                    ProgressView()
                }
            }
           
            .navigationTitle("My profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu{
                        Button("Log out", action: logoutUser)
                        
                        Button("Delete account", role: .destructive, action: deleteUserAccount)
                    }label: {
                       Image(systemName: "ellipsis")
                            .rotationEffect(Angle(degrees: 90))
                            .tint(.black)
                            .scaleEffect(0.8)
                    }
                }
            }
        }
        .overlay {
            LoadingView(show: $isLoading)
        }
        .alert(errorMessage, isPresented: $showError, actions: {})
        .task {
            if myProfile != nil{
                return
            }
            await fetchUserData()
        }
    }
    
    func fetchUserData() async{
        guard let userID = Auth.auth().currentUser?.uid else { return }
        guard let user  = try? await Firestore.firestore().collection("Users").document(userID).getDocument(as: User.self) else { return }
        await MainActor.run(body: {
            myProfile = user
        })
    }
    
    func logoutUser(){
        try? Firebase.Auth.auth().signOut()
        logStatus = false
    }
    
    func deleteUserAccount(){
        isLoading = true
        Task{
            do{
                guard let currentUserUID = Firebase.Auth.auth().currentUser?.uid else { return }
                // deleting user profile pic from firebase storage
                let reference = Storage.storage().reference().child("Profile_Images")
                    .child(currentUserUID)
                try await reference.delete()
                // removing user's data from firestore database
                try await Firebase.Auth.auth().currentUser?.delete()
                // deleting user from Auth account
                try await Firebase.Auth.auth().currentUser?.delete()
                logStatus = false
            }catch{
                await setError(error: error)
            }
        }
    }
    
    func setError(error: Error) async{
        await MainActor.run(body: {
            isLoading = false
            errorMessage = error.localizedDescription
            showError.toggle()
        })
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
