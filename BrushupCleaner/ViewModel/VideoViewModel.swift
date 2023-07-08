//
//  VideoViewModel.swift
//  BrushupCleaner
//
//  Created by victor kabike on 2023/07/08.
//

import Foundation
import Photos
import AVFoundation


import Photos

class VideoViewModel: ObservableObject {
    @Published var videos: [Video] = [] {
            didSet {
                self.videosCount = videos.count
                self.videosSize = videos.reduce(0) { $0 + $1.size }
            }
        }
    @Published var videosCount: Int = 0

    @Published var videosSize: Int64 = 0
    
    func fetchLargeSizeVideos() {
        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.video.rawValue)
        let allVideos = PHAsset.fetchAssets(with: options)

        allVideos.enumerateObjects { (asset, _, _) in
            let resources = PHAssetResource.assetResources(for: asset)
            if let resource = resources.first, let fileSize = resource.value(forKey: "fileSize") as? Int64, fileSize > 5_000_000 {
                
                // Fetch the video URL
                PHImageManager.default().requestAVAsset(forVideo: asset, options: nil) { (avAsset, _, _) in
                    if let urlAsset = avAsset as? AVURLAsset {
                        let videoURL = urlAsset.url
                        
                        // Create the Video instance inside the completion block
                        let video = Video(id: UUID().uuidString, asset: asset, size: fileSize, duration: asset.duration, url: videoURL)
                        
                        DispatchQueue.main.async {
                            self.videos.append(video)
                            self.videos.sort(by: { $0.size > $1.size })
                            print(self.videos.reduce(0) { $0 + $1.size })
                        }
                    }
                }
            }
        }
    }


}
