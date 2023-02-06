//
//  PostFeedView.swift
//  SwiftuiSocialMediaProject
//
//  Created by Bhavik Bhatt on 06/02/23.
//

import SwiftUI
import Firebase

struct PostFeedView: View {
    var basedOnUID: Bool = false
    var uid: String = ""
    @Binding var recentPosts: [Post]
    @State private var isFetching: Bool = true
    
    //pagination
    @State private var paginationDocument: QueryDocumentSnapshot?
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack{
                if isFetching{
                    ProgressView()
                        .padding(.top, 30)
                }else{
                    if recentPosts.isEmpty{
                        // no posts found on firestore
                        Text("No posts found")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.top, 30)
                    }else{
                        posts()
                    }
                }
            }
            .padding(15)
        }
        .refreshable {
            guard !basedOnUID else { return }
            isFetching = true
            recentPosts = []
            /* paginationDoc must set to nil as if it is not set to nil, whatever next 20 post of there are after paginationDoc will be fetched. There are no issues as such but here when user refreshes we set recentPosts to blank array, so if pagination doc is not nil then before pagination doc whatever docs are, their data won't be in recentPosts array*/
            paginationDocument = nil
            await fetchPosts()
            
        }
        .task {
            guard recentPosts.isEmpty else { return }
            await fetchPosts()
        }
    }
    @ViewBuilder
    func posts() -> some View{
        ForEach(recentPosts){post in
            PostCardView(post: post) { updatedPost in
                if let index = recentPosts.firstIndex(where: { post in
                    post.id == updatedPost.id
                }){
                    recentPosts[index].likeIDs = updatedPost.likeIDs
                    recentPosts[index].dislikedIDs = updatedPost.dislikedIDs
                }
            } onDelete: {
                withAnimation(.easeInOut(duration: 0.25)){
                    recentPosts.removeAll{post.id == $0.id}
                }
            }
            /* below mentioned on appear is code responsible for pagination*/
            .onAppear{
                if post.id == recentPosts.last?.id && paginationDocument != nil{
                    Task{
                        await fetchPosts()
                    }
                }
            }
            
            /* padding given on horizontal is -15 coz on LazyVstack, we have given padding of 15*/
            Divider()
                .padding(.horizontal, -15)

        }
    }
    
    func fetchPosts()async{
        do {
            var query: Query!
            if let paginationDocument{
                query = Firestore.firestore().collection("Posts")
                    .order(by: "publishedDate", descending: true)
                    .start(afterDocument: paginationDocument)
                    .limit(to: 20)
            }else{
                query = Firestore.firestore().collection("Posts")
                    .order(by: "publishedDate", descending: true)
                    .limit(to: 20)
            }
            
            if basedOnUID{
                query = query
                    .whereField("userUID", isEqualTo: uid)
            }
            
            let docs = try await query.getDocuments()
            let fetchedPosts = docs.documents.compactMap { doc -> Post? in
                try? doc.data(as: Post.self)
            }
            await MainActor.run(body: {
                recentPosts.append(contentsOf: fetchedPosts)
                paginationDocument = docs.documents.last
                isFetching = false
            })
        } catch  {
            print(error.localizedDescription)
        }
    }
}

//struct PostFeedView_Previews: PreviewProvider {
//    static var previews: some View {
//        PostFeedView()
//    }
//}
