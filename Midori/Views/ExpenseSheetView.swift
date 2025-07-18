//
//  ExpenseSheetView.swift
//  Midori
//
//  Created by Wanying Zhu on 7/18/25.
//

import SwiftUI

struct ExpenseSheetView: View {
    @Binding var expenseAmount: String
    @Binding var expenseNote: String
    @Binding var card: Card
    @Binding var isPresented: Bool

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Add Expense")) {
                    TextField("Amount", text: $expenseAmount)
                        .keyboardType(.decimalPad)
                    TextField("Note (optional)", text: $expenseNote)
                }
                Section {
                    Button("Add") {
                        if let amount = Double(expenseAmount) {
                            let txn = Transaction(
                                id: UUID(),
                                date: Date(),
                                amount: amount,
                                note: expenseNote,
                                type: .expense
                            )
                            card.balance -= amount
                            card.transactions.insert(txn, at: 0)
                            expenseAmount = ""
                            expenseNote = ""
                            isPresented = false
                        }
                    }
                    .disabled(Double(expenseAmount) == nil)
                }
            }
            .navigationTitle("New Expense")
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
