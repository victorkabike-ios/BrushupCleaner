//
//  AuthorizationUtitilies.swift
//  BrushupCleaner
//
//  Created by victor kabike on 2023/07/08.
//

import Foundation
import Photos
import Contacts
import EventKit

class AuthorizationUtilities {
    static func requestPhotoPermission(completion: @escaping (Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    completion(true)
                default:
                    completion(false)
                }
            }
        }
    }

    static func requestContactPermission(completion: @escaping (Bool) -> Void) {
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { granted, error in
            if let error = error {
                print("Error requesting contact permission: \(error.localizedDescription)")
            }
            completion(granted)
        }
    }

    static func requestCalendarPermission(completion: @escaping (Bool) -> Void) {
        let eventStore = EKEventStore()
        eventStore.requestAccess(to: .event) { granted, error in
            if let error = error {
                print("Error requesting calendar permission: \(error.localizedDescription)")
            }
            completion(granted)
        }
    }
}
