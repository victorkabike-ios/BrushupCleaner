//
//  UserViewModel.swift
//  BrushupCleaner
//
//  Created by victor kabike on 2023/07/08.
//

import Foundation
import RevenueCat
import SwiftUI

/* Static shared model for UserView */
class UserViewModel: ObservableObject {
    static let shared = UserViewModel()
    @Published var subscriptionActive: Bool = false
    init() {
        // Using Completion Blocks
        Purchases.shared.getCustomerInfo { (customerInfo, error) in
            // access latest customerInfo
                self.subscriptionActive = customerInfo?.entitlements.all[Constants.entitlementID]?.isActive == true
        }
    }
    @Published var customerInfo: CustomerInfo? {
        didSet {
            subscriptionActive = customerInfo?.entitlements[Constants.entitlementID]?.isActive == true
        }
    }
  
    func login(userId: String) async {
        _ = try? await Purchases.shared.logIn(userId)
    }
    
    func logout() async {
        _ = try? await Purchases.shared.logOut()
    }
}
