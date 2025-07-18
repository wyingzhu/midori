import SwiftUI

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
            ScrollView {
                VStack(spacing: 20) {
                    // MARK: - Account Summary
                    GroupBox(label: Label("Accounts", systemImage: "arrow.left.arrow.right")
                                .font(.headline)) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("From: \(card.institution)")
                            Text("Balance: $\(card.balance, specifier: "%.2f")")
                            
                            if let target = store.cards.first(where: { $0.id == selectedTargetCardID }) {
                                Divider().padding(.vertical, 4)
                                Text("To: \(target.institution)")
                                Text("Balance: $\(target.balance, specifier: "%.2f")")
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 6)
                    }

                    // MARK: - Select Target
                    GroupBox(label: Label("Transfer To", systemImage: "arrowshape.turn.up.right")
                                .font(.headline)) {
                        Picker("Target Card", selection: $selectedTargetCardID) {
                            ForEach(targetCards) { card in
                                Text(card.institution).tag(card.id as UUID?)
                            }
                        }
                        .pickerStyle(.menu)
                        .padding(.horizontal)
                    }

                    // MARK: - Transfer Details
                    GroupBox(label: Label("Transfer Details", systemImage: "pencil")
                                .font(.headline)) {
                        VStack(spacing: 12) {
                            TextField("Amount", text: $transferAmount)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(.roundedBorder)

                            TextField("Note (optional)", text: $transferNote)
                                .textFieldStyle(.roundedBorder)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }

                    // MARK: - Transfer Button
                    Button(action: {
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
                    }) {
                        Text("Transfer")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isTransferAmountValid && selectedTargetCardID != nil ? Color.accentColor : Color.gray.opacity(0.3))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .disabled(!isTransferAmountValid || selectedTargetCardID == nil)

                    Spacer(minLength: 20)
                }
                .padding()
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

#Preview {
    let sampleCard = Card(
        institution: "Chase",
        balance: 1200.0,
        last4Digits: "1234",
        accountType: .debit
    )

    let targetCard = Card(
        institution: "Bank of America",
        balance: 800.0,
        last4Digits: "5678",
        accountType: .debit
    )
    
    let thirdCard = Card(
        institution: "Capital One",
        balance: 500.0,
        last4Digits: "9012",
        accountType: .debit
    )

    let store = CardStore()
    store.cards = [sampleCard, targetCard, thirdCard]

    return TransferSheetView(
        card: .constant(store.cards[0]),
        store: store,
        transferAmount: .constant("100"),
        transferNote: .constant("Rent"),
        selectedTargetCardID: .constant(store.cards[1].id),
        isPresented: .constant(true)
    )
}
