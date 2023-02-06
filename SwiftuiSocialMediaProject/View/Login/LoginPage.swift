//
//  LoginPage.swift
//  SwiftuiSocialMediaProject
//
//  Created by Bhavik Bhatt on 05/02/23.
//

import SwiftUI
import Firebase


struct LoginPage: View {
    
    @State var email: String = ""
    @State var password: String = ""
    @State var showRegisterView: Bool = false
    @State var showError: Bool = false
    @State var errorMessage: String = ""
    
    @State var isLoading: Bool = false
    
    // User defaults
    @AppStorage("log_status") var logStatus: Bool = false
    @AppStorage("user_profile_url") var profileURL: URL?
    @AppStorage("user_name") var userNamedStored: String = ""
    @AppStorage("user_uid") var userID: String = ""
    
    var body: some View {
        VStack(spacing: 10){
            Text("Sign In")
                .font(.largeTitle)
                .fontWeight(.heavy)
                .hAligned(alignment: .leading)
            
            Text("Welcome back, hope you are doing well !!")
                .multilineTextAlignment(.leading)
                .hAligned(alignment: .leading)
            
            VStack(spacing: 12){
                
                TextField("Email", text: $email)
                    .textInputAutocapitalization(.never)
                    .textContentType(.emailAddress)
                    .BorderOfInputFields()
                    .padding(.top, 25)
                
                SecureField("Password", text: $password)
                    .textContentType(.emailAddress)
                    .BorderOfInputFields()
                
                Button("Reset Password?", action: {
                    resetPassword()
                })
                    .tint(.black)
                    .hAligned(alignment: .trailing)
                
                Button{
                    loginUser()
                }label: {
                    Text("Log In")
                }
                .foregroundColor(.white)
                .padding()
                .hAligned(alignment: .center)
                .background(.black)
                .cornerRadius(10)
                .padding(.top)
            }
            
            HStack{
                Text("Don't have an account yet")
                    .foregroundColor(.gray)
                
                Button{
                    withAnimation(.easeIn){
                        showRegisterView.toggle()
                    }
                }label: {
                    Text("Register now")
                }
                .foregroundColor(.black)
                .font(.subheadline)
                .fontWeight(.heavy)
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .padding()
        .vAligned(alignment: .top)
        .overlay(content: {
            LoadingView(show: $isLoading)
        })
        .fullScreenCover(isPresented: $showRegisterView) {
            SignUpPage {
                showRegisterView = false
            }
        }
        .alert(errorMessage, isPresented: $showError) {
            
        }
    }
    
    func loginUser(){
        isLoading = true
        closeKeyboard()
        Task{
            do{
                try await Firebase.Auth.auth().signIn(withEmail: email, password: password)
                print("user found in data base")
                try await fetchUser()
            }catch{
                await setError(error)
            }
        }
    }
    
    func fetchUser()async throws{
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let user = try await Firestore.firestore().collection("Users").document(userId)
            .getDocument(as: User.self)
        
        await MainActor.run(body: {
            userID = userId
            userNamedStored = user.Username
            profileURL = user.profilePicURL
            logStatus = true
        })
    }
    
    func resetPassword(){
            Task{
                do{
                    try await Firebase.Auth.auth().sendPasswordReset(withEmail: email)
                    print("link sent to your user's email id")
                }catch{
                    await setError(error)
                }
            }
    }
    
    func setError(_ error: Error)async{
        await MainActor.run {
            errorMessage = error.localizedDescription
            showError.toggle()
            isLoading = false
        }
    }
}



struct LoginPage_Previews: PreviewProvider {
    static var previews: some View {
        LoginPage()
    }
}


extension View{
    
    func BorderOfInputFields() -> some View{
       return self
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(style: StrokeStyle(lineWidth: 2))
            )
    }
    
}
