//
//  CardView.swift
//  Midori
//
//  Created by Wanying Zhu on 7/15/25.
//

import SwiftUI

struct CardView: View {
    let card: Card

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(card.institution)
                    .font(.title2).bold()
                Text("(\(card.last4Digits))")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
                Text(card.accountType.displayName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Text("$\(card.balance, specifier: "%.2f")")
                .font(.headline)
                .foregroundColor(card.balance >= 0 ? .green : .red)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
}
