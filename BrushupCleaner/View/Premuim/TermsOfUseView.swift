//
//  TermsOfUseView.swift
//  BrushupCleaner
//
//  Created by victor kabike on 2023/07/08.
//

import Foundation
import SwiftUI

struct TermsOfUseView: View {
    @Environment(\.dismiss) var dismissAction
    var body: some View {
        NavigationStack{
            ZStack{
                Color("backgroundColor")
                    .opacity(0.6)
                    .edgesIgnoringSafeArea(.all)
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        VStack(alignment: .leading, spacing: 15){
                            
                            Text("Please read these Terms of Use (\"Terms\") carefully before using Brush Storage Cleaner (\"the App\"). By using the App, you agree to be bound by these Terms.")
                            
                            Text("1. Access to User Data: In order to provide its services, the App requires access to your photos, contacts, and videos. This access is necessary for the proper functioning of the App.")
                            
                            Text("2. No Uploads: We do not upload any user photos to our servers. Your data remains on your device.")
                            
                            Text("3. No Account Creation: The App does not offer the option to create an account. You can use the App without providing any personal information.")
                            
                            Text("4. In-App Purchases: The App offers in-app purchase subscriptions. These purchases are subject to the terms and conditions set by the respective app store.")
                        }
                        VStack(alignment: .leading, spacing: 15){
                            Text("5. Data Privacy: We value your privacy and are committed to protecting your personal information. Any data collected by the App will only be used to optimize its performance. We will not sell or share your personal information with third parties without your consent.")
                            
                            Text("6. User Responsibility: You are solely responsible for the content and data you choose to store on your device using the App. We are not liable for any loss or damage to your data.")
                            
                            Text("7. Prohibited Activities: You agree not to use the App for any illegal or unauthorized purposes. This includes, but is not limited to, uploading or sharing copyrighted material, engaging in fraudulent activities, or violating any applicable laws or regulations.")
                            
                            Text("8. Intellectual Property: All intellectual property rights related to the App, including trademarks, logos, and software, are owned by the App or its licensors. You agree not to reproduce, modify, or distribute any copyrighted material without prior written consent.")
                            
                            Text("9. Limitation of Liability: The App is provided \"as is\" without any warranties or guarantees. We are not responsible for any damages or losses resulting from the use or inability to use the App.")
                            
                            Text("10. Indemnification: You agree to indemnify and hold the App harmless from any claims, damages, or liabilities arising out of your use of the App or any violation of these Terms.")
                            Text("11. Modification of Terms: The App reserves the right to modify or update these Terms at any time. It is your responsibility to review these Terms periodically for any changes.")
                            Text("12. Governing Law: These Terms shall be governed by and construed in accordance with the laws of the jurisdiction in which the App operates.")
                        }
                        
                    }.padding(.horizontal)
                }
            }
            .navigationTitle("Terms of Use")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismissAction()
                    }) {
                        Text("Agree")
                    }
                }
            }

        }
    }
    
}
