//
//  SearchBarView.swift
//  ShareTech
//
//  Created by Bhavik Bhatt on 09/02/23.
//

import SwiftUI

//struct SearchBarView: View {
//    var body: some View {
//        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
//    }
//}
//
//struct SearchBarView_Previews: PreviewProvider {
//    static var previews: some View {
//        SearchBarView()
//    }
//}
//
////
////  SearchBarView.swift
////  SwiftuiCoins
////
////  Created by Bhavik Bhatt on 27/01/23.
////
//
//import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String
    @FocusState var isKeyBoardFocused: Bool
    var body: some View {
        HStack{
            Image(systemName: "magnifyingglass")
                .foregroundColor(.black)
            TextField("Search user name", text: $searchText)
                .foregroundColor(.black)
                .autocorrectionDisabled()
                .keyboardType(.default)
                .focused($isKeyBoardFocused)
                .overlay(
                Image(systemName: "xmark.circle.fill")
                    .padding()
                    .offset(x: 10)
                    .foregroundColor(.black)
                    .opacity(searchText.isEmpty ? 0.0 : 1.0)
                    .onTapGesture {
                        searchText = ""
                        isKeyBoardFocused = false
                    }
                , alignment: .trailing
                )
        }
        .font(.headline)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(.white)
                .shadow(color: .black.opacity(0.15), radius: 10)
        )
        .padding()
    }
}

struct SearchBarView_Previews: PreviewProvider {
    static var previews: some View {
        SearchBarView(searchText: .constant(""))
    }
}
