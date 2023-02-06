//
//  PostCardView.swift
//  SwiftuiSocialMediaProject
//
//  Created by Bhavik Bhatt on 06/02/23.
//

import SwiftUI
import SDWebImageSwiftUI
import FirebaseFirestore
import FirebaseStorage

struct PostCardView: View {
    
    var post: Post
    @AppStorage("user_uid") var userID: String = ""
    @State private var docListener: ListenerRegistration?
    
    var onUpdate: (Post) -> ()
    var onDelete: () -> ()
    
    var body: some View {
        HStack(alignment: .top, spacing: 12){
            WebImage(url: post.userProfileURL)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 35, height: 35)
                .clipShape(Circle())
            
            VStack(alignment: .leading) {
                Text(post.userName)
                    .font(.callout)
                    .fontWeight(.semibold)
                Text(post.publishedDate.formatted(date: .numeric, time: .shortened))
                    .font(.caption2)
                    .foregroundColor(.gray)
                Text(post.text)
                    .textSelection(.enabled)
                    .padding(.vertical, 8)
                
                if let postImageURL = post.imageURL{
                    GeometryReader{ geo in
                        WebImage(url: postImageURL)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geo.size.width, height: geo.size.height)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    .frame(height: 200)
                }
                
                postInteraction()
            }
        }
        .hAligned(alignment: .leading)
        .overlay(alignment: .topTrailing){
            if post.userUID == userID{
                Menu{
                    Button("Delete", role: .destructive, action: deletedPost)
                }label: {
                    Image(systemName: "ellipsis")
                        .font(.caption)
                        .rotationEffect(Angle(degrees: -90))
                        .foregroundColor(.black)
                        .padding(8)
                        .contentShape(Rectangle())
                }
                .offset(x: 8)
            }
        }
        .onAppear{
            if docListener == nil{
                guard let postID = post.id else { return }
                docListener = Firestore.firestore().collection("Posts")
                    .document(postID)
                    .addSnapshotListener({ snapshot, error in
                        if let snapshot{
                            if snapshot.exists{
                                /* this runs when post is updated*/
                                if let updatedPost = try? snapshot.data(as: Post.self){
                                    onUpdate(updatedPost)
                                }
                            }else{
                                /* this runs when post is deleted*/
                                onDelete()
                            }
                        }
                    })
            }
        }
        .onDisappear{
            if let docListener{
                docListener.remove()
                self.docListener = nil
            }
        }
    }
    
    // like or dislike interaction
    @ViewBuilder
    func postInteraction() -> some View{
        HStack(spacing: 6){
            Button(action: likedPost){
                Image(systemName: (post.likeIDs.contains(userID)) ? "hand.thumbsup.fill" : "hand.thumbsup")
            }
            
            Text("\(post.likeIDs.count)")
                .font(.caption)
                .foregroundColor(.gray)
            
            Button(action: dislikedPost){
                Image(systemName: (post.dislikedIDs.contains(userID)) ? "hand.thumbsdown.fill" : "hand.thumbsdown")
            }
            .padding(.leading, 25)
            
            Text("\(post.dislikedIDs.count)")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .foregroundColor(.black)
        .padding(.vertical, 8)
    }
    
    func likedPost(){
        Task{
            guard let postID = post.id else { return }
            if post.likeIDs.contains(userID){
                Firestore.firestore().collection("Posts")
                    .document(postID)
                    .updateData([
                        "likeIDs": FieldValue.arrayRemove([userID])
                    ])
            }else{
                Firestore.firestore().collection("Posts")
                    .document(postID)
                    .updateData([
                        "likeIDs": FieldValue.arrayUnion([userID]),
                        "dislikedIDs" : FieldValue.arrayRemove([userID])
                    ])
            }
        }
    }
    func dislikedPost(){
        Task{
            guard let postID = post.id else { return }
            if post.dislikedIDs.contains(userID){
                Firestore.firestore().collection("Posts")
                    .document(postID)
                    .updateData([
                        "dislikedIDs": FieldValue.arrayRemove([userID])
                    ])
            }else{
                Firestore.firestore().collection("Posts")
                    .document(postID)
                    .updateData([
                        "dislikedIDs": FieldValue.arrayUnion([userID]),
                        "likeIDs" : FieldValue.arrayRemove([userID])
                    ])
            }
        }
    }
    
    func deletedPost(){
        Task{
            do{
                // deleting image of post if it contained
                if post.imageReferenceID != ""{
                    try await Storage.storage().reference().child("Post_images")
                        .child(post.imageReferenceID)
                        .delete()
                }
                // deleting document for post in firestore
                guard let postId = post.id else { return}
                try await Firestore.firestore().collection("Posts")
                    .document(postId).delete()
                
            }catch{
                print("couldn't delete post \(error)")
            }
        }
    }
    
    
}

