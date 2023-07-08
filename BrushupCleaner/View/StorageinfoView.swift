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
            CircularProgressView(progress: usedPercentage)
                .frame(height: 160)
            Text("\(String(format: "%.1f", usedStorage))GB of \(String(format: "%.1f", totalStorage))GB used")
                .font(.headline)
                .onAppear(perform: getStorage)
                .padding()
        }
    }
    func getStorage() {
        if let (usedCapacity, totalCapacity , usedPercentage) = getStorageInfo() {
              usedStorage = usedCapacity / 1_000_000_000
              totalStorage = totalCapacity / 1_000_000_000
            self.usedPercentage = usedPercentage / 100.0
          } else {
              print("Failed to retrieve storage info")
          }
      }
   
}

//struct StorageInfoView: View {
//    var body: some View {
//        VStack {
//            if let storageInfo = getStorageInfo() {
//                let usedGB = storageInfo.used / (1024 * 1024 * 1024)
//                let totalGB = storageInfo.total / (1024 * 1024 * 1024)
//
//                Text("Storage used: \(String(format: "%.1f", usedGB))GB of \(String(format: "%.0f", totalGB))GB")
//                    .font(.system(size: 20))
//                    .padding()
//            } else {
//                Text("Failed to retrieve storage information")
//                    .font(.system(size: 20))
//                    .padding()
//            }
//        }
//    }
//}
