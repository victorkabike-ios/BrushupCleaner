//
//  PhotoViewModel.swift
//  BrushupCleaner
//
//  Created by victor kabike on 2023/07/08.
//

import Foundation
//
//  PhotoLibraryViewModel.swift
//  Storagebrush
//
//  Created by victor kabike on 2023/06/04.
//

import SwiftUI
import Photos
import Vision

class PhotoviewModel: ObservableObject {
    var allPhotos: [PhotoModel] = []
    var allPhotosSize:[Int] = []
    @Published var photoCategories: [[PhotoModel]] = []
    @Published var livePhotoCategories: [[PhotoModel]] = []
    @Published var ScreenshotCategories: [[PhotoModel]] = []
    @Published var selectedPhotos: [PhotoModel] = []
    @Published var isFetching = false
    @Published var progress = 0.0
    @Published var showCongratsView = false
    @Published var similarPhotosCount = 0
    @Published var bestPhotos: [PhotoModel] = []
    @Published var selectedPhotoCount = 0
    @Published var selectedPhotosSize: Int = 0
    @Published var similarPhotosize = 0
    
    @Published var deletedPhotosCount: Int = 0
    @Published var deletedPhotosSize: Int = 0
    
    private let classificationCache = NSCache<UIImage, NSString>()
    private let imageManager = PHCachingImageManager()
    
