//
//  Transaction.swift
//  Midori
//
//  Created by Wanying Zhu on 7/16/25.
//
import Foundation

struct Transaction: Identifiable, Codable {
    let id: UUID
    let date: Date
    let amount: Double
    let note: String
    let type: TransactionType
}

enum TransactionType: String, Codable {
    case income
    case expense
    case transferIn
    case transferOut

    var label: String {
        switch self {
        case .income: return "Income"
        case .expense: return "Expense"
        case .transferIn: return "Transfer In"
        case .transferOut: return "Transfer Out"
        }
    }
}
