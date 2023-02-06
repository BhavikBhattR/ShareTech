//
//  MainView.swift
//  SwiftuiSocialMediaProject
//
//  Created by Bhavik Bhatt on 06/02/23.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView{
            PostsView()
                .tabItem {
                    Image(systemName: "rectangle.portrait.on.rectangle.portrait.angled")
                    Text("post's")
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Profile")
                }
        }
        .tint(.black)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
