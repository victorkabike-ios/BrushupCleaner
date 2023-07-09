//
//  RingAminationView.swift
//  BrushupCleaner
//
//  Created by victor kabike on 2023/07/09.
//

import Foundation
import SwiftUI

struct RingAnimation: View {
    @Binding var progressValue:Double
    @State private var progress:Double = 0
    
    let animation = Animation
        .easeOut(duration: 3)
        .delay(0.5)
    var body: some View {
        ZStack{
            
            ring(for: Color.blue)
                    .frame(width: 164)
            Text(String(format: "%.0f %%", min(self.progress, 1.0)*100.0))
                .font(.largeTitle)
                .bold()
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
        }.animation(animation, value: progress)
            .onAppear {
                progress = progressValue
            }
        
    }
    
    func ring(for color: Color) -> some View {
            // Background ring
            Circle()
                .stroke(style: StrokeStyle(lineWidth: 16))
                .foregroundStyle(.blue.opacity(0.4))
                .overlay {
                    // Foreground ring
                    Circle()
                        .trim(from: 0, to: CGFloat(min(progress, 1.0)))
                        .stroke(color.gradient,
                                style: StrokeStyle(lineWidth: 16, lineCap: .round))
                }
                .rotationEffect(.degrees(-90))
        }
}
