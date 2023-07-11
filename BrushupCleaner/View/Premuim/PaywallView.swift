//
//  PaywallView.swift
//  BrushupCleaner
//
//  Created by victor kabike on 2023/07/08.
//

import Foundation
import SwiftUI
import RevenueCat
import ConfettiSwiftUI


struct PaywallView: View {
    @ObservedObject var userViewModel = UserViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var isPurchasing: Bool = false
    @State var currentOffering: Offering?
    @State var selectedOffer: Package?
    @State private var showCongratsAlert = false
    @State private var showSubscriptionTerms = false
    @State private var showTermsOfUse = false

    
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("backgroundColor")
                    .opacity(0.6)
                    .edgesIgnoringSafeArea(.all)
                if userViewModel.subscriptionActive {
                    PremiumCongratView(showCongratsAlert: $showCongratsAlert)
                }else{
                    LazyVStack(alignment: .center, spacing: 25){
                        HStack{
                            Button(action: {dismiss()}) {
                                Image(systemName: "xmark")
                                    .foregroundColor(.white)
                                    .font(.headline)
                                    .padding(6)
                                    .background(Color.white.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                  
                            }
                            Spacer()
                            Button(action: {
                                Task {
                                    try? await Purchases.shared.restorePurchases()
                                }
                            }) {
                                Text("Restore Purchase")
                                    .foregroundColor(.secondary)
                                    .font(.subheadline)
                                    
                            }
                        }
                        Section {
                            VStack(alignment: .leading, spacing: 15) {
                                FeatureRow(imageName: "photo.fill", title: "Unlimited Photo Cleaning")
                                FeatureRow(imageName: "paintbrush.fill", title: "Unlock Smart Cleaning Features")
                                FeatureRow(imageName: "video.fill", title: "Unlimited video compression")
                                FeatureRow(imageName: "crown.fill", title: "Access to Future Features")
                            }
                            .padding(.horizontal)
                        }
                    header: {
                        VStack(alignment: .leading) {
                            Text("Unlock Unlimited Access")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .padding(.bottom, 30)
                            Text("Get the most out of your device with our premium features.")
                                .font(.title3)
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                    }
                        
                        if currentOffering != nil{
                            Section {
                                ForEach(currentOffering!.availablePackages){ package in
                                    PackageCellView(package: package) { package in
                                        self.selectedOffer = package
                                    }
                                    .onAppear{
                                        if package.recommended{
                                            selectedOffer = package
                                        }
                                    }
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(selectedOffer == package ? Color.blue : Color.gray.opacity(0.2), lineWidth: 2)
                                    )
                                }
                                Spacer()
                                    Button {
                                        isPurchasing = true
                                        Purchases.shared.purchase(package: selectedOffer!) { (transaction, customerInfo, error, userCancelled) in
                                            // Unlock that great "pro" content
                                            if let error = error {
                                                print("Error making purchase: \(error.localizedDescription)")
                                            } else if userCancelled {
                                                print("User cancelled the purchase")
                                            } else {
                                                if customerInfo!.entitlements[Constants.entitlementID]?.isActive == true {
                                                    // Grant premium access to the user
                                                    print("Purchase successful!")
                                                    self.isPurchasing = false
                                                    showCongratsAlert = true
                                                }
                                            }
                                        }
                                    } label: {
                                        HStack{
                                            Text("Unlock Premium")
                                            if isPurchasing{
                                                ProgressView()
                                                    .progressViewStyle(CircularProgressViewStyle())
                                            }
                                        }
                                        .foregroundColor(.white)
                                        .bold()
                                        .frame(width: 360, height: 60)
                                        .background(Color.blue)
                                        .clipShape(RoundedRectangle(cornerRadius: 15))
                                    }.disabled(isPurchasing)
                                HStack {
                                            Spacer()
                                    Link("Privacy Policy", destination: URL(string: "https://www.freeprivacypolicy.com/live/a40d2df4-6956-4ff0-91e8-5f9b49a735b6")!)
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                        .underline()
                                            Spacer()
                                            Text("Terms of Use")
                                        .font(.caption)
                                                .foregroundColor(.blue)
                                                .underline()
                                                .onTapGesture {
                                                    // Show terms of use
                                                    showTermsOfUse = true
                                                }
                                            Spacer()
                                            Text("Subscription Terms")
                                        .font(.caption)
                                                .foregroundColor(.blue)
                                                .underline()
                                                .onTapGesture {
                                                    // Show subscription terms
                                                    showSubscriptionTerms = true
                                                }
                                            Spacer()
                                        }
                                
                                
                            }
                        }else{
                            ProgressView()
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .edgesIgnoringSafeArea(.bottom)
                }
                
            }
            .sheet(isPresented: $showSubscriptionTerms, content: {
                SubscriptionTermsView()
            })
            .sheet(isPresented: $showTermsOfUse, content: {
               TermsOfUseView()
            })
//            .toolbar(content: {
//                ToolbarItem(placement: .navigationBarLeading) {
//
//
//                }
//                ToolbarItem(placement: .navigationBarTrailing) {
//
//                }
//            })
            .onAppear{
                Purchases.shared.getOfferings { (offerings, error) in
                    if let offer = offerings?.current, error == nil {
                       currentOffering = offer
                    }
                }
            }
        }
    }
}

struct PackageCellView: View {

    let package: Package
    let onSelection: (Package) async -> Void
    var body: some View {
        Button {
            Task {
                await self.onSelection(self.package)
            }
        } label: {
            self.buttonLabel
        }
        .padding()
        .frame(width: 360, height: 60)
    }

    private var buttonLabel: some View {
        HStack {
            VStack(spacing: 10){
                HStack {
                    Text("\(package.storeProduct.localizedPriceString)")
                        .foregroundColor(.white)
                        .font(.headline)
                        .bold()
                    
                    Spacer()
                }
                HStack {
                    Text(package.storeProduct.localizedTitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            .padding([.top, .bottom], 8.0)
            
            Spacer()
            
            Text("-70% OFF")
                .foregroundColor(.white)
                .font(.caption)
                .bold()
                .padding(8)
                .background(LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing))
                .clipShape(Capsule())
        }
        
    }

}

extension NSError: LocalizedError {

    public var errorDescription: String? {
        return self.localizedDescription
    }

}

struct PremiumCongratView: View {
    @Binding var showCongratsAlert:Bool
    @State private var counter: Int = 0
    var body: some View {
        VStack {
            Text("🎉")
                .font(.system(size: 100))
                .confettiCannon(counter: $counter,rainHeight: 1000.0, radius: 500, repetitions: 3, repetitionInterval: 0.7)
            
            Text("Premium Unlocked")
                .font(.title)
                .fontWeight(.bold)
                .padding()
            Text("Congratations you can now access Premuim Features")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Button {
            } label: {
                Text("Great")
                    .foregroundColor(.white)
                    .bold()
                    .frame(width: 360, height: 60)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            }

        }
        .onAppear {
            counter = 4
        }
    }
}

struct FeatureRow: View {
    let imageName: String
    let title: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: imageName)
                .font(.caption)
                    .foregroundColor(.white)
                    .frame(width: 35, height: 35)
                    .background(Color.blue)
                    .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.bold)
            }
        }
    }
}
