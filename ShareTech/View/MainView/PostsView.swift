//
//  PostsView.swift
//  SwiftuiSocialMediaProject
//
//  Created by Bhavik Bhatt on 06/02/23.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage

struct PostsView: View {
    
    
    @State private var createNewPost: Bool = false
//    @State private var recentPosts: [Post] = []
    @EnvironmentObject var vm: TechnologyPickerViewModel
    @EnvironmentObject var vmOfPostFeed: PostFeedViewModel
    @State private var showTechnologySelector: Bool = true
    @State private var showSearchUserView: Bool = false

    
    var body: some View {
        NavigationStack{
            PostFeedView()
                .hAligned(alignment: .center)
                .vAligned(alignment: .center)
                .fullScreenCover(isPresented: $showTechnologySelector, content: {
                    TechnologyPicker(areTechnologySelectedForPosts: false)
                })
                .overlay(alignment: .bottomTrailing){
                    Button{
                        vm.selectedTechnologiesForPosts = []
                        createNewPost.toggle()
                    }label: {
                        Image(systemName: "plus")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(13)
                            .background(.black, in: Circle())
                    }
                    .padding()
                    .sheet(isPresented: $showTechnologySelector) {
                        TechnologyPicker(areTechnologySelectedForPosts: false)
                    }
                }
                .toolbar(content: {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showSearchUserView.toggle()
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .tint(.black)
                                .scaleEffect(0.9)
                        }
                        
                    }
                    
                    
                    
                    ToolbarItem(placement: .navigationBarLeading) {
                        Image(systemName: "line.horizontal.3.decrease.circle")
                            .foregroundColor(.black)
                            .onTapGesture {
                                showTechnologySelector.toggle()
                            }
                    }
                })
                .sheet(isPresented: $showSearchUserView, content: {
                    SearchUserView()
                })
                .navigationTitle("Posts")
        }
        .fullScreenCover(isPresented: $createNewPost) {
            CreateNewPost { post in
                vmOfPostFeed.recentPosts.insert(post, at: 0)
            }
        }
    }
        
}

struct PostsView_Previews: PreviewProvider {
    static var previews: some View {
        PostsView()
            .environmentObject(TechnologyPickerViewModel())
            .environmentObject(PostFeedViewModel())
    }
}
