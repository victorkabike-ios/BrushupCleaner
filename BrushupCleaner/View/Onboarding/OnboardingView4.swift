//
//  OnboardingView4.swift
//  BrushupCleaner
//
//  Created by victor kabike on 2023/07/08.
//

import Foundation
import SwiftUI

struct OnboardingView4: View {
    @State private var isTextVisible = false
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    var body: some View {
        NavigationView{
            VStack {
                Spacer()
                Image("contacts")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                Spacer()
                VStack(alignment: .leading) {
                    FeatureView(title: "Merge Duplicate Contacts", description: "No more confusion with duplicate contacts. Brush finds and merges them for a cleaner, more organized contact list.")
                }
                .padding(.horizontal, 30)
                Spacer()
                NavigationLink(destination: ContentView().navigationBarBackButtonHidden(true)) {
                    Text("Let's Brush Up!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 380, height: 60)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .onTapGesture {
                            hasCompletedOnboarding = true
                        }
                }
                .padding(.bottom, 50)
            }
            .opacity(isTextVisible ? 1 : 0)
            .animation(.easeIn(duration: 1.5))
            .onAppear {
                self.isTextVisible = true
            }
        }
    }
}
