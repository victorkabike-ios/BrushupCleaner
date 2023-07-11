//
//  OnboardingView2.swift
//  BrushupCleaner
//
//  Created by victor kabike on 2023/07/08.
//

import Foundation
import SwiftUI

struct OnboardingView2: View {
    @State private var isTextVisible = false

    var body: some View {
        NavigationStack{
            ZStack{
                Color("backgroundColor")
                    .opacity(0.6)
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    Spacer()
                    Image("similarphotos")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    Spacer()
                    VStack(alignment: .leading) {
                        FeatureView(title: "Remove Similar Media", description: "Say goodbye to cluttered galleries. Brush identifies and helps you remove similar photos and videos, freeing up your storage.")
                    }
                    .padding(.horizontal, 30)
                    Spacer()
                    NavigationLink(destination: OnboardingView3().navigationBarBackButtonHidden(true)) {
                        Text("Continue")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 380, height: 60)
                            .background(Color.blue)
                            .cornerRadius(10)
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
}

struct FeatureView: View {
    var title: String
    var description: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .padding(.bottom, 5)
            Text(description)
                .font(.body)
                .foregroundColor(.gray)
                .padding(.bottom, 20)
        }
    }
}


