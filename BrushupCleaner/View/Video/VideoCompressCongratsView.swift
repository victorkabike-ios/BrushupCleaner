//
//  VideoCompressCongratsView.swift
//  BrushupCleaner
//
//  Created by victor kabike on 2023/07/08.
//

import Foundation
import SwiftUI

struct VideCompressedCongratsView: View {
    let originalVideoURL: URL
    let compressedVideoURL: URL
    @Environment(\.dismiss) var dismiss
    @State private var counter: Int = 0
    
    var body: some View {
        VStack {
            Text("🎉")
                .font(.system(size: 100))
                .confettiCannon(counter: $counter,rainHeight: 1000.0, radius: 500, repetitions: 3, repetitionInterval: 0.7)
            
            Text("Congratulations!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            GroupBox{
                VStack(alignment: .leading, spacing: 40){
                     
                    Label {
                        if let originalSize = getFileSize(url: originalVideoURL){
                            Text("Freed up ") + Text("\(originalSize)")
                            .foregroundColor(.blue)
                            + Text(" of storage space.")
                    }

                } icon: {
                    Image(systemName: "opticaldiscdrive.fill")
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.red)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                
                }.padding()
        }
            Spacer()
            Button(action: {
                           dismiss()
                        }) {
                            Text("Awesome")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(width: 360, height: 50)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        
        }
        .onAppear {
            counter = 2
        }
    }
    func getFileSize(url: URL) -> String? {
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: url.path)
            if let fileSize = fileAttributes[FileAttributeKey.size] as? NSNumber {
                let byteCountFormatter = ByteCountFormatter()
                byteCountFormatter.allowedUnits = [.useKB, .useMB, .useGB]
                byteCountFormatter.countStyle = .file
                return byteCountFormatter.string(fromByteCount: Int64(fileSize))
            }
        } catch {
            print("Error: \(error)")
        }
        return nil
    }
}
