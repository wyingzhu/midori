//
//  Card.swift
//  Midori
//
//  Created by Wanying Zhu on 7/15/25.
//

import Foundation

enum AccountType: String, Codable, CaseIterable, Identifiable {
    case credit
    case debit
    case cash
    case rewards
    case investment
    case loan
    case other

    var id: String { self.rawValue }

    var displayName: String {
        switch self {
        case .credit: return "Credit"
        case .debit: return "Debit"
        case .cash: return "Cash"
        case .rewards: return "Rewards"
        case .investment: return "Investment"
        case .loan: return "Loan"
        case .other: return "Other"
        }
    }
}


struct Card: Identifiable, Codable {
    let id: UUID
    var institution: String
    var balance: Double
    var last4Digits: String
    var accountType: AccountType
    
    init(institution: String, balance: Double, last4Digits: String, accountType: AccountType) {
        self.id = UUID()
        self.institution = institution
        self.balance = balance
        self.last4Digits = last4Digits
        self.accountType = accountType
    }
}
