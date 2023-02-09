//
//  TechnologyLogo.swift
//  ShareTech
//
//  Created by Bhavik Bhatt on 08/02/23.
//

import SwiftUI

struct TechnologyLogo: View {
    
    var name: String
    
    var body: some View {
        Text(name)
            .foregroundColor(.white)
            .fontWeight(.semibold)
            .padding()
            .frame(height: 50)
            .background(
            RoundedRectangle(cornerRadius: 10)
            )
           
    }
}

struct TechnologyLogo_Previews: PreviewProvider {
    static var previews: some View {
        TechnologyLogo(name: "Node js")
    }
}
