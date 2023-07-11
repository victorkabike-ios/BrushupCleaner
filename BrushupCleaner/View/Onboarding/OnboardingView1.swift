//
//  OnboardingView1.swift
//  BrushupCleaner
//
//  Created by victor kabike on 2023/07/08.
//

import Foundation
import SwiftUI
import Combine


struct OnboardingView1: View {
    @State private var isTextVisible = false
    var body: some View {
        NavigationStack{
            ZStack{
                Color("backgroundColor")
                    .opacity(0.6)
                    .edgesIgnoringSafeArea(.all)
                VStack(alignment: .center){
                    Spacer()
                    Image("contentview")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    Spacer()
                    VStack {
                        Text("Brush Up")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.bottom, 10)
                        Text("Brush - Storage Cleaner is designed to help you declutter your device with ease. With our advanced algorithms, we can help you identify and remove similar photos and videos, compress large video files, and merge duplicate contacts. Let's get started!")
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                        Spacer()
                        NavigationLink(destination: OnboardingView2().navigationBarBackButtonHidden(true)) {
                            Text("Start Cleaning")
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
                    .navigationBarBackButtonHidden(true)
                }
            }
        }
    }
}
