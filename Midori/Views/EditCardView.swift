//
//  EditCardView.swift
//  Midori
//
//  Created by Wanying Zhu on 7/15/25.
//

import SwiftUI

struct EditCardView: View {
    @Environment(\.dismiss) var dismiss
    @State var card: Card
    @ObservedObject var store: CardStore
    @State private var showIncomeSheet = false
    @State private var showExpenseSheet = false
    @State private var showTransferSheet = false
    @State private var incomeAmount = ""
    @State private var incomeNote = ""
    @State private var expenseAmount = ""
    @State private var expenseNote = ""
    @State private var transferAmount = ""
    @State private var transferNote = ""
    @State private var selectedTargetCardID: UUID?

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
        Form {
            Section(header: Text("Card Info")) {
                TextField("Institution", text: $card.institution)
                Picker("Account Type", selection: $card.accountType) {
                    ForEach(AccountType.allCases) { type in
                        Text(type.displayName).tag(type)
                    }
                }
                TextField("Last 4 Digits", text: $card.last4Digits)
                    .keyboardType(.numberPad)
                Text("Balance: $\(card.balance, specifier: "%.2f")")
                    .foregroundColor(card.balance >= 0 ? .green : .red)
            }

            Section(header: Text("Actions")) {
                Button(action: {
                    showIncomeSheet = true
                }) {
                    Text("Add Income")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .listRowSeparator(.hidden)
                .buttonStyle(BorderedProminentButtonStyle())

                Button(action: {
                    showExpenseSheet = true
                }) {
                    Text("Add Expense")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .listRowSeparator(.hidden)
                .buttonStyle(BorderedProminentButtonStyle())

                Button(action: {
                    showTransferSheet = true
                }) {
                    Text("Transfer")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .listRowSeparator(.hidden)
                .buttonStyle(BorderedProminentButtonStyle())
            }
        }
        .navigationTitle("Edit Card")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    store.update(card)
                    dismiss()
                }
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $showIncomeSheet) {
            IncomeSheetView(incomeAmount: $incomeAmount, incomeNote: $incomeNote, card: $card, isPresented: $showIncomeSheet)
        }
        .sheet(isPresented: $showExpenseSheet) {
            ExpenseSheetView(expenseAmount: $expenseAmount, expenseNote: $expenseNote, card: $card, isPresented: $showExpenseSheet)
        }
        .sheet(isPresented: $showTransferSheet) {
            TransferSheetView(card: $card, store: store, transferAmount: $transferAmount, transferNote: $transferNote, selectedTargetCardID: $selectedTargetCardID, isPresented: $showTransferSheet)
        }
    }
}

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
                            card.balance += amount
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
                            card.balance -= amount
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
                            card.balance -= amount
                            store.cards[index].balance += amount
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
