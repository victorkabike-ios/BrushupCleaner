//
//  CircularProgressView.swift
//  BrushupCleaner
//
//  Created by victor kabike on 2023/07/08.
//

import Foundation
import SwiftUI


struct CircularProgressView: View {
    var progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 20.0)
                .opacity(0.3)
                .foregroundColor(Color.white)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 20.0, lineCap: .round, lineJoin: .round))
                .fill(AngularGradient(gradient: Gradient(colors: [Color.blue]), center: .center))
                .rotationEffect(Angle(degrees: 270.0))
            
            Text(String(format: "%.0f %%", min(self.progress, 1.0)*100.0))
                .font(.largeTitle)
                .bold()
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
        }
    }
}
