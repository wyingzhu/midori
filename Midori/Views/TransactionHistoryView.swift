import SwiftUI

struct TransactionHistoryView: View {
    let transactions: [Transaction]

    var body: some View {
        VStack(alignment: .leading) {
            if transactions.isEmpty {
                Text("No transactions yet.")
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(transactions.prefix(20)) { txn in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(txn.type.label)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)

                                    if !txn.note.isEmpty {
                                        Text(txn.note)
                                            .font(.body)
                                    }
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("$\(txn.amount, specifier: "%.2f")")
                                    Text(txn.date, style: .date)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.horizontal)
                            Divider()
                        }
                    }
                }
                .frame(height: 250) // Customize scrollable height
                .background(Color.clear)
            }
        }
        .padding(.bottom)
        .background(Color.clear)
    }
}
