//
//  VideoCompressionView.swift
//  BrushupCleaner
//
//  Created by victor kabike on 2023/07/08.
//

import SwiftUI
import AVKit
import AVFoundation
import FYVideoCompressor
struct VideoCompressionView: View {
    @Binding var selectedVideo: Video?
    @State private var compressionQuality: VideoQuality = .mediumQuality
    @State private var isCompressing = false
    @State private var compressedVideoURL: URL?
    @State private var showResults = false
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationView{
            ZStack{
                Color("backgroundColor").edgesIgnoringSafeArea(.all)
                VStack {
                    if let video = selectedVideo {
                        if isCompressing {
                            CompressionProgressView()
                        } else  {
                            VStack{
                                VideoPlayer(player: AVPlayer(url: video.url))
                                    .frame(height: 400)
                                    .cornerRadius(15)
                                    .padding(.horizontal)
                                Spacer()
                                VStack{
                                    Text("Select Compression Quality")
                                        .font(.title2)
                                        .bold()
                                        .padding(.bottom, 10)
                                    
                                    HStack {
                                        QualityButton(quality: .lowQuality, selectedQuality: $compressionQuality)
                                        QualityButton(quality: .mediumQuality, selectedQuality: $compressionQuality)
                                        QualityButton(quality: .highQuality, selectedQuality: $compressionQuality)
                                    }
                                    .padding(.bottom, 20)
                                    
                                    ActionButton(title: "Compress", action: compressVideo, color: .blue)
                                        .padding(.bottom,40)
                                }
                                .padding(20)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(25)
                            }
                        }
                        
                    }
                }
            }
            .navigationTitle("Compress Video")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading){
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                    }

                }
            }
            .edgesIgnoringSafeArea(.bottom)
            .fullScreenCover(isPresented: $showResults) {
                if let originalVideoURL =  selectedVideo?.url{
                    if let url = compressedVideoURL{
                        CompressionResultsView(originalVideoURL: originalVideoURL , compressedVideoURL: url)
                    }
                }
            }

        }
    }
    
    func compressVideo() {
        guard let video = selectedVideo else { return }
        
        isCompressing = true
        
        let inputURL = video.url
        let outputURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("mp4")
        
        let compressor = FYVideoCompressor()
        let config = FYVideoCompressor.CompressionConfig(videoBitrate: 1000_000,
                                                        videomaxKeyFrameInterval: 10,
                                                        fps: 24,
                                                        audioSampleRate: 44100,
                                                        audioBitrate: 128_000,
                                                        fileType: .mp4,
                                                        scale: CGSize(width: 640, height: 480))
        FYVideoCompressor().compressVideo(inputURL, quality: .lowQuality) { result in
            DispatchQueue.main.async {
                isCompressing = false
                
                switch result {
                case .success(let compressedURL):
                    compressedVideoURL = compressedURL
                    showResults = true
                case .failure(let error):
                    print("Error compressing video: \(error)")
                }
            }
        }
    }
}
struct CompressionProgressView: View {
    @State private var progress: CGFloat = 0.0
    var body: some View {
        VStack {
            Text("Compressing...")
                .font(.headline)
                .padding(.bottom, 10)
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(Color.gray.opacity(0.1))
                    .frame(height: 10)
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.blue)
                    .frame(width: self.progress * 350, height: 10)
            }
            .animation(.linear)
        }
        .frame(width: 350)
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                if self.progress < 1.0 {
                    self.progress += 0.01
                } else {
                    timer.invalidate()
                }
            }
        }
    }
}

struct QualityButton: View {
    let quality: VideoQuality
    @Binding var selectedQuality: VideoQuality
    
    var body: some View {
        Button(action: { selectedQuality = quality }) {
            Text(quality.rawValue)
                .bold()
                .frame(maxWidth: .infinity)
                .padding(10)
                .background(selectedQuality == quality ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(.white)
                .cornerRadius(15)
        }
    }
}

struct ActionButton: View {
    let title: String
    let action: () -> Void
    let color: Color
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.title2)
                .bold()
                .frame(maxWidth: .infinity)
                .padding()
                .background(color)
                .foregroundColor(.white)
                .cornerRadius(15)
        }
    }
}
