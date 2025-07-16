//
//  AddCardView.swift
//  Midori
//
//  Created by Wanying Zhu on 7/15/25.
//

import SwiftUI

struct AddCardView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var store: CardStore

    @State private var institution = ""
    @State private var balance = ""
    @State private var last4Digits = ""
    @State private var accountType: AccountType = .credit
    
    var isLast4Valid: Bool {
        last4Digits.trimmingCharacters(in: .whitespaces).count == 4 &&
        last4Digits.allSatisfy { $0.isNumber }
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Card Info")) {
                    TextField("Institution", text: $institution)
                    TextField("Balance", text: $balance)
                        .keyboardType(.decimalPad)
                    TextField("Last 4 digits", text: $last4Digits)
                        .keyboardType(.numberPad)
                    Picker("Account Type", selection: $accountType) {
                        ForEach(AccountType.allCases) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                }

                Button("Save") {
                    if let amount = Double(balance) {
                        let card = Card(
                            institution: institution,
                            balance: amount,
                            last4Digits: last4Digits,
                            accountType: accountType
                        )
                        store.add(card)
                        dismiss()
                    }
                }
                .disabled(institution.isEmpty || balance.isEmpty || !isLast4Valid)
                .opacity(institution.isEmpty || balance.isEmpty || !isLast4Valid ? 0.5 : 1)
            }
            .navigationTitle("Add card")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
