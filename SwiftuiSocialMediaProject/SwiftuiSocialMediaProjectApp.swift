//
//  SwiftuiSocialMediaProjectApp.swift
//  SwiftuiSocialMediaProject
//
//  Created by Bhavik Bhatt on 05/02/23.
//

import SwiftUI
import Firebase

@main
struct SwiftuiSocialMediaProjectApp: App {
 
    @AppStorage("log_status") var logStatus: Bool = false
   
//    var logStatus: Bool = UserDefaults.automaticallyNotifiesObservers(forKey: "log_status")
    init(){
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            if logStatus{
                MainView()
            }else{
                LoginPage()
            }
           
        }
    }
}
