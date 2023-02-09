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
    @EnvironmentObject var vm: TechnologyPickerViewModel
    @EnvironmentObject var vmOfPostFeed: PostFeedViewModel
    @State var postTopic: String = ""
    @State var showTagTechnology: Bool = false
    
    @StateObject var photosUIPicker: PhotosUIPicker = PhotosUIPicker()
    
    var body: some View {
        
        VStack(spacing: 20){
            
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
            ScrollView{
                
                TextField("Topic", text: $postTopic)
                    .BorderOfInputFields()
                    .padding(.horizontal)
                
                TextEditor(text: $postText)
                    .focused($showKeyBoard)
                    .textInputAutocapitalization(.never)
                    .BorderOfInputFields()
                    .padding(.horizontal)
                    .frame(height: 200)
                
                
                
            }
            
            
    
                    if !photosUIPicker.images.isEmpty{
                        Text("Selected Images")
                        GeometryReader{ geo in
                        ScrollView(.horizontal, showsIndicators: false){
                            HStack(spacing: 15){
                                ForEach(0..<photosUIPicker.images.count, id: \.self) { index in
                                        Image(uiImage: photosUIPicker.images[index])
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: geo.size.width, height: 220)
                                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                            .overlay(alignment: .topLeading){
                                                Button {
                                                    withAnimation(.easeOut(duration: 0.25)) {
                                                        let _ = self.photosUIPicker.images.remove(at: index)
                                                        
                                                    }
                                                } label: {
                                                    Image(systemName: "xmark")
                                                        .fontWeight(.bold)
                                                        .tint(.black)
                                                }
                                                .padding(10)
                                                
                                            }
                                            .padding(.leading, 15)
                                    }
                                Spacer()
                                }
                            }
                        .clipped()
                        .frame(height: 220)
                        }.hAligned(alignment: .center)
                    }
                   
                    
            HStack{
                Button{
                    showImagePicker.toggle()
                }label: {
                    Image(systemName: "photo.on.rectangle")
                }
                
                Spacer()
                
                Button{
                    showTagTechnology.toggle()
                }label: {
                    Image(systemName: "tag")
                }
                .sheet(isPresented: $showTagTechnology) {
                    TechnologyPicker(areTechnologySelectedForPosts: true)
                }
                
                Spacer()
                
                Button("Done"){
                    showKeyBoard = false
                }
            }
            .foregroundColor(.black)
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            
            
        }.vAligned(alignment: .top)
            .photosPicker(isPresented: $showImagePicker, selection: $photosUIPicker.imageSelections)
            .alert(errorMessage, isPresented: $showError, actions: {})
            .overlay {
                LoadingView(show: $isLoading)
            }
            
    }
    
    // post content to firebase
    func createPost(){
        isLoading = true
        showKeyBoard = false
        var imageURLs: [URL] = []
        var imageReferenceIds: [String] = []
        let selectedTechnologiesForPosts: [String] = vm.selectedTechnologiesForPosts
        Task{
            do{
                guard let profileURL = profileURL else { return }
                // upload an image if there is in the post
                
                if self.photosUIPicker.images.count > 0 {
                    for index in 0..<self.photosUIPicker.images.count{
                        let imageReferenceID = "\(userID)\(Date())\(index)"
                        let storageRef = Storage.storage().reference().child("Post_images").child(imageReferenceID)
                        if let imageData = self.photosUIPicker.images[index].jpegData(compressionQuality: 0.5){
                            let _ = try await storageRef.putDataAsync(imageData)
                            let uploadedImageURL = try await storageRef.downloadURL()
                            imageURLs.append(uploadedImageURL)
                            imageReferenceIds.append(imageReferenceID)
                        }
                    }
                    let post = Post(text: postText, imageURL: imageURLs, imageReferenceID: imageReferenceIds ,userName: userNamedStored, userUID: userID, userProfileURL: profileURL, relatedTechnologies: selectedTechnologiesForPosts, postTopic: postTopic)
                    
                    
                    
                    try await storePostInfoInFirebase(post)
                }else{
                    // post text only
                    let post = Post(text: postText, userName: userNamedStored, userUID: userID, userProfileURL: profileURL, relatedTechnologies: selectedTechnologiesForPosts, postTopic: postTopic)
               
                    try await storePostInfoInFirebase(post)
                    
                    vm.selectedTechnologies = []
                    Task{
                        await vmOfPostFeed.fetchPosts(selectedTechnologies: vm.selectedTechnologies, basedOnUID: false, uid: userID)
                    }
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
