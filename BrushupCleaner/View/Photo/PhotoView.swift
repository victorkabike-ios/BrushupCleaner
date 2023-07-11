//
//  PhotoView.swift
//  BrushupCleaner
//
//  Created by victor kabike on 2023/07/08.
//

import Photos
import SwiftUI
import ScrollKit

struct PhotoView: View {
    let headerHeight: CGFloat
    @State
       private var headerVisibleRatio: CGFloat = 1
       
    @State
        private var scrollOffset: CGPoint = .zero
    @EnvironmentObject var photoViewModel: PhotoviewModel
    @EnvironmentObject var userModel: UserViewModel
    @Environment(\.dismiss) var dismiss
    @State var totalPhoto = 0
    @State var totalLivePhoto = 0
    @State var screenshotPhoto = 0
    @State var totalPhotoSize: Double = 0
    @State var totalLivePhotoSize: Double = 0
    @State var screenshotPhotoSize: Double = 0
    @Binding  var showPaywall: Bool
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top){
                Color("backgroundColor")
                    .opacity(0.6)
                    .edgesIgnoringSafeArea(.all)
                ScrollViewWithStickyHeader(
                            header: header,
                            headerHeight: 120,
                            onScroll: handleScrollOffset(_:headerVisibleRatio:)
                ) {
                    LazyVStack{
                        NavigationLink {
                            SimilarPhotoView(headerHeight: 120, photos: photoViewModel.photoCategories, totalPhoto: $totalPhoto, totalSize: $totalPhotoSize, showPaywall: $showPaywall)
                                .background(Color("backgroundColor")
                                    .opacity(0.3)
                                    .edgesIgnoringSafeArea(.all))
                                .environmentObject(photoViewModel)
                                .environmentObject(userModel)
                                .navigationBarBackButtonHidden(true)
                                .onAppear{
                                    photoViewModel.fetchAndCategorizePhotos()
                                }
                        } label: {
                            if let firstPhoto = photoViewModel.photoCategories.first {
                                PhotoCellView(title: "Photos", amount:totalPhoto , icon: "photo.fill", photo: firstPhoto)
                                    .onAppear{
                                        totalPhoto = photoViewModel.photoCategories.reduce(0) { result, category in
                                            result + category.count
                                        }
                                        calculateTotalDataSize(photoCategories: photoViewModel.photoCategories) { totalDataSize  in
                                            totalPhotoSize = totalDataSize
                                        }
                                    }
                            }
                        }
                        NavigationLink {
                            SimilarPhotoView(headerHeight: 120, photos: photoViewModel.livePhotoCategories, totalPhoto: $totalLivePhoto, totalSize: $totalLivePhotoSize, showPaywall: $showPaywall)
                                .background(Color("backgroundColor")
                                    .opacity(0.3)
                                    .edgesIgnoringSafeArea(.all))
                                .environmentObject(photoViewModel)
                                .environmentObject(userModel)
                                .navigationBarBackButtonHidden(true)
                                .onAppear{
                                    photoViewModel.fetchAndCategorizeLivePhotos()
                                }
                        } label: {
                            if let firstPhoto = photoViewModel.livePhotoCategories.first {
                                PhotoCellView(title: "Live Photos", amount: totalLivePhoto, icon: "livephoto", photo: firstPhoto)
                                    .onAppear{
                                        totalLivePhoto = photoViewModel.livePhotoCategories.reduce(0) { result, category in
                                            result + category.count
                                        }
                                        calculateTotalDataSize(photoCategories: photoViewModel.livePhotoCategories) { totalDataSize  in
                                            totalLivePhotoSize = totalDataSize
                                        }
                                    }
                            }
                        }
                        NavigationLink {
                            SimilarPhotoView(headerHeight: 120, photos: photoViewModel.ScreenshotCategories, totalPhoto: $screenshotPhoto, totalSize: $screenshotPhotoSize, showPaywall: $showPaywall)
                                .background(Color("backgroundColor")
                                    .opacity(0.3)
                                    .edgesIgnoringSafeArea(.all))
                                .environmentObject(photoViewModel)
                                .environmentObject(userModel)
                                .navigationBarBackButtonHidden(true)
                                .onAppear{
                                    photoViewModel.fetchAndCategorizeScreenshotPhotos()
                                }
                        } label: {
                            if let firstPhoto = photoViewModel.ScreenshotCategories.first{
                                PhotoCellView(title: "Screenshots", amount: screenshotPhoto, icon: "square.dashed.inset.fill", photo: firstPhoto)
                                    .onAppear{
                                        screenshotPhoto = photoViewModel.ScreenshotCategories.reduce(0) { result, category in
                                            result + category.count
                                        }
                                        calculateTotalDataSize(photoCategories: photoViewModel.ScreenshotCategories) { totalDataSize  in
                                            screenshotPhotoSize = totalDataSize
                                        }
                                    }
                            }
                        }
                    }
                    .padding()
                }
                .toolbarBackground(.hidden)
                .statusBarHidden(scrollOffset.y > -3)
                .toolbarColorScheme(.dark, for: .navigationBar)
                
            }
            
        }
    }
    func header() -> some View {
            ZStack(alignment: .bottomLeading) {
                ScrollViewHeaderGradient()
                headerTitle.previewHeaderContent()
            }
        }
    var headerTitle: some View {
            VStack(alignment: .leading) {
                HStack{
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                        .font(.subheadline)
                        .padding(8)
                        .background(Color("groupBackgroundColor"))
                        .clipShape(RoundedRectangle(cornerRadius: 13))
                        .onTapGesture {
                            dismiss()
                        }
                    Spacer()
                    Image(systemName: "sparkles")
                         .font(.headline)
                         .padding(8)
                         .background(Color.blue)
                         .clipShape(Circle())
                }
                .padding(.vertical,18)
                .padding(.horizontal)
                VStack(alignment: .leading){
                    let total = totalPhoto + totalLivePhoto + screenshotPhoto
                    let totalSize = totalPhotoSize + totalLivePhotoSize + screenshotPhotoSize
                    Text("Clean up Photos").font(.largeTitle)
                    Text("\(total) Photos . \(totalSize , specifier: "%.2f") MB of Storage to free up")
                        .foregroundColor(.white)
                        .fontWeight(.thin)
                        .font(.subheadline)
                }.padding(.horizontal)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("backgroundColor"))
            .edgesIgnoringSafeArea(.all)
            .opacity(headerVisibleRatio)
       }
    func handleScrollOffset(_ offset: CGPoint, headerVisibleRatio: CGFloat) {
            self.scrollOffset = offset
            self.headerVisibleRatio = headerVisibleRatio
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

struct PhotoCellView: View {
    let title:String
    let amount: Int
    let icon: String
    let photo: [PhotoModel]
    var body: some View {
        VStack{
            HStack{
                VStack(alignment: .leading) {
                    HStack{
                        Image(systemName: icon)
                            .font(.headline)
                            .bold()
                            .padding(8)
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .clipShape(Circle())
                        VStack(alignment: .leading){
                            Text("Similar \(title)")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("\(amount) \(title)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top)
                        
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.blue)
                    .clipShape(Circle())
            }
            .background(Color("backgroundColor").opacity(0.5))
            .zIndex(1)
            LazyHGrid(rows: [GridItem(.fixed(160))]) {
                ForEach(photo.prefix(2), id: \.id) { photo in
                        Image(uiImage: photo.image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipped()
                        .frame(width: 160,height: 160)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                   

            }
            .padding(.bottom)
        }
        .padding(.horizontal)
        .background(Color("backgroundColor").opacity(0.6))
        .cornerRadius(18)
        
    }
}

 extension View {
    
    func previewHeaderContent() -> some View {
        self.foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
//            .shadow(color: Color("backgroundColor"), radius: 1, x: 1, y: 1)
//            .background(Color("backgroundColor")
//                .edgesIgnoringSafeArea(.all))
            
    }
}
