//
//  TechnologyPicker.swift
//  ShareTech
//
//  Created by Bhavik Bhatt on 08/02/23.
//
/*
 {
     HStack{
         Spacer()
         Text("+ new message")
         Spacer()
     }
     .padding(.vertical)
     .background(Color.purple)
     .cornerRadius(10)
     .padding(.horizontal)
     .shadow(color: Color.theme.secondaryTextColor, radius: 2)
     .foregroundColor(.primary)
     .font(.headline)
     .fullScreenCover(isPresented: $showNewMessageScreen) {
         NewMessageScreen { user in
             self.selectedChatUser = user
             self.PtoPmessageViewModel.receiver = user
             self.PtoPmessageViewModel.getAllMessages()
             self.showPtoPMessageScreeen.toggle()
         }
     }
 }
 */

import SwiftUI

struct TechnologyPicker: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("user_uid") var userID: String = ""
    var colors: [Color] = [.red, .blue, .green, .yellow, .pink, .purple, .cyan]
   @State var allItems:[String] = [
        "Node JS",
        "JavaScript",
        "Swift",
        "ios",
        "Java",
        ".NET",
        "SQL",
        "Devops",
        "Blockchain",
        "Linux",
        "C#",
        "Cloud computing",
        "AI/ML",
        "AR/VR",
        "React JS",
        "Data Science",
        "Web Dev",
        "Cyber security"
    ]
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    var areTechnologySelectedForPosts: Bool = false
    @EnvironmentObject var vm: TechnologyPickerViewModel
    @EnvironmentObject var vmOfPostFeed: PostFeedViewModel
    @EnvironmentObject var vmOfPersonalFeed: PersonalFeedModel
    var body: some View {
        NavigationStack{
            ScrollView{
                if areTechnologySelectedForPosts{
                    LazyVGrid(columns: columns, alignment: .leading) {
                    ForEach(0..<allItems.count, id: \.self) { index in
                        TechnologyLogo(name: allItems[index])
                            .foregroundColor(vm.selectedTechnologiesForPosts.contains(allItems[index]) ? .green : .black)
                            .onTapGesture {
                                if vm.selectedTechnologiesForPosts.contains(allItems[index]){
                                    vm.selectedTechnologiesForPosts.removeAll { str in
                                        str == allItems[index]
                                    }
                                }else{
                                    vm.selectedTechnologiesForPosts.append(allItems[index])
                               
                                }
                            }
                    }
                }
                }else{
                    LazyVGrid(columns: columns, alignment: .leading) {
                    ForEach(0..<allItems.count, id: \.self) { index in
//                        TechnologyLogo(name: allItems[index])
                        ZStack{
                            Rectangle()
                                .fill(returnedColor(index: index))
                                .cornerRadius(10)
                                .frame(height: 150)
                            
                            Text(allItems[index])
                                .font(.subheadline)
                                .fontWeight(.bold)
                        }.overlay {
                            Rectangle()
                                .fill(.black.opacity(vm.selectedTechnologies.contains(allItems[index]) ? 0.3 : 0))
                                .cornerRadius(10)
                                .frame(height: 150)
                        }
                            .onTapGesture {
                                if vm.selectedTechnologies.contains(allItems[index]){
                                    vm.selectedTechnologies.removeAll { str in
                                        str == allItems[index]
                                    }
                                }else{
                                    vm.selectedTechnologies.append(allItems[index])
                                   
                                }
                            }
                    }
                }
                }
            }
            .padding([.top, .horizontal])
            .toolbar(areTechnologySelectedForPosts ? .visible : .hidden, for: .navigationBar)
            .navigationTitle("Filter post by technology")
            .navigationBarTitleDisplayMode(.inline)
        }
        .overlay(alignment: .bottom ,content: {
            if areTechnologySelectedForPosts{
                
            }else{
                if vm.selectedTechnologies.count > 0{
                    Button{
                        dismiss()
                    }label: {
                        HStack{
                            Spacer()
                            Text("Apply Filter")
                                .padding(2)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical)
                                .background(Color.black)
                                .cornerRadius(10)
                                .padding(.horizontal)
                            Spacer()
                        }
                    }
                }else{
                    Button{
                        dismiss()
                    }label: {
                        HStack{
                            Spacer()
                            Text("Show All Blogs")
                                .padding(2)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical)
                                .background(Color.black)
                                .cornerRadius(10)
                                .padding(.horizontal)
                            Spacer()
                        }
                    }
                }
            }
        })
        .onDisappear{
            Task{
               
                vmOfPostFeed.recentPosts = []
                vmOfPostFeed.isFetching = true
                vmOfPersonalFeed.recentPostsOfOwn = []
                vmOfPersonalFeed.isFetching = true
                vmOfPostFeed.listener?.remove()
                await vmOfPostFeed.fetchPosts(selectedTechnologies: vm.selectedTechnologies, basedOnUID: false, uid: userID)
                await vmOfPersonalFeed.fetchPosts(selectedTechnologies: vm.selectedTechnologies, basedOnUID: true, uid: userID)
            }
        }
    }
    func returnedColor(index: Int) -> Color{
        if index > colors.count - 1{
            return colors[index % colors.count]
        }else{
            return colors[index]
        }
    }
}

struct TechnologyPicker_Previews: PreviewProvider {
    static var previews: some View {
        TechnologyPicker()
            .environmentObject(TechnologyPickerViewModel())
    }
}
