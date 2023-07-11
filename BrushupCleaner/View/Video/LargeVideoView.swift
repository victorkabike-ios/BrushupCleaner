//
//  LargeVideoView.swift
//  BrushupCleaner
//
//  Created by victor kabike on 2023/07/08.
//

import SwiftUI
import Photos
import AVKit

struct VideoView: View {
    @StateObject private var viewModel = VideoViewModel()
    @State private var selectedVideo: Video?
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationStack {
            ZStack{
                Color("backgroundColor").edgesIgnoringSafeArea(.all)
                ScrollView {
                    LazyVGrid(columns: [GridItem(.fixed(200)), GridItem(.fixed(200))], spacing: 16) {
                        ForEach(viewModel.videos) { video in
                            Button(action: {selectedVideo = video}) {
                                ZStack {
                                    VideoThumbnailView(asset: video.asset, size: video.size)
                                    Text(formatDuration(video.duration))
                                        .foregroundColor(.white)
                                        .font(.caption)
                                        .bold()
                                        .padding(.leading,120)
                                        .padding(.bottom,150)
                                    HStack {
                                        Text("\(video.size / 1_000_000) MB")
                                            .foregroundColor(.white)
                                            .frame(width: 80, height: 40)
                                            .background(Color.blue)
                                            .cornerRadius(15)
                                            .padding(.trailing, 8)
                                        
                                    }
                                    .padding(.top, 120)
                                }
                                .frame(width: 180, height: 200)
                                .cornerRadius(15)
                                .shadow(radius: 4)
                                .padding(8)
                            }
                            
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Large Videos")
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
            .onAppear {
                viewModel.fetchLargeSizeVideos()
            }
            .fullScreenCover(item: $selectedVideo) { video in
                            VideoCompressionView(selectedVideo: $selectedVideo)
                        }
        }
    }
    func formatDuration(_ duration: TimeInterval) -> String {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.hour, .minute, .second]
            formatter.unitsStyle = .positional
            formatter.zeroFormattingBehavior = .pad
            
            return formatter.string(from: duration) ?? ""
        }
}

struct VideoThumbnailView: View {
    let asset: PHAsset
    let size :Int64

    var body: some View {
        ZStack{
            Image(uiImage: getThumbnail(asset: asset))
                .resizable()
                .aspectRatio(contentMode: .fill)
        }
    }

    func getThumbnail(asset: PHAsset) -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        option.isSynchronous = true
        manager.requestImage(for: asset, targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: option, resultHandler: { (result, _) in
            thumbnail = result!
        })
        return thumbnail
    }
    
}
