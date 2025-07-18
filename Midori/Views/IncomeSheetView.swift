//
//  IncomeSheetView.swift
//  Midori
//
//  Created by Wanying Zhu on 7/18/25.
//
import SwiftUI

struct IncomeSheetView: View {
    @Binding var incomeAmount: String
    @Binding var incomeNote: String
    @Binding var card: Card
    @Binding var isPresented: Bool

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Add Income")) {
                    TextField("Amount", text: $incomeAmount)
                        .keyboardType(.decimalPad)
                    TextField("Note (optional)", text: $incomeNote)
                }
                Section {
                    Button("Add") {
                        if let amount = Double(incomeAmount) {
                            let txn = Transaction(
                                id: UUID(),
                                date: Date(),
                                amount: amount,
                                note: incomeNote,
                                type: .income
                            )
                            card.balance += amount
                            card.transactions.insert(txn, at: 0)
                            incomeAmount = ""
                            incomeNote = ""
                            isPresented = false
                        }
                    }
                    .disabled(Double(incomeAmount) == nil)
                }
            }
            .navigationTitle("New Income")
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
