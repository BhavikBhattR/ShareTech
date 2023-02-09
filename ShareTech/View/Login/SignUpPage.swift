//
//  SignUpPage.swift
//  SwiftuiSocialMediaProject
//
//  Created by Bhavik Bhatt on 05/02/23.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage
import FirebaseFirestoreSwift

struct SignUpPage: View {
    
    // vars to hold user details
    @State var email: String = ""
    @State var password: String = ""
    @State var Username: String = ""
    @State var userBio: String = ""
    @State var profilePic: UIImage?
    @State var userBioLink: String = ""
    @State var userProfileData: Data?
    
    // Vars to update UI after some action
    @State var showImagePicker: Bool = false
    @State var showError: Bool = false
    @State var errorMessage: String = ""
    @State var updateOnSuccess: Bool = false
    @State var successMessage: String = ""
    
    @State var isLoading: Bool = false
    
    // User defaults
    @AppStorage("log_status") var logStatus: Bool = false
    @AppStorage("user_profile_url") var profileURL: URL?
    @AppStorage("user_name") var userNamedStored: String = ""
    @AppStorage("user_uid") var userID: String = ""
    
    @Environment(\.dismiss) var dismiss
    
    
    var getDismissed: () -> ()
    
    var body: some View {
        VStack(spacing: 10){
            Text("Register")
                .font(.largeTitle)
                .fontWeight(.heavy)
                .hAligned(alignment: .leading)
            
            Text("Welcome, We are glad to have you here !!")
                .multilineTextAlignment(.leading)
                .hAligned(alignment: .leading)
            
            
            // to adapt the size of small phones
            ViewThatFits {
                ScrollView(.vertical, showsIndicators: false){
                    HelperView()
                }
                HelperView()
            }
            .alert(errorMessage, isPresented: $showError) {
                
            }
            
            HStack{
                Text("Already have an account?")
                    .foregroundColor(.gray)
                
                Button{
                    getDismissed()
                }label: {
                    Text("Login now")
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
        .fullScreenCover(isPresented: $showImagePicker) {
            ImagePicker(image: $profilePic)
        }
    }
    
    @ViewBuilder
    func HelperView() -> some View{
        VStack(spacing: 12){
            
            ZStack{
                if let
                    image = profilePic{
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipShape(Circle())
                        .contentShape(Circle())
                }else{
                    Image(systemName: "person")
                        .resizable()
                        .padding()
                        .aspectRatio(contentMode: .fill)
                        .clipShape(Circle())
                        .contentShape(Circle())
                }
            }
            .frame(width: 90, height: 90)
            .background(
                Circle()
                    .stroke(style: StrokeStyle(lineWidth: 2))
            )
            .padding(.top)
            .onTapGesture {
                showImagePicker.toggle()
            }
            
            TextField("Email", text: $email)
                .textInputAutocapitalization(.never)
                .textContentType(.emailAddress)
                .BorderOfInputFields()
                .padding(.top, 25)
            
            TextField("User name", text: $Username)
                .textContentType(.emailAddress)
                .BorderOfInputFields()
            
            SecureField("Password", text: $password)
                .textContentType(.emailAddress)
                .BorderOfInputFields()
            
            TextField("Bio Link (optional)", text: $userBioLink)
                .textContentType(.emailAddress)
                .BorderOfInputFields()
            
            TextField("Tell something about you", text: $userBio, axis: .vertical)
                .frame(minHeight: 100, alignment: .top)
                .textContentType(.emailAddress)
                .BorderOfInputFields()
            
            
            Button{
                registerUser()
            }label: {
                Text("Sign Up")
            }
            .foregroundColor(.white)
            .padding()
            .hAligned(alignment: .center)
            .background(.black)
            .cornerRadius(10)
            .padding(.top)
            .disabledIf(Username == "" || email == "" || userBio == "" || profilePic == nil || password == "")
            .alert(errorMessage, isPresented: $showError, actions: {})
            .alert(successMessage, isPresented: $updateOnSuccess, actions: {})
        }
    }
    
    
    func registerUser(){
        isLoading = true
        closeKeyboard()
        Task{
            
            do{
                // creating an account for user
                try await Auth.auth().createUser(withEmail: email, password: password)
                
                //uploading the profile pic into firebase storage
                guard let userID = Firebase.Auth.auth().currentUser?.uid else { return }
                guard let imgData = profilePic?.jpegData(compressionQuality: 0.5) else { return }
                let storageRef = Storage.storage().reference().child("Profile_Images").child(userID)
                let _ = try await storageRef.putDataAsync(imgData)
                
                //downloading image URL
                let profileImageURL = try await storageRef.downloadURL()
                
                //creating a user in firestore database
                let user = User(Username: Username, userBio: userBio, userBioLink: userBioLink, userUID: userID, email: email, profilePicURL: profileImageURL)
                let _ = try Firestore.firestore().collection("Users").document(userID).setData(from: user, completion: { error in
                    if error == nil{
                        print("User successfully created")
                        successMessage = "User successfully created"
                        isLoading = false
                        updateOnSuccess.toggle()
                        userNamedStored = Username
                        self.userID = userID
                        profileURL = profileImageURL
                    }
                   
                })
                logStatus = true
                getDismissed()

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

struct SignUpPage_Previews: PreviewProvider {
    static var previews: some View {
        SignUpPage(getDismissed: {})
    }
}

    
