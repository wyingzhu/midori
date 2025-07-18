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
                                Text("Income")
                            }
                        }
                        .padding(.horizontal, 12)
                        
                        Divider()
                        
                        Button {
                            showExpenseSheet = true
                        } label: {
                            VStack {
                                Image(systemName: "creditcard.fill")
                                Text("Expense")
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
