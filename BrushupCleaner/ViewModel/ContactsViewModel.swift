//
//  ContactsViewModel.swift
//  BrushupCleaner
//
//  Created by victor kabike on 2023/07/08.
//



import SwiftUI
import Contacts

struct Contact: Identifiable {
    let id = UUID()
 var name: String
    var phoneNumbers: [String]
    var emailAddresses: [String]

    mutating func merge(_ contact: Contact) {
        if !contact.name.isEmpty {
            name = contact.name
        }
        phoneNumbers.append(contentsOf: contact.phoneNumbers.filter { !phoneNumbers.contains($0) })
        emailAddresses.append(contentsOf: contact.emailAddresses.filter { !emailAddresses.contains($0) })
    }
}



class ContactViewModel: ObservableObject {
    var contacts: [Contact] = []
    @Published var duplicateContacts: [String: [Contact]] = [:]
    private let similarityThreshold: Double = 0.85
    @Published var progress = 0.0
    
    func requestContactPermission(completion: @escaping (Bool) -> Void) {
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { granted, error in
            if let error = error {
                print("Error requesting contact permission: \(error.localizedDescription)")
            }
            completion(granted)
        }
    }

    func normalize(_ string: String) -> String {
        return string.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func jaroWinklerSimilarity(_ string1: String, _ string2: String) -> Double {
        let jaroDistance = jaroSimilarity(string1, string2)
        let commonPrefixLength = commonPrefix(string1, string2).count
        let scalingFactor = 0.1

        return jaroDistance + Double(commonPrefixLength) * scalingFactor * (1 - jaroDistance)
    }

    func jaroSimilarity(_ string1: String, _ string2: String) -> Double {
        let string1Length = string1.count
        let string2Length = string2.count

        if string1Length == 0 || string2Length == 0 {
            return 0
        }

        let matchDistance = max(string1Length, string2Length) / 2 - 1
        var string1Matches = Array(repeating: false, count: string1Length)
        var string2Matches = Array(repeating: false, count: string2Length)

        var matches = 0
        var transpositions = 0

        for i in 0..<string1Length {
            let start = max(0, i - matchDistance)
            let end = min(string2Length - 1, i + matchDistance)

            if start <= end {
                for j in start...end {
                    if string2Matches[j] {
                        continue
                    }
                    if string1[i] != string2[j] {
                        continue
                    }
                    string1Matches[i] = true
                    string2Matches[j] = true
                    matches += 1
                    break
                }
            }
        }

        if matches == 0 {
            return 0
        }

        var k = 0
        for i in 0..<string1Length {
            if !string1Matches[i] {
                continue
            }
            while !string2Matches[k] {
                k += 1
            }
            if string1[i] != string2[k] {
                transpositions += 1
            }
            k += 1
        }

        let matchesDouble = Double(matches)
        return (matchesDouble / Double(string1Length) + matchesDouble / Double(string2Length) + (matchesDouble - Double(transpositions / 2)) / matchesDouble) / 3
    }

    func commonPrefix(_ string1: String, _ string2: String) -> String {
        let minLength = min(string1.count, string2.count)
        var result = ""

        for i in 0..<minLength {
            if string1[i] == string2[i] {
                result.append(string1[i])
            } else {
                break
            }
        }

        return result
    }
    func saveMergedContact(_ contact: Contact) {
            // Add the merged contact to the contacts array
            contacts.append(contact)
        }

        func deleteDuplicateContacts(_ contactsToDelete: [Contact]) {
            // Remove the duplicate contacts from the contacts array
            for contact in contactsToDelete {
                if let index = contacts.firstIndex(where: { $0.id == contact.id }) {
                    contacts.remove(at: index)
                }
            }
            // Remove the duplicate contacts from the duplicateContacts dictionary
            let key = contactsToDelete[0].name
            if var duplicates = duplicateContacts[key] {
                for contact in contactsToDelete {
                    if let index = duplicates.firstIndex(where: { $0.id == contact.id }) {
                        duplicates.remove(at: index)
                    }
                }
                if duplicates.isEmpty {
                    duplicateContacts.removeValue(forKey: key)
                } else {
                    duplicateContacts[key] = duplicates
                }
            }
        }

 


    func isSimilar(_ string1: String, _ string2: String) -> Bool {
        return jaroWinklerSimilarity(normalize(string1), normalize(string2)) >= similarityThreshold
    }

    func fetchContacts() {
        progress = 0
        let store = CNContactStore()
        let keysToFetch = [
            CNContactGivenNameKey,
            CNContactFamilyNameKey,
            CNContactPhoneNumbersKey,
            CNContactEmailAddressesKey
        ] as [CNKeyDescriptor]
        let request = CNContactFetchRequest(keysToFetch: keysToFetch)

        var allContacts: [Contact] = []

        DispatchQueue.global(qos: .background).async {
            do {
                try store.enumerateContacts(with: request) { (contact, _) in
                    let name = "\(contact.givenName) \(contact.familyName)"
                    let phoneNumbers = contact.phoneNumbers.map { $0.value.stringValue }
                    let emailAddresses = contact.emailAddresses.map { $0.value as String }
                    let newContact = Contact(name: name, phoneNumbers: phoneNumbers, emailAddresses: emailAddresses)
                    allContacts.append(newContact)
                }
                DispatchQueue.main.async {
                    self.progress = 0.5
                    for contact in allContacts {
                        var foundDuplicate = false
                        for (key, contacts) in self.duplicateContacts {
                            if self.isSimilar(key, contact.name) {
                                self.duplicateContacts[key]?.append(contact)
                                foundDuplicate = true
                                break
                            }
                        }
                        if !foundDuplicate {
                            self.duplicateContacts[contact.name] = [contact]
                        }
                    }
                    self.duplicateContacts = self.duplicateContacts.filter { $1.count > 1 }
                    self.progress = 1
                }
            } catch {
                print("Error fetching contacts: \(error)")
            }
        }

    }
}

extension String {
    subscript(i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
}
