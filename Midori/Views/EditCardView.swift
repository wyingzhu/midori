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
        ScrollView {
            VStack(spacing: 24) {
                // MARK: Card Balance
                VStack(alignment: .leading) {
                    Text("$\(card.balance, specifier: "%.2f")")
                        .font(.largeTitle)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .bold()
                    Text("Total balance")
                        .font(.caption)
                }
                .padding()
                
                // MARK: Card Info
                GroupBox(label: Text("Card Info")) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            TextField("Institution", text: $card.institution)
                                .textFieldStyle(.roundedBorder)
                            Picker("Account Type", selection: $card.accountType) {
                                ForEach(AccountType.allCases) { type in
                                    Text(type.displayName).tag(type)
                                }
                            }
                        }
                        TextField("Last 4 Digits", text: $card.last4Digits)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                    }
                    .padding(.vertical, 4)
                }

                // MARK: Actions
                GroupBox(label: Text("Actions")) {
                    HStack(spacing: 12) {
                        Button {
                            showIncomeSheet = true
                        } label: {
                            VStack {
                                Image(systemName: "plus.rectangle.on.rectangle")
                                Text("Deposit")
                            }
                        }
                        .padding(.horizontal, 12)
                        
                        Divider()
                        
                        Button {
                            showExpenseSheet = true
                        } label: {
                            VStack {
                                Image(systemName: "creditcard.fill")
                                Text("Spend")
                            }
                        }
                        .padding(.horizontal, 12)
                        
                        Divider()
                        
                        Button {
                            showTransferSheet = true
                        } label: {
                            VStack {
                                Image(systemName: "arrow.left.arrow.right")
                                Text("Transfer")
                            }
                        }
                        .padding(.horizontal, 12)
                    }
                }

                // MARK: Transaction History
                GroupBox(label: Text("Recent Transactions")){
                    TransactionHistoryView(transactions: card.transactions)
                }
            }
            .padding()
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
            IncomeSheetView(
                incomeAmount: $incomeAmount,
                incomeNote: $incomeNote,
                card: $card,
                isPresented: $showIncomeSheet
            )
        }
        .sheet(isPresented: $showExpenseSheet) {
            ExpenseSheetView(
                expenseAmount: $expenseAmount,
                expenseNote: $expenseNote,
                card: $card,
                isPresented: $showExpenseSheet
            )
        }
        .sheet(isPresented: $showTransferSheet) {
            TransferSheetView(
                card: $card,
                store: store,
                transferAmount: $transferAmount,
                transferNote: $transferNote,
                selectedTargetCardID: $selectedTargetCardID,
                isPresented: $showTransferSheet
            )
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
