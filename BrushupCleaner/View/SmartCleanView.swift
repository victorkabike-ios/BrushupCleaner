//
//  SmartCleanView.swift
//  BrushupCleaner
//
//  Created by victor kabike on 2023/07/08.
//


import Foundation
import SwiftUI
import Photos


struct SmartCleanView: View {
    @EnvironmentObject var photoViewModel: PhotoviewModel
    @EnvironmentObject var videoViewModel: VideoViewModel
    @EnvironmentObject var contactViewModel: ContactViewModel
    @EnvironmentObject var userModel : UserViewModel
    @State private var progress: Double = 0.0
    @State private var isFetching = true
    @State var totalPhotoSize: Double = 0
    @State var totalLivePhotoSize: Double = 0
    @State var screenshotPhotoSize: Double = 0
    @State var totalPhoto = 0
    @State var totalLivePhoto = 0
    @State var screenshotPhoto = 0
    @Environment(\.dismiss) var dismiss
    @State var paywallPresented = false
    
    var body: some View {
        NavigationView{
            ZStack{
                Color("backgroundColor")
                    .opacity(0.6)
                    .edgesIgnoringSafeArea(.all)
                VStack(spacing: 15){
                    VStack(alignment: .center,spacing: 30){
                        ZStack{
                            Circle()
                                .opacity(0.4)
                                .foregroundColor(Color.blue)
                                .frame(width: 240, height: 240)
                            ProgressBar(progress: $progress)
                                .onReceive(Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()) { _ in
                                    if progress < 1.0 {
                                        progress += 0.01
                                    } else {
                                        isFetching = false
                                    }
                                }
                                .frame(width: 180,height: 180)
                                .opacity(isFetching ? 1 : 0)
                            let similarPhoto = totalPhotoSize + totalLivePhotoSize + screenshotPhotoSize
                            let videosize = (Double(videoViewModel.videosSize) / (1024 * 1024))
                            let totalsize = (similarPhoto + videosize) / 1024
                            VStack{
                                
                                Text("\(totalsize, specifier: "%.2f") GB")
                                    .foregroundColor(.white)
                                    .font(.system(size: 46))
                                    .opacity(isFetching ? 0 : 1)
                                
                                    .bold()
                                Text("Files to clean up")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                                    .opacity(isFetching ? 0 : 1)
                            }
                            
                        }.padding(.top)
                        if isFetching{
                            VStack(spacing: 10){
                                Text("Scanning")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.primary)
                                Text("Looking for similar photos, videos and contacts")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.secondary)
                            }
                            
                        }
                        Spacer()
                    }
                    // Separate the calculation of similar photos, videos, and contacts into separate groups
                    if !isFetching {
                            LazyVStack{
                                ScrollView{
                                    NavigationLink {
                                        SimilarPhotoView(photos: photoViewModel.photoCategories, totalPhoto: $totalPhoto, totalSize: $totalPhotoSize)
                                            .environmentObject(photoViewModel)
                                            .navigationBarBackButtonHidden(true)
                                            .background(Color("backgroundColor")
                                                .opacity(0.3)
                                                .edgesIgnoringSafeArea(.all))
                                            .onAppear{
                                                photoViewModel.fetchAndCategorizePhotos()
                                            }
                                    } label: {
                                        GroupBox{
                                            HStack{
                                                Image(systemName: "photo.fill")
                                                    .font(.headline)
                                                    .foregroundColor(.white)
                                                    .frame(width: 40, height: 40)
                                                    .background(Color.blue)
                                                    .clipShape(Circle())
                                                VStack(alignment: .leading){
                                                    Text("Similar Photos")
                                                        .font(.headline)
                                                        .bold()
                                                        .foregroundColor(.white)
                                                    Text("\(totalPhoto) Photos")
                                                        .foregroundColor(.white)
                                                }
                                                Spacer()
                                                let similarPhotosize = totalPhotoSize
                                                Text("\(similarPhotosize, specifier: "%.2f") MB")
                                                    .font(.subheadline)
                                                    .foregroundColor(.white)
                                                Image(systemName: "chevron.right")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        .groupBoxStyle(CustomGroupBoxStyle(color: Color("groupBackgroundColor")))
                                        .onAppear{
                                            totalPhoto = photoViewModel.photoCategories.reduce(0) { result, category in
                                                result + category.count
                                            }
                                            calculateTotalDataSize(photoCategories: photoViewModel.photoCategories) { totalDataSize  in
                                                totalPhotoSize = totalDataSize
                                            }
                                        }
                                        
                                    }
                                    NavigationLink {
                                        SimilarPhotoView(photos: photoViewModel.livePhotoCategories, totalPhoto: $totalLivePhoto, totalSize: $totalLivePhotoSize)
                                            .environmentObject(photoViewModel)
                                            .navigationBarBackButtonHidden(true)
                                            .background(Color("backgroundColor")
                                                .opacity(0.3)
                                                .edgesIgnoringSafeArea(.all))
                                            .onAppear{
                                                photoViewModel.fetchAndCategorizeLivePhotos()
                                            }
                                    } label: {
                                        GroupBox{
                                            HStack{
                                                Image(systemName: "livephoto")
                                                    .font(.headline)
                                                    .foregroundColor(.white)
                                                    .frame(width: 40, height: 40)
                                                    .background(Color.blue)
                                                    .clipShape(Circle())
                                                VStack(alignment: .leading){
                                                    Text("Similar Live Photos")
                                                        .font(.headline)
                                                        .bold()
                                                        .foregroundColor(.white)
                                                    Text("\(totalLivePhoto) Photos")
                                                        .foregroundColor(.white)
                                                }
                                                Spacer()
                                                let similarPhotosize = totalLivePhotoSize
                                                Text("\(similarPhotosize, specifier: "%.2f") MB")
                                                    .font(.subheadline)
                                                    .foregroundColor(.white)
                                                Image(systemName: "chevron.right")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        .groupBoxStyle(CustomGroupBoxStyle(color: Color("groupBackgroundColor")))
                                        .onAppear{
                                            totalLivePhoto = photoViewModel.livePhotoCategories.reduce(0) { result, category in
                                                result + category.count
                                            }
                                            calculateTotalDataSize(photoCategories: photoViewModel.livePhotoCategories) { totalDataSize  in
                                                totalLivePhotoSize = totalDataSize
                                            }
                                        }
                                    }
                                    NavigationLink {
                                        SimilarPhotoView(photos: photoViewModel.ScreenshotCategories, totalPhoto: $screenshotPhoto, totalSize: $screenshotPhotoSize)
                                            .environmentObject(photoViewModel)
                                            .navigationBarBackButtonHidden(true)
                                            .background(Color("backgroundColor")
                                                .opacity(0.3)
                                                .edgesIgnoringSafeArea(.all))
                                            .onAppear{
                                                photoViewModel.fetchAndCategorizeScreenshotPhotos()
                                            }
                                    } label: {
                                        GroupBox{
                                            HStack{
                                                Image(systemName: "viewfinder")
                                                    .font(.headline)
                                                    .foregroundColor(.white)
                                                    .frame(width: 40, height: 40)
                                                    .background(Color.blue)
                                                    .clipShape(Circle())
                                                VStack(alignment: .leading){
                                                    Text("Similar Screenshot")
                                                        .font(.headline)
                                                        .bold()
                                                        .foregroundColor(.white)
                                                    Text("\(screenshotPhoto) Photos")
                                                        .foregroundColor(.white)
                                                }
                                                Spacer()
                                                let similarPhotosize = screenshotPhotoSize
                                                Text("\(similarPhotosize, specifier: "%.2f") MB")
                                                    .font(.subheadline)
                                                    .foregroundColor(.white)
                                                Image(systemName: "chevron.right")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                        }.groupBoxStyle(CustomGroupBoxStyle(color: Color("groupBackgroundColor")))
                                            .onAppear{
                                                screenshotPhoto = photoViewModel.ScreenshotCategories.reduce(0) { result, category in
                                                    result + category.count
                                                }
                                                calculateTotalDataSize(photoCategories: photoViewModel.ScreenshotCategories) { totalDataSize  in
                                                    screenshotPhotoSize = totalDataSize
                                                }
                                            }
                                    }
                                    NavigationLink {
                                        VideoView()
                                            .environmentObject(videoViewModel)
                                            .navigationBarHidden(true)
                                        
                                    } label: {
                                        GroupBox{
                                            HStack{
                                                Image(systemName: "video.fill")
                                                    .font(.headline)
                                                    .foregroundColor(.white)
                                                    .frame(width: 40, height: 40)
                                                    .background(Color.blue)
                                                    .clipShape(Circle())
                                                VStack(alignment: .leading){
                                                    Text("Videos")
                                                        .font(.headline)
                                                        .bold()
                                                        .foregroundColor(.white)
                                                    Text("\(videoViewModel.videosCount) videos")
                                                        .foregroundColor(.white)
                                                }
                                                Spacer()
                                                let videosSizeInMB = Double(videoViewModel.videosSize) / (1024 * 1024)
                                                
                                                if videosSizeInMB >= 1024 {
                                                    let videosSizeInGB = videosSizeInMB / 1024
                                                    Text("\(videosSizeInGB, specifier: "%.2f") GB")
                                                        .font(.subheadline)
                                                        .foregroundColor(.white)
                                                    Image(systemName: "chevron.right")
                                                        .font(.caption)
                                                        .foregroundColor(.secondary)
                                                } else {
                                                    Text("\(videosSizeInMB, specifier: "%.2f") MB")
                                                        .font(.subheadline)
                                                        .foregroundColor(.white)
                                                    Image(systemName: "chevron.right")
                                                        .font(.caption)
                                                        .foregroundColor(.secondary)
                                                }
                                                
                                            }
                                        }
                                        .groupBoxStyle(CustomGroupBoxStyle(color: Color("groupBackgroundColor")))
                                        .onAppear{
                                            videoViewModel.fetchLargeSizeVideos()
                                        }
                                    }
                                    NavigationLink {
                                        DuplicateContactsView()
                                            .navigationBarHidden(true)
                                    } label: {
                                        GroupBox{
                                            HStack{
                                                Image(systemName: "person.text.rectangle.fill")
                                                    .font(.headline)
                                                    .foregroundColor(.white)
                                                    .frame(width: 40, height: 40)
                                                    .background(Color.blue)
                                                    .clipShape(Circle())
                                                Text("Duplicate Contacts")
                                                    .font(.headline)
                                                    .bold()
                                                    .foregroundColor(.white)
                                                Spacer()
                                                let similarContactsCount = contactViewModel.duplicateContacts.reduce(0) { $0 + $1.value.count }
                                                
                                                Text("\(similarContactsCount) contacts")
                                                    .font(.subheadline)
                                                    .foregroundColor(.white)
                                                Image(systemName: "chevron.right")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        .groupBoxStyle(CustomGroupBoxStyle(color: Color("groupBackgroundColor")))
                                        .onAppear{
                                            contactViewModel.fetchContacts()
                                        }
                                    }
                                    
                                    
                                    Spacer()
                                    Button(action: {}) {
                                        Text("Delete All")
                                            .font(.title2)
                                            .foregroundColor(.white)
                                            .frame(width: 350, height: 60)
                                            .background(Color.blue)
                                            .clipShape(RoundedRectangle(cornerRadius: 18))
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .transition(.move(edge: .bottom))
                       
                    }
                    
                    
                }
            }
            .navigationTitle("Smart Clean")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Cancel")
                    }
                }
            }
        }
        
    }
    
    
    func calculateTotalDataSize(photoCategories: [[PhotoModel]], completion: @escaping (Double) -> Void) {
        var totalDataSize: Int = 0
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.deliveryMode = .highQualityFormat

        let imageManager = PHImageManager.default()

        for category in photoCategories {
            for photo in category {
                imageManager.requestImageData(for: photo.asset, options: options) { (data, _, _, _) in
                    if let size = data?.count {
                        totalDataSize += size
                    }
                }
            }
        }

        let totalDataSizeInMB = Double(totalDataSize) / (1024 * 1024)
        completion(totalDataSizeInMB)
    }

}

struct ProgressBar: View {
    @Binding var progress: Double
    
    var body: some View {
            ZStack {
                Circle()
                    .stroke(lineWidth: 20.0)
                    .opacity(0.3)
                    .foregroundColor(Color.blue)
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                    .stroke(style: StrokeStyle(lineWidth: 20.0, lineCap: .round, lineJoin: .round))
                    .foregroundColor(Color.blue)
                    .rotationEffect(Angle(degrees: 270.0))
                    .animation(.linear)
                Text(String(format: "%.0f %%", min(self.progress, 1.0)*100.0))
                    .font(.largeTitle)
                    .bold()
            }
    }
}
struct CustomGroupBoxStyle: GroupBoxStyle {
    var color: Color

    func makeBody(configuration: Configuration) -> some View {
    configuration.content
        .padding()
        .background(color)
        .cornerRadius(10)
    }
}
