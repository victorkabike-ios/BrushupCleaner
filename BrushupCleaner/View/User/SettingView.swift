//
//  SettingView.swift
//  BrushupCleaner
//
//  Created by victor kabike on 2023/07/08.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    let recipient = "tinotendakab@icloud.com"
    let instagramURL = URL(string: "https://instagram.com/brushcleanerapp?igshid=MmIzYWVlNDQ5Yg==")!
    @ObservedObject var userModel = UserViewModel.shared
    @Binding var paywallPresented: Bool
    var body: some View {
        NavigationView {
            Form {
                
                Section(header: Text("Feedback")) {
                    Button(action: {
                        // Rate app
                    }) {
                        HStack {
                                               Image(systemName: "star.fill")
                                                   .foregroundColor(.yellow)
                                               Text("Rate App")
                                           }
                    }
                    
                    Button(action: {
                        // Share app
                    }) {
                        HStack {
                                               Image(systemName: "square.and.arrow.up")
                                                   .foregroundColor(.blue)
                                               Text("Share App")
                                           }
                    }
                    
                    Button(action: {
                        let email  = "mailto:\(recipient)"
                     guard let url = URL(string: email) else { return }
                                UIApplication.shared.open(url)
                            }) {
                                HStack {
                                    Image(systemName: "exclamationmark.bubble")
                                        .foregroundColor(.red)
                                    Text("Report Bug")
                                }
                            }
                    Button(action: { UIApplication.shared.open(instagramURL)}, label: {
                        HStack {
                                               Image(systemName: "info.circle")
                                                   .foregroundColor(.blue)
                                               Text("About")
                                           }
                    })
                }
            }
            .navigationBarTitle("Settings")
            .navigationBarItems(trailing: NavigationLink {
                PaywallView( paywallsheet: $paywallPresented)
            } label: {
                Label {
                    Text("Unlock Premium")
                } icon: {
                    Image(systemName: "crown.fill")
                        .foregroundColor(.yellow)
                }
                .padding(8)
                .background(Color("backgroundColor"))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            })
        }
    }
}

struct AboutView: View {
    var body: some View {
        Text("About View")
            .navigationBarTitle("About")
    }
}

struct SupportView: View {
    var body: some View {
        Text("Support View")
            .navigationBarTitle("Support")
    }
}
