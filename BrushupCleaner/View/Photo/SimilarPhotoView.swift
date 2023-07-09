//
//  SimilarPhotoView.swift
//  BrushupCleaner
//
//  Created by victor kabike on 2023/07/08.
//

import SwiftUI
import Photos
import ConfettiSwiftUI

struct SimilarPhotoView: View {
    @EnvironmentObject var photoViewModel: PhotoviewModel
    @Environment(\.dismiss) var dismissAction
    var photos: [[PhotoModel]]
    @State private var showCongratsView = false
    @Binding var totalPhoto:Int
    @Binding var totalSize: Double
    @State var selectedTotalSize: Double = 0
    @EnvironmentObject var  userModel: UserViewModel
    @State var showPaywall:Bool = false
    var body: some View {
        NavigationStack{
            ZStack(alignment: .top){
                Color("backgroundColor")
                    .opacity(0.6)
                    .edgesIgnoringSafeArea(.all)
                HStack{
                    VStack(alignment: .leading, spacing: 5) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                            .font(.subheadline)
                            .padding(8)
                            .background(Color("groupBackgroundColor"))
                            .clipShape(RoundedRectangle(cornerRadius: 13))
                            .onTapGesture {
                                dismissAction()
                            }
                        Text("Similar Photos").font(.title)
                        Text("\(totalPhoto) Photos . \(totalSize , specifier: "%.2f") MB of Storage to free up")
                            .foregroundColor(.white)
                            .fontWeight(.thin)
                            .font(.subheadline)
                    }
                    .padding(.top, 40)
                    .padding(.horizontal)
                    .padding(.vertical)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .background(Color("backgroundColor"))
                .edgesIgnoringSafeArea(.all)
                .zIndex(1)
                ScrollView {
                    LazyVStack{
                        ForEach(photos, id: \.self) { category in
                            Section {
                                ScrollView(.horizontal) {
                                    LazyHStack {
                                        ForEach(category, id: \.id) { photo in
                                            SimilarPhotoTumbnailView(photo: photo, photoViewModel: photoViewModel)
                                        }

                                    }
                                }
                            } header:{
                                HStack{
                                    Text("Similar")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color.white)
                                    Spacer()
                                    // Add a "Select All" button to select all photos in the category that are not the best
                                    Button(action: {
                                        let nonBestPhotos = category.filter { !photoViewModel.bestPhotos.contains($0) }
                                        photoViewModel.selectedPhotos.append(contentsOf: nonBestPhotos)
                                    }) {
                                        Text("Select All")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                    }
                                }.padding(.trailing)
                            }
                        }
                    }.padding(.leading)
                }
                
                VStack {

                    Button(action: {
                        if userModel.subscriptionActive{
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.success)
                            photoViewModel.deleteSelectedPhotosFromLibrary()
                        } else{
                            showPaywall = true
                        }
                       
                    })  {
                        HStack {
                            Text("Delete \(photoViewModel.selectedPhotoCount) Similar Photos")
                                .fontWeight(.semibold)
                            Text("(\(selectedTotalSize, specifier: "%.2f") MB)")
                                .fontWeight(.bold)
                        }
                        .frame(width: 360, height: 75)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(18)
                        .animation(.easeInOut(duration: 0.5))
                        .onChange(of: photoViewModel.selectedPhotos) { total in
                            let totalSelectedSize = calculateTotalDataSize(photoModels: photoViewModel.selectedPhotos) { totalSize in
                                selectedTotalSize = totalSize
                            }
                        }
                    }
                    .padding()
                    .disabled(photoViewModel.selectedPhotos.isEmpty)
                   

                }
                .frame(maxHeight: .infinity, alignment: .bottom)
            }
            .fullScreenCover(isPresented: $showPaywall, content: {
                PaywallView()
            })
            .sheet(isPresented: $photoViewModel.showCongratsView) {
                CongratsView(size: Double(photoViewModel.selectedPhotosSize) / (1024 * 1024), count: photoViewModel.selectedPhotos.count)
                   }
            
        }
    }
    func calculateTotalDataSize(photoModels: [PhotoModel], completion: @escaping (Double) -> Void) {
        var totalDataSize: Int = 0
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.deliveryMode = .highQualityFormat

        let imageManager = PHImageManager.default()

        let group = DispatchGroup() // Create a dispatch group

        for photo in photoModels {
            group.enter() // Enter the dispatch group

            imageManager.requestImageData(for: photo.asset, options: options) { (data, _, _, _) in
                if let size = data?.count {
                    totalDataSize += size
                }
                group.leave() // Leave the dispatch group
            }
        }

        group.notify(queue: .main) {
            let totalDataSizeInMB = Double(totalDataSize) / (1024 * 1024)
            completion(totalDataSizeInMB)
        }
    }

}
struct SimilarPhotoTumbnailView: View {
    let photo: PhotoModel
    @ObservedObject var photoViewModel: PhotoviewModel
    
    var body: some View {
        ZStack(alignment: .bottomLeading){
            Image(uiImage: photo.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .clipped()
                .frame(width: 180,height: 180)
                .clipShape(RoundedRectangle(cornerRadius: 18))
            HStack{
                // Add a badge to indicate the best photo in each category
                if photoViewModel.bestPhotos.contains(photo) {
                    HStack{
                        Image(systemName: "checkmark.seal.fill")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        Text("Best Photo")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                    }
                        .frame(width: 100, height: 30)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                Spacer()
                Button(action: {photoViewModel.selectPhoto(photo)}) {
                    if photoViewModel.selectedPhotos.contains(photo){
                        ZStack{
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.blue)
                            Image(systemName: "checkmark")
                                .foregroundColor( Color.white)
                                .font(.caption)
                                .bold()
                        }.frame(width: 25, height: 25)
                    }else{
                        ZStack{
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(lineWidth: 2)
                                .foregroundColor(.white)
                        }.frame(width: 25, height: 25)
                    }
                  
                }.padding(6)
            }.padding(.horizontal, 8)
        }
        .padding(4)
    }
}
struct CongratsView: View {
    let size: Double
    let count: Int
    @State private var counter: Int = 8
    @Environment(\.dismiss) var dismissAction
    var body: some View {
        ZStack {
            Color("backgroundColor")
                .opacity(0.6)
                .edgesIgnoringSafeArea(.all)
            VStack(alignment: .center, spacing: 18) {
                Spacer()
                Text("🎉")
                    .font(.system(size: 100))
                    .confettiCannon(counter: $counter, rainHeight: 1000.0, radius: 500, repetitions: 3, repetitionInterval: 0.7)
                
                Text("Congratulations!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("The selected photos have been moved to the Recently Deleted album on your iPhone.")
                    .font(.headline)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Text("This action frees up \(String(format: "%.2f", size)) MB of storage.")
                    .font(.headline)
                    .foregroundColor(.blue)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.vertical)
                    .background(
                           RoundedRectangle(cornerRadius: 10)
                               .fill(Color.blue.opacity(0.2))
                       )
                       .overlay(
                           RoundedRectangle(cornerRadius: 10)
                               .stroke(Color.blue, lineWidth: 2)
                       )
                
                Spacer()
                
                Button(action: { dismissAction() }) {
                    Text("Awesome")
                        .font(.title3)
                        .bold()
                        .foregroundColor(.white)
                        .frame(width: 380, height: 70)
                        .background(Color.blue)
                        .cornerRadius(30)
                }
            }
        }
        .onAppear {
            counter = 4
        }

    }
}
