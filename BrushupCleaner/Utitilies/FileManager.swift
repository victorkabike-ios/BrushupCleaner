//
//  FileManager.swift
//  BrushupCleaner
//
//  Created by victor kabike on 2023/07/08.
//

import Foundation
import UIKit

func getStorageInfo() -> (usedCapacity: Double, totalCapacity: Double, usedPercentage: Double)? {
    let fileURL = URL(fileURLWithPath: NSHomeDirectory() as String)
    do {
        let values = try fileURL.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey, .volumeTotalCapacityKey])
        if let availableCapacity = values.volumeAvailableCapacityForImportantUsage,
           let totalCapacity = values.volumeTotalCapacity {
            let usedCapacity = Double(totalCapacity - Int(availableCapacity))
            let usedPercentage = usedCapacity / Double(totalCapacity) * 100
            return (usedCapacity, Double(totalCapacity), usedPercentage)
        } else {
            print("Capacity is unavailable")
            return nil
        }
    } catch {
        print("Error retrieving capacity: \(error.localizedDescription)")
        return nil
    }
}
