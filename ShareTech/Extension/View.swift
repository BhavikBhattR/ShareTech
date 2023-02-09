//
//  View.swift
//  SwiftuiSocialMediaProject
//
//  Created by Bhavik Bhatt on 05/02/23.
//

import Foundation
import SwiftUI

extension View{
    
    func closeKeyboard(){
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func hAligned(alignment: Alignment) -> some View{
        return self.frame(maxWidth: .infinity, alignment: alignment)
    }
    
    func vAligned(alignment: Alignment) -> some View{
        return self.frame(maxHeight: .infinity, alignment: alignment)
    }
    
    func disabledIf(_ condition : Bool) -> some View{
        self
            .disabled(condition)
            .opacity(condition ? 0.6 : 1)
    }
    
}
