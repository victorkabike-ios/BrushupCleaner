//
//  PhotoModel.swift
//  BrushupCleaner
//
//  Created by victor kabike on 2023/07/08.
//

import SwiftUI
import CoreLocation
import UIKit
import Photos

struct PhotoModel: Identifiable , Equatable,Hashable {
    let id = UUID()
    let image: UIImage
    let asset: PHAsset
    var category: String?
    
    static func == (lhs: PhotoModel, rhs: PhotoModel) -> Bool {
           return lhs.id == rhs.id
       }
    func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
}



