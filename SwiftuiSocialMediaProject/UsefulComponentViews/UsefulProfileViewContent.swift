//
//  UsefulProfileViewContent.swift
//  SwiftuiSocialMediaProject
//
//  Created by Bhavik Bhatt on 06/02/23.
//

import SwiftUI
import SDWebImageSwiftUI
import SDWebImage

struct UsefulProfileViewContent: View {
    var user: User
    @State private var fetchedPosts: [Post] = []
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack{
                HStack(spacing: 12){
                    WebImage(url: user.profilePicURL).placeholder(content: {
                        ProgressView()
                    })
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 120, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(user.Username)
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Text(user.userBio)
                            .foregroundColor(.gray)
                            .lineLimit(3)
                        
                        if let biolink = URL(string: user.userBioLink){
                            Link(user.userBioLink, destination: biolink)
                                .font(.callout)
                                .tint(.blue)
                                .lineLimit(1)
                        }
                    }
                    .hAligned(alignment: .leading)
                }
                
                
                Text("My post's")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .hAligned(alignment: .leading)
                    .padding(.vertical, 4)
                
                PostFeedView(basedOnUID: true,  uid: user.userUID, recentPosts: $fetchedPosts)
            }
            .padding(15)
        }
    }
}

//struct ProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProfileView()
//    }
//}
