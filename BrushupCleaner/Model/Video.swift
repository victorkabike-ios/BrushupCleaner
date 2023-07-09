//
//  Video.swift
//  BrushupCleaner
//
//  Created by victor kabike on 2023/07/08.
//

import Foundation
import SwiftUI
import Photos
import AVKit

struct Video: Identifiable {
    let id: String
    let asset: PHAsset
    let size: Int64
    let duration: TimeInterval
    let url: URL
}
