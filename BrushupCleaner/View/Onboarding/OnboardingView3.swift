//
//  OnboardingView3.swift
//  BrushupCleaner
//
//  Created by victor kabike on 2023/07/08.
import Foundation
import SwiftUI

struct OnboardingView3: View {
    @State private var isTextVisible = false

    var body: some View {
        NavigationStack{
            ZStack{
                Color("backgroundColor")
                    .opacity(0.6)
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    Spacer()
                    Image("video")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    Spacer()
                    VStack(alignment: .leading) {
                        FeatureView(title: "Compress Large Videos", description: "Don't let large video files eat up your storage. Brush compresses them without compromising on quality.")
                    }
                    .padding(.horizontal, 30)
                    Spacer()
                    NavigationLink(destination: OnboardingView4().navigationBarBackButtonHidden(true)) {
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
