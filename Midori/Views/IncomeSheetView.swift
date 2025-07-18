import SwiftUI

struct IncomeSheetView: View {
    @Binding var incomeAmount: String
    @Binding var incomeNote: String
    @Binding var card: Card
    @Binding var isPresented: Bool
    
    var isAmountInvalid: Bool {
        guard let amount = Double(incomeAmount) else { return true }
        return amount <= 0
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // MARK: - Input Fields
                GroupBox(label: Label("Add Income", systemImage: "plus.circle")
                            .font(.headline)) {
                    VStack(spacing: 12) {
                        TextField("Amount", text: $incomeAmount)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)

                        TextField("Note (optional)", text: $incomeNote)
                            .textFieldStyle(.roundedBorder)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }

                // MARK: - Add Button
                Button(action: {
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
                }) {
                    Text("Add Income")
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



#Preview {
    IncomeSheetView(
        incomeAmount: .constant("0"),
        incomeNote: .constant("Test Note"),
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
