//
//  TransferSheetView.swift
//  Midori
//
//  Created by Wanying Zhu on 7/18/25.
//

import SwiftUI

struct TransferSheetView: View {
    @Binding var card: Card
    var store: CardStore
    @Binding var transferAmount: String
    @Binding var transferNote: String
    @Binding var selectedTargetCardID: UUID?
    @Binding var isPresented: Bool

    var targetCards: [Card] {
        store.cards.filter { $0.id != card.id }
    }

    var isTransferAmountValid: Bool {
        if let amount = Double(transferAmount) {
            return amount > 0 && amount <= card.balance
        }
        return false
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Accounts")) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("From: \(card.institution)")
                        Text("Balance: $\(card.balance, specifier: "%.2f")")
                            .foregroundColor(card.balance >= 0 ? .green : .red)
                    }
                    if let target = store.cards.first(where: { $0.id == selectedTargetCardID }) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("To: \(target.institution)")
                            Text("Balance: $\(target.balance, specifier: "%.2f")")
                                .foregroundColor(target.balance >= 0 ? .green : .red)
                        }
                    }
                }

                Section(header: Text("Transfer To")) {
                    Picker("Target Card", selection: $selectedTargetCardID) {
                        ForEach(targetCards) { targetCard in
                            Text(targetCard.institution)
                                .tag(targetCard.id as UUID?)
                        }
                    }
                }
                Section(header: Text("Transfer Details")) {
                    TextField("Amount", text: $transferAmount)
                        .keyboardType(.decimalPad)
                    TextField("Note (optional)", text: $transferNote)
                }
                Section {
                    Button("Transfer") {
                        if let amount = Double(transferAmount),
                           let targetID = selectedTargetCardID,
                           let index = store.cards.firstIndex(where: { $0.id == targetID }) {
                            
                            let outTxn = Transaction(
                                id: UUID(),
                                date: Date(),
                                amount: amount,
                                note: transferNote,
                                type: .transferOut
                            )
                            card.balance -= amount
                            card.transactions.insert(outTxn, at: 0)

                            let inTxn = Transaction(
                                id: UUID(),
                                date: Date(),
                                amount: amount,
                                note: transferNote,
                                type: .transferIn
                            )
                            store.cards[index].balance += amount
                            store.cards[index].transactions.insert(inTxn, at: 0)
                            transferAmount = ""
                            transferNote = ""
                            isPresented = false
                        }
                    }
                    .disabled(!isTransferAmountValid || selectedTargetCardID == nil)
                }
            }
            .navigationTitle("Transfer Funds")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
}
