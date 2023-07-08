//
//  SubscriptionTermsView.swift
//  BrushupCleaner
//
//  Created by victor kabike on 2023/07/08.
//

import Foundation
import SwiftUI

struct SubscriptionTermsView: View {
    @Environment(\.dismiss) var dismissAction
    var body: some View {
        NavigationStack{
            ZStack{
                Color("backgroundColor")
                    .opacity(0.6)
                    .edgesIgnoringSafeArea(.all)
                ScrollView{
                    LazyVStack(alignment: .leading, spacing: 10) {
                        VStack(alignment: .leading){
                            Text("Subscription Terms and Conditions")
                                .font(.title)
                                .fontWeight(.bold)
                        }
                        VStack(alignment: .leading){
                            Text("1. Subscription Period")
                                .font(.headline)
                            Text("The subscription period will start when you subscribe to the app and will continue until you cancel your subscription.")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .padding()
                            
                            Text("2. Automatic Renewal")
                                .font(.headline)
                            Text("Your subscription will automatically renew at the end of each subscription period unless you cancel it at least 24 hours before the end of the current period.")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .padding()
                            
                            Text("3. Payment")
                                .font(.headline)
                            Text("Payment will be charged to your iTunes & App Store/Apple ID account at confirmation of purchase or after the end of the free trial.")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .padding()
                        }
                        VStack(alignment: .leading){
                            
                            Text("4. Cancellation")
                                .font(.headline)
                            Text("You can cancel your subscription anytime by turning off auto-renewal through your Account settings.")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .padding()
                            
                            Text("5. Refunds")
                                .font(.headline)
                            Text("If you purchased a subscription through the Apple App Store and are eligible for a refund, you’ll have to request it directly from Apple.")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .padding()
                            
                            Text("6. Managing Subscriptions")
                                .font(.headline)
                            Text("You alone can manage your subscriptions. Learn more about managing subscriptions (and how to cancel them) on the Apple support page. Note that deleting the app does not cancel your subscriptions. However, if you use Apple’s iOS 13 or later versions, Apple provides you with a convenient way to manage subscriptions when you delete an app.")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .padding()
                        }
                    }
                    .padding()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismissAction()
                    }) {
                        Text("Agree")
                    }
                }
            }
        }
    }
}


