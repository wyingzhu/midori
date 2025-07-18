import SwiftUI

struct ExpenseSheetView: View {
    @Binding var expenseAmount: String
    @Binding var expenseNote: String
    @Binding var card: Card
    @Binding var isPresented: Bool
    
    var isAmountInvalid: Bool {
        guard let amount = Double(expenseAmount) else { return true }
        return amount <= 0
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // MARK: - Input Fields
                GroupBox(label: Label("Add Expense", systemImage: "minus.circle")
                            .font(.headline)) {
                    VStack(spacing: 12) {
                        TextField("Amount", text: $expenseAmount)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)

                        TextField("Note (optional)", text: $expenseNote)
                            .textFieldStyle(.roundedBorder)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }

                // MARK: - Add Button
                Button(action: {
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
                }) {
                    Text("Add Expense")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .disabled(isAmountInvalid)

                Spacer()
            }
            .padding()
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


#Preview {
    ExpenseSheetView(
        expenseAmount: .constant("-1"),
        expenseNote: .constant("Test Note"),
        card: .constant(
            Card(
                institution: "Demo Bank",
                balance: 1200.00,
                last4Digits: "1234",
                accountType: .debit
            )
        ),
        isPresented: .constant(true)
    )
}