    func fetchAndCategorizeScreenshotPhotos() {
        isFetching = true
        DispatchQueue.global(qos: .userInitiated).async {
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            fetchOptions.predicate = NSPredicate(
                    format: "(mediaSubtype & %d) != 0",
                    PHAssetMediaSubtype.photoScreenshot.rawValue
                )
            fetchOptions.fetchLimit = 500
            let allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
            
            var categories: [String: [PhotoModel]] = [:]
            
            let targetSize = CGSize(width: 224, height: 224)
            let options = PHImageRequestOptions()
            options.isSynchronous = false
            options.deliveryMode = .highQualityFormat
            options.resizeMode = .none
            
            let dispatchGroup = DispatchGroup()
            let semaphore = DispatchSemaphore(value: 5) // Limit concurrent image requests
            
            allPhotos.enumerateObjects { (asset, count, stop) in
                autoreleasepool {
                    dispatchGroup.enter()
                    semaphore.wait()
                    
                    self.imageManager.requestImage(for: asset,
                                                   targetSize: targetSize,
                                                   contentMode: .aspectFill,
                                                   options: options) { (image, info) in
                        defer {
                            dispatchGroup.leave()
                            semaphore.signal()
                        }
                        if let image = image {
                            let photo = PhotoModel(image: image, asset: asset)
                            self.allPhotos.append(photo)
                        }
                        
                        guard let image = image else { return }
                        let photo = PhotoModel(image: image, asset: asset)
                        if let cachedCategory = self.classificationCache.object(forKey: image) {
                            let category = cachedCategory as String
                            if categories[category] == nil {
                                categories[category] = []
                            }
                            categories[category]?.append(photo)
                        } else if let category = PhotoUtilities.category(for: image) {
                            self.classificationCache.setObject(category as NSString, forKey: image)
                            if categories[category] == nil {
                                categories[category] = []
                            }
                            categories[category]?.append(photo)
                        }
                        
                        DispatchQueue.main.async {
                            self.progress = Double(count + 1) / Double(allPhotos.count)
                        }
                    }
                        self.imageManager.requestImageDataAndOrientation(for: asset, options: options) { data, _, _, _ in
                            if let data = data{
                                self.allPhotosSize.append(data.count)
                            }
                        }
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                self.ScreenshotCategories =   self.processFetchedPhotos(categories: categories)
            }
        }
    }
    func fetchAndCategorizeLivePhotos() {
        isFetching = true
        DispatchQueue.global(qos: .userInitiated).async {
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            fetchOptions.predicate = NSPredicate(
                    format: "(mediaSubtype & %d) != 0",
                    PHAssetMediaSubtype.photoLive.rawValue
                )
            fetchOptions.fetchLimit = 500
            let allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
            
            var categories: [String: [PhotoModel]] = [:]
            
            let targetSize = CGSize(width: 224, height: 224)
            let options = PHImageRequestOptions()
            options.isSynchronous = false
            options.deliveryMode = .highQualityFormat
            options.resizeMode = .none
            
            let dispatchGroup = DispatchGroup()
            let semaphore = DispatchSemaphore(value: 5) // Limit concurrent image requests
            
            allPhotos.enumerateObjects { (asset, count, stop) in
                autoreleasepool {
                    dispatchGroup.enter()
                    semaphore.wait()
                    
                    self.imageManager.requestImage(for: asset,
                                                   targetSize: targetSize,
                                                   contentMode: .aspectFill,
                                                   options: options) { (image, info) in
                        defer {
                            dispatchGroup.leave()
                            semaphore.signal()
                        }
                        if let image = image {
                            let photo = PhotoModel(image: image, asset: asset)
                            self.allPhotos.append(photo)
                        }
                        
                        guard let image = image else { return }
                        let photo = PhotoModel(image: image, asset: asset)
                        if let cachedCategory = self.classificationCache.object(forKey: image) {
                            let category = cachedCategory as String
                            if categories[category] == nil {
                                categories[category] = []
                            }
                            categories[category]?.append(photo)
                        } else if let category = PhotoUtilities.category(for: image) {
                            self.classificationCache.setObject(category as NSString, forKey: image)
                            if categories[category] == nil {
                                categories[category] = []
                            }
                            categories[category]?.append(photo)
                        }
                        
                        DispatchQueue.main.async {
                            self.progress = Double(count + 1) / Double(allPhotos.count)
                        }
                    }
                        self.imageManager.requestImageDataAndOrientation(for: asset, options: options) { data, _, _, _ in
                            if let data = data{
                                self.allPhotosSize.append(data.count)
                            }
                        }
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                self.livePhotoCategories =  self.processFetchedPhotos(categories: categories)
            }
        }
        isFetching = false
    }

    func fetchAndCategorizePhotos(){
        isFetching = true
        DispatchQueue.global(qos: .userInitiated).async {
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            fetchOptions.predicate = NSPredicate(
                    format: "NOT ( ( (mediaSubtype & %d) != 0) || ( (mediaSubtype & %d) != 0) || (burstIdentifier != nil))",
                    PHAssetMediaSubtype.photoLive.rawValue,
                    PHAssetMediaSubtype.photoScreenshot.rawValue
                )
            fetchOptions.fetchLimit = 500
            let allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
            
            var categories: [String: [PhotoModel]] = [:]
            
            let targetSize = CGSize(width: 224, height: 224)
            let options = PHImageRequestOptions()
            options.isSynchronous = false
            options.deliveryMode = .highQualityFormat
            options.resizeMode = .none
            
            let dispatchGroup = DispatchGroup()
            let semaphore = DispatchSemaphore(value: 5) // Limit concurrent image requests
            
            allPhotos.enumerateObjects { (asset, count, stop) in
                autoreleasepool {
                    dispatchGroup.enter()
                    semaphore.wait()
                    
                    self.imageManager.requestImage(for: asset,
                                                   targetSize: targetSize,
                                                   contentMode: .aspectFill,
                                                   options: options) { (image, info) in
                        defer {
                            dispatchGroup.leave()
                            semaphore.signal()
                        }
                        if let image = image {
                            let photo = PhotoModel(image: image, asset: asset)
                            self.allPhotos.append(photo)
                        }
                        
                        guard let image = image else { return }
                        let photo = PhotoModel(image: image, asset: asset)
                        if let cachedCategory = self.classificationCache.object(forKey: image) {
                            let category = cachedCategory as String
                            if categories[category] == nil {
                                categories[category] = []
                            }
                            categories[category]?.append(photo)
                        } else if let category = PhotoUtilities.category(for: image) {
                            self.classificationCache.setObject(category as NSString, forKey: image)
                            if categories[category] == nil {
                                categories[category] = []
                            }
                            categories[category]?.append(photo)
                        }
                        
                        DispatchQueue.main.async {
                            self.progress = Double(count + 1) / Double(allPhotos.count)
                        }
                    }
                        self.imageManager.requestImageDataAndOrientation(for: asset, options: options) { data, _, _, _ in
                            if let data = data{
                                self.allPhotosSize.append(data.count)
                            }
                        }
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                self.photoCategories =  self.processFetchedPhotos(categories: categories)
            }
        }
    }


    func processFetchedPhotos(categories: [String: [PhotoModel]]) -> [[PhotoModel]] {
        var fetchedCategory = [[PhotoModel]]()
        let dispatchGroup = DispatchGroup()
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .none

        fetchedCategory = Array(categories.values.filter { $0.count >= 2 })
        self.similarPhotosCount = fetchedCategory.reduce(0) { $0 + $1.count }
        self.bestPhotos = fetchedCategory.map({ category in
            category.first!
        })
        for category in fetchedCategory {
            for photo in category {
                dispatchGroup.enter()
                self.imageManager.requestImageDataAndOrientation(for: photo.asset, options: options) { data, _, _, _ in
                    if let data = data {
                        self.similarPhotosize += data.count
                    }
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.isFetching = false
        }
return fetchedCategory
    }


    func selectPhoto(_ photo:PhotoModel) {
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        if let index = selectedPhotos.firstIndex(of: photo) {
            selectedPhotos.remove(at: index)
            selectedPhotoCount = selectedPhotos.count
            // Update the size of the selected photos here
            self.imageManager.requestImageDataAndOrientation(for: photo.asset, options: options) { data, _, _, _ in
                if let data = data{
                    self.selectedPhotosSize -= data.count
                }
            }
//            if let index = allPhotos.firstIndex(of: photo),
//               index < allPhotosSize.count {
//                selectedPhotosSize -= allPhotosSize[index]
//            }
        } else {
            // Only add the photo to the selectedPhotos array if it is not already present
            if !selectedPhotos.contains(photo) {
                selectedPhotos.append(photo)
                selectedPhotoCount = selectedPhotos.count
                // Update the size of the selected photos here
                self.imageManager.requestImageDataAndOrientation(for: photo.asset, options: options) { data, _, _, _ in
                    if let data = data{
                        self.selectedPhotosSize += data.count
                    }
                }
//                if let index = allPhotos.firstIndex(of: photo),
//                   index < allPhotosSize.count {
//                    selectedPhotosSize += allPhotosSize[index]
//                }
            }
        }
    }

    func deleteSelectedPhotosFromLibrary() {
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                PHPhotoLibrary.shared().performChanges({
                    let assetsToDelete = self.selectedPhotos.map { $0.asset }
                    PHAssetChangeRequest.deleteAssets(assetsToDelete as NSArray)
                }, completionHandler: { success, error in
                    if success {
                        print("Successfully deleted selected photos")
                        DispatchQueue.main.async {
                            self.selectedPhotos.removeAll()
                            self.similarPhotosCount -= self.selectedPhotoCount
                            // Remove the selected photos from the photoCategories array
                            for (categoryIndex, category) in self.photoCategories.enumerated() {
                                self.photoCategories[categoryIndex] = category.filter { !self.selectedPhotos.contains($0) }
                            }
                            self.showCongratsView = true
                        }
                    } else if let error = error {
                        print("Error deleting selected photos: \(error)")
                    } else {
                        print("Unknown error occurred")
                    }
                })
            } else {
                print("Permission to access photo library not granted")
            }
        }
    }







}
