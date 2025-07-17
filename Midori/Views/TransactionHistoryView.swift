//
//  TransactionHistoryView.swift
//  Midori
//
//  Created by Wanying Zhu on 7/16/25.
//

import SwiftUI

struct TransactionHistoryView: View {
    let transactions: [Transaction]

    var body: some View {
        VStack(alignment: .leading) {
            Text("Recent Transactions")
                .font(.headline)

            if transactions.isEmpty {
                Text("No transactions yet.")
                    .foregroundColor(.secondary)
            } else {
                ForEach(transactions.prefix(10)) { txn in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(txn.type.label)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            if !txn.note.isEmpty {
                                Text(txn.note)
                            }
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("\(txn.amount, specifier: "%.2f")")
                                .foregroundColor({
                                    switch txn.type {
                                    case .income:
                                        return .green
                                    case .expense:
                                        return .red
                                    case .transferIn, .transferOut:
                                        return .primary // or .black if you prefer
                                    }
                                }())
                            Text(txn.date, style: .date)
                                .font(.caption)
                        }
                    }
                }
            }
        }
        .padding()
    }
}

