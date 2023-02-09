//
//  PostFeedView.swift
//  SwiftuiSocialMediaProject
//
//  Created by Bhavik Bhatt on 06/02/23.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct PostFeedView: View {
//    var basedOnUID: Bool = false
//    var uid: String = ""
//    @Binding var recentPosts: [Post]
//    @State private var isFetching: Bool = true
//    @EnvironmentObject var vm: TechnologyPickerViewModel
//
//    //pagination
//    @State private var paginationDocument: QueryDocumentSnapshot?
    @EnvironmentObject var vmOfPostFeed: PostFeedViewModel
    @EnvironmentObject var vm: TechnologyPickerViewModel
    

    @AppStorage("user_uid") var userID: String = ""

    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack{
                if vmOfPostFeed.isFetching{
                    ProgressView()
                        .padding(.top, 30)
                }else{
                    if vmOfPostFeed.recentPosts.isEmpty{
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
            guard !vmOfPostFeed.basedOnUID else { return }
            vmOfPostFeed.isFetching = true
            vmOfPostFeed.recentPosts = []
            /* paginationDoc must set to nil as if it is not set to nil, whatever next 20 post of there are after paginationDoc will be fetched. There are no issues as such but here when user refreshes we set recentPosts to blank array, so if pagination doc is not nil then before pagination doc whatever docs are, their data won't be in recentPosts array*/
            vmOfPostFeed.paginationDocument = nil
            await vmOfPostFeed.fetchPosts(selectedTechnologies: vm.selectedTechnologies, basedOnUID: vmOfPostFeed.basedOnUID, uid: userID)
     
            
        }
        .task {
            guard vmOfPostFeed.recentPosts.isEmpty else { return }
            await vmOfPostFeed.fetchPosts(selectedTechnologies: vm.selectedTechnologies, basedOnUID: vmOfPostFeed.basedOnUID, uid: userID)
      
        }
    }
    @ViewBuilder
    func posts() -> some View{
        ForEach(vmOfPostFeed.recentPosts){post in
            PostCardView(post: post) { updatedPost in
                if let index = vmOfPostFeed.recentPosts.firstIndex(where: { post in
                    post.id == updatedPost.id
                }){
                    vmOfPostFeed.recentPosts[index].likeIDs = updatedPost.likeIDs
                    vmOfPostFeed.recentPosts[index].dislikedIDs = updatedPost.dislikedIDs
                }
            } onDelete: {
                withAnimation(.easeInOut(duration: 0.25)){
                    vmOfPostFeed.recentPosts.removeAll{post.id == $0.id}
                }
            }
            /* below mentioned on appear is code responsible for pagination*/
            .onAppear{
                if post.id == vmOfPostFeed.recentPosts.last?.id && vmOfPostFeed.paginationDocument != nil{
                    Task{
                        await vmOfPostFeed.fetchPosts(selectedTechnologies: vm.selectedTechnologies, basedOnUID: vmOfPostFeed.basedOnUID, uid: userID)
                    }
                }
            }
            
            /* padding given on horizontal is -15 coz on LazyVstack, we have given padding of 15*/
            Divider()
                .padding(.horizontal, -15)

        }
    }
    
    /*
     vm.selecttedTechnologies (will get this data from environment),
     BaSEDonUID (fixed),
     uid (fixed),
     recentPosts (inout)
     paginationDocument (inout),
     isFetching (inout)
     */
    
//    func fetchPosts()async{
//        print("fetching data from fetchPosts.. for technologies \(vm.selectedTechnologies)")
//        do {
//            var query: Query!
//
//
//
//            if let paginatedDocument = vmOfPostFeed.paginationDocument{
//                if vm.selectedTechnologies.count > 0{
//                    query = Firestore.firestore().collection("Posts")
//                        .whereField("relatedTechnologies", arrayContainsAny: vm.selectedTechnologies)
//                        .order(by: "publishedDate", descending: true)
//                        .start(afterDocument: paginatedDocument)
//                        .limit(to: 20)
//                }else{
//                    query = Firestore.firestore().collection("Posts")
//                        .order(by: "publishedDate", descending: true)
//                        .start(afterDocument: paginatedDocument)
//                        .limit(to: 20)
//                }
//            }else{
//                if vm.selectedTechnologies.count > 0{
//                    query = Firestore.firestore().collection("Posts")
//                        .whereField("relatedTechnologies", arrayContainsAny: vm.selectedTechnologies)
//                        .order(by: "publishedDate", descending: true)
//                        .limit(to: 20)
//                }else{
//                    query = Firestore.firestore().collection("Posts")
//                        .order(by: "publishedDate", descending: true)
//                        .limit(to: 20)
//                }
//            }
//
//            if vmOfPostFeed.basedOnUID{
//                query = query
//                    .whereField("userUID", isEqualTo: vmOfPostFeed.uid)
//            }
//
//            let docs = try await query.getDocuments()
//            let fetchedPosts = docs.documents.compactMap { doc -> Post? in
//                try? doc.data(as: Post.self)
//            }
//            print("fetchedposts : \(fetchedPosts)")
//            await MainActor.run(body: {
//                vmOfPostFeed.recentPosts.append(contentsOf: fetchedPosts)
//                vmOfPostFeed.paginationDocument = docs.documents.last
//                vmOfPostFeed.isFetching = false
//            })
//        } catch  {
//            print(error.localizedDescription)
//        }
//    }
}

