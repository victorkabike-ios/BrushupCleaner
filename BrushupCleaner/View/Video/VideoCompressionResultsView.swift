//
//  VideoCompressionResultsView.swift
//  BrushupCleaner
//
//  Created by victor kabike on 2023/07/08.
//
import Foundation
import SwiftUI
import AVFoundation
import AVKit
import Photos

struct CompressionResultsView: View {
    let originalVideoURL: URL
    let compressedVideoURL: URL
    
    @State var showCongratview = false
    
    @State private var isSavingToLibrary = false
    @State private var showAlert = false
    @State private var isDeleteAlertShowing = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView{
            VStack {
                VStack {
                    VideoPlayer(player: AVPlayer(url: compressedVideoURL))
                    HStack{
                        GroupBox{
                            VStack(alignment: .center){
                                Text("Original Size")
                                    .font(.subheadline)
                                    .bold()
                                if let dimensions = getVideoDimensions(url: originalVideoURL) {
                                    Text(" \(Int(dimensions.width)) x \(Int(dimensions.height))")
                                }
                                if let fileSize = getFileSize(url: originalVideoURL) {
                                    Text("\(fileSize)")
                                }
                                
                            }
                        }
                        GroupBox{
                            VStack(alignment: .center){
                                Text("Compressed Size")
                                    .font(.subheadline)
                                    .bold()
                                if let dimensions = getVideoDimensions(url: compressedVideoURL) {
                                    Text("\(Int(dimensions.width)) x \(Int(dimensions.height))")
                                }
                                if let fileSize = getFileSize(url: compressedVideoURL) {
                                    Text("\(fileSize)")
                                }
                            }
                        }
                    }
                }
                Spacer()
                Button(action: saveToLibrary) {
                    Text("Save to Library")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 350, height: 60)
                        .background(isSavingToLibrary ? Color.gray : Color.blue)
                        .cornerRadius(10)
                }
                .disabled(isSavingToLibrary)
                
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Delete Original Video"),
                    message: Text("What would you like to do with the original video?"),
                    primaryButton: .destructive(Text("Delete")){
                        PHPhotoLibrary.requestAuthorization { (status) in
                            switch status {
                            case .authorized:
                                deleteVideoFromLibrary()
                                
                            case .denied, .restricted:
                                print("Permission denied")
                            case .notDetermined:
                                // Permission has not been asked yet
                                print("Permission not determined")
                            case .limited:
                                // Permission is limited
                                print("Permission limited")
                            @unknown default:
                                fatalError("Unknown authorization status")
                            }
                        }
                    },
                    secondaryButton: .default(Text("Keep"), action: keepOriginalVideo)
                )
            }
            .fullScreenCover(isPresented: $showCongratview, content: {
                VideCompressedCongratsView(originalVideoURL: originalVideoURL, compressedVideoURL: compressedVideoURL)
            })
            .navigationTitle("Compression Results")
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
            
        }
    }
    
    func saveToLibrary() {
        isSavingToLibrary = true
        
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: compressedVideoURL)
        } completionHandler: { success, error in
            DispatchQueue.main.async {
                isSavingToLibrary = false
                
                if success {
                    showAlert = true // Show the delete alert
                } else if let error = error {
                    print("Error saving video to library: \(error)")
                }
            }
        }
    }

    func deleteVideoFromLibrary() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.video.rawValue)
        
        let fetchResult = PHAsset.fetchAssets(with: fetchOptions)
        fetchResult.enumerateObjects { (asset, _, _) in
            if asset.mediaType == .video && asset.value(forKey: "filename") as! String == originalVideoURL.lastPathComponent {
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.deleteAssets([asset] as NSArray)
                }, completionHandler: { success, error in
                    if success {
                        print("Successfully deleted video")
                        showCongratview.toggle()
                    } else if let error = error {
                        print("Error deleting video: \(error)")
                    } else {
                        print("Unknown error occurred")
                    }
                })
            }
        }
    }

    

    func keepOriginalVideo() {
        // Do nothing, the original video will be kept
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

    func getVideoDimensions(url: URL) -> CGSize? {
        let asset = AVAsset(url: url)
        let track = asset.tracks(withMediaType: .video).first
        if let track = track {
            let size = track.naturalSize.applying(track.preferredTransform)
            return CGSize(width: abs(size.width), height: abs(size.height))
        }
        return nil
    }

}
