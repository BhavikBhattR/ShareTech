//
//  TechnologyPickerViewModel.swift
//  ShareTech
//
//  Created by Bhavik Bhatt on 08/02/23.
//

import Foundation
import SwiftUI

class TechnologyPickerViewModel: ObservableObject{
    @EnvironmentObject var vmOfPostFeed: PostFeedViewModel
    @AppStorage("user_uid") var userID: String = ""
    @Published var selectedTechnologies: [String] = []
    @Published var selectedTechnologiesForPosts: [String] = []
}
