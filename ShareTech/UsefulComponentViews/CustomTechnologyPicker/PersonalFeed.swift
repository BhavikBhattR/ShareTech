//
//  PersonalFeed.swift
//  ShareTech
//
//  Created by Bhavik Bhatt on 08/02/23.
//

import SwiftUI

struct PersonalFeed: View {
    @EnvironmentObject var vmOfPersonalFeed: PersonalFeedModel
    @EnvironmentObject var vmOfPostFeed: PostFeedViewModel
    @EnvironmentObject var vm: TechnologyPickerViewModel
    @AppStorage("user_uid") var userID: String = ""
    var personalFeedOfOwn: Bool
    var idOfOtherUser: String?
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack{
                if vmOfPersonalFeed.isFetching{
                    ProgressView()
                        .padding(.top, 30)
                }else{
                    if vmOfPersonalFeed.recentPostsOfOwn.isEmpty{
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
            guard !vmOfPersonalFeed.basedOnUID else { return }
            vmOfPersonalFeed.isFetching = true
            vmOfPersonalFeed.recentPostsOfOwn = []
            /* paginationDoc must set to nil as if it is not set to nil, whatever next 20 post of there are after paginationDoc will be fetched. There are no issues as such but here when user refreshes we set recentPosts to blank array, so if pagination doc is not nil then before pagination doc whatever docs are, their data won't be in recentPosts array*/
            vmOfPersonalFeed.paginationDocumentForPersonalFeed = nil
            
            await vmOfPersonalFeed.fetchPosts(selectedTechnologies: vm.selectedTechnologies, basedOnUID: vmOfPersonalFeed.basedOnUID, uid: personalFeedOfOwn ? userID : idOfOtherUser!)
     
            
        }
        .task {
            print("called")
            vmOfPersonalFeed.paginationDocumentForPersonalFeed = nil
            vmOfPersonalFeed.recentPostsOfOwn = []
            vmOfPersonalFeed.isFetching = true
            await vmOfPersonalFeed.fetchPosts(selectedTechnologies: vm.selectedTechnologies, basedOnUID: vmOfPersonalFeed.basedOnUID, uid: personalFeedOfOwn ? userID : idOfOtherUser!)
      
        }
    }
    @ViewBuilder
    func posts() -> some View{
        ForEach(vmOfPersonalFeed.recentPostsOfOwn){post in
            PostCardView(post: post) { updatedPost in
                if let index = vmOfPersonalFeed.recentPostsOfOwn.firstIndex(where: { post in
                    post.id == updatedPost.id
                }){
                    vmOfPersonalFeed.recentPostsOfOwn[index].likeIDs = updatedPost.likeIDs
                    vmOfPersonalFeed.recentPostsOfOwn[index].dislikedIDs = updatedPost.dislikedIDs
                }
            } onDelete: {
                withAnimation(.easeInOut(duration: 0.25)){
                    vmOfPersonalFeed.recentPostsOfOwn.removeAll{post.id == $0.id}
                }
            }
            /* below mentioned on appear is code responsible for pagination*/
            .onAppear{
                if post.id == vmOfPersonalFeed.recentPostsOfOwn.last?.id && vmOfPersonalFeed.paginationDocumentForPersonalFeed != nil{
                        
                    Task{
                        await vmOfPersonalFeed.fetchPosts(selectedTechnologies: vm.selectedTechnologies, basedOnUID: vmOfPersonalFeed.basedOnUID, uid: personalFeedOfOwn ? userID: idOfOtherUser!)
                    }
                }
            }
            
            /* padding given on horizontal is -15 coz on LazyVstack, we have given padding of 15*/
            Divider()
                .padding(.horizontal, -15)

        }
    }
}

struct PersonalFeed_Previews: PreviewProvider {
    static var previews: some View {
        PersonalFeed(personalFeedOfOwn: true, idOfOtherUser: "")
            .environmentObject(TechnologyPickerViewModel())
            .environmentObject(PostFeedViewModel())
    }
}
