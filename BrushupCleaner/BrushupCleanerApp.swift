//
//  BrushupCleanerApp.swift
//  BrushupCleaner
//
//  Created by victor kabike on 2023/07/08.
//

import SwiftUI
import RevenueCat

@main
struct BrushupCleanerApp: App {
    init(){
           Purchases.logLevel = .debug
           Purchases.configure(
                      with: Configuration.Builder(withAPIKey: Constants.apiKey)
                          .with(usesStoreKit2IfAvailable: true)
                          .build()
                  )
                  /* Set the delegate to our shared instance of PurchasesDelegateHandler */
                  Purchases.shared.delegate = PurchasesDelegateHandler.shared
       }
    var body: some Scene {
        WindowGroup {
                ContentView()
                    .background(Color("backgroundColor"))
                    .environmentObject(PhotoviewModel())
                    .environmentObject(VideoViewModel())
                    .environmentObject(ContactViewModel())
        }
    }
}
