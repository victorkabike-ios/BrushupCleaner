//
//  DuplicateContacts.swift
//  BrushupCleaner
//
//  Created by victor kabike on 2023/07/08.
//

import SwiftUI
import Contacts

struct DuplicateContactsView: View {
    @ObservedObject var viewModel = ContactViewModel()

    var body: some View {
        NavigationView {
            List {
                ForEach(Array(viewModel.duplicateContacts.keys), id: \.self) { key in
                    Section(header: Text(key)) {
                        ForEach(viewModel.duplicateContacts[key]!) { contact in
                            ContactRow(contact: contact)
                        }
                        Button(action: {
                            let mergedContact = mergeContacts(viewModel.duplicateContacts[key]!)
                            viewModel.saveMergedContact(mergedContact)
                            viewModel.deleteDuplicateContacts(viewModel.duplicateContacts[key]!)
                        }) {
                            Text("Merge")
                        }

                    }
                }
            }
            .navigationBarTitle("Duplicate Contacts")
            .onAppear {
                viewModel.fetchContacts()
            }
        }
    }

    func mergeContacts(_ contacts: [Contact]) -> Contact {
        var mergedContact = contacts[0]
        for i in 1..<contacts.count {
            mergedContact.merge(contacts[i])
        }
        return mergedContact
    }

}

struct ContactRow: View {
    let contact: Contact

    var body: some View {
        VStack(alignment: .leading) {
            Text(contact.name)
                .font(.headline)
            if !contact.phoneNumbers.isEmpty {
                Text(contact.phoneNumbers[0])
                    .font(.subheadline)
            }
            if !contact.emailAddresses.isEmpty {
                Text(contact.emailAddresses[0])
                    .font(.subheadline)
            }
        }
    }
}
