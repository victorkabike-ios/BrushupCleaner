//
//  StorageinfoView.swift
//  BrushupCleaner
//
//  Created by victor kabike on 2023/07/08.
//
import Foundation
import SwiftUI

struct StorageView: View {
    @State var usedStorage: Double = 0
    @State  var totalStorage: Double = 0
    @State  var usedPercentage: Double = 0
    
    var body: some View {
        VStack(spacing: 10){
            RingAnimation(progress: $usedPercentage)
//                .onAppear{
//                    getStorage()
//                }
                .frame(width: 180,height: 180)
                
            Text("\(String(format: "%.1f", usedStorage))GB of \(String(format: "%.1f", totalStorage))GB used")
                .font(.headline)
                .onAppear{
                    self.usedPercentage = getStorage()
                }
                .padding()
        }
    }
    func getStorage()-> Double {
        var percentage = 0.0
        if let (usedCapacity, totalCapacity , usedPercentage) = getStorageInfo() {
              usedStorage = usedCapacity / 1_000_000_000
              totalStorage = totalCapacity / 1_000_000_000
            withAnimation(.linear(duration: 2)){
                  percentage = usedPercentage / 100.0
            }
          } else {
              print("Failed to retrieve storage info")
          }
        return percentage
      }
   
}
