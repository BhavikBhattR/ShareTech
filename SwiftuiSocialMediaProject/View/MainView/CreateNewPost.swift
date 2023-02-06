//
//  CreateNewPost.swift
//  SwiftuiSocialMediaProject
//
//  Created by Bhavik Bhatt on 06/02/23.
//

import SwiftUI
import PhotosUI
import Firebase
import FirebaseStorage
import FirebaseFirestore
import FirebaseFirestoreSwift

struct CreateNewPost: View {
    
    var onPost: (Post) -> ()
    
    // post content
    @State var postText: String = ""
    @State var postImageData: Data?
    // user info coming from userdefaults
    @AppStorage("user_profile_url") var profileURL: URL?
    @AppStorage("user_name") var userNamedStored: String = ""
    @AppStorage("user_uid") var userID: String = ""
    // vars used to update view
    @Environment(\.dismiss) var dismiss
    @State private var isLoading: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var showImagePicker: Bool = false
    @State private var photosItem: PhotosPickerItem?
    @FocusState private var showKeyBoard: Bool
    
    var body: some View {
        VStack{
            
            HStack{
                Menu{
                    Button("cancel", role: .destructive){
                        dismiss()
                    }
                }label: {
                    Text("cancel")
                        .font(.callout)
                        .foregroundColor(.black)
                }
                .hAligned(alignment: .leading)
                
                Button {
                    createPost()
                } label: {
                    Text("Post")
                        .font(.callout)
                        .foregroundColor(.white)
                        .padding(.horizontal, 29)
                        .padding(.vertical, 6)
                        .background(.black, in: Capsule())
                }.disabledIf(postText.trimmingCharacters(in: .whitespacesAndNewlines) == "")
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background{
                Rectangle().fill(.gray.opacity(0.5))
                    .ignoresSafeArea()
            }
 
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 15){
                    TextField("What's going on?", text: $postText, axis: .vertical)
                        .focused($showKeyBoard)
                        .textInputAutocapitalization(.never)
                    
                    
                    if
                        let postImageData, let image = UIImage(data: postImageData){
                        GeometryReader{ geo in
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geo.size.width, height: geo.size.height)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                .overlay(alignment: .topLeading){
                                    Button {
                                        withAnimation(.easeOut(duration: 0.25)) {
                                            self.postImageData = nil
                                        }
                                    } label: {
                                        Image(systemName: "xmark")
                                            .fontWeight(.bold)
                                            .tint(.black)
                                    }
                                    .padding(10)

                                }
                        }
                        .clipped()
                        .frame(height: 220)
                    }
                }
                .padding(15)
            }
            
            Divider()
            
            
            HStack{
                Button{
                    showImagePicker.toggle()
                }label: {
                    Image(systemName: "photo.on.rectangle")
                }
                .hAligned(alignment: .leading)
                
                Button("Done"){
                    showKeyBoard = false
                }
            }
            .foregroundColor(.black)
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            
            
        }.vAligned(alignment: .top)
            .photosPicker(isPresented: $showImagePicker, selection: $photosItem)
            .onChange(of: photosItem) { newValue in
                if let newValue{
                    Task{
                        if let rawImageData = try?  await newValue.loadTransferable(type: Data.self),
                           let image = UIImage(data: rawImageData),
                           let compressedImageData = image.jpegData(compressionQuality: 0.5){
                            await MainActor.run(body: {
                                postImageData = compressedImageData
                                photosItem = nil
                            })
                        }
                    }
                }
            }
            .alert(errorMessage, isPresented: $showError, actions: {})
            .overlay {
                LoadingView(show: $isLoading)
            }
            
    }
    
    // post content to firebase
    func createPost(){
        isLoading = true
        showKeyBoard = false
        Task{
            do{
                guard let profileURL = profileURL else { return }
                // upload an image if there is in the post
                let imageReferenceID = "\(userID)\(Date())"
                let storageRef = Storage.storage().reference().child("Post_images").child(imageReferenceID)
                if let postImageData{
                let _ = try await storageRef.putDataAsync(postImageData)
                    let uploadedImageURL = try await storageRef.downloadURL()
                    
                    let post = Post(text: postText, imageURL: uploadedImageURL, imageReferenceID: imageReferenceID ,userName: userNamedStored, userUID: userID, userProfileURL: profileURL)
                    
                    try await storePostInfoInFirebase(post)
                }else{
                    // post text only
                    let post = Post(text: postText, userName: userNamedStored, userUID: userID, userProfileURL: profileURL)
                    try await storePostInfoInFirebase(post)
                }
            }catch{
                await setError(error: error)
            }
        }
    }
    
    func setError(error: Error)async{
        isLoading = false
        await MainActor.run(body: {
            errorMessage = error.localizedDescription
            showError.toggle()
        })
    }
    
    func storePostInfoInFirebase(_ post: Post)async throws{
        let doc = Firestore.firestore().collection("Posts").document()
        let _ = try doc.setData(from: post, completion: { error in
            if error == nil{
                isLoading = false
                var updatedPost = post
                updatedPost.id = doc.documentID
                onPost(updatedPost)
                dismiss()
            }
        })
    }
}

struct CreateNewPost_Previews: PreviewProvider {
    static var previews: some View {
        CreateNewPost(onPost: {post in })
    }
}
