import SwiftUI

struct AddCardView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var store: CardStore

    @State private var institution = ""
    @State private var balance = ""
    @State private var last4Digits = ""
    @State private var accountType: AccountType = .credit

    var isLast4Valid: Bool {
        last4Digits.trimmingCharacters(in: .whitespaces).count == 4 &&
        last4Digits.allSatisfy { $0.isNumber }
    }

    var isFormValid: Bool {
        !institution.isEmpty &&
        Double(balance) != nil &&
        isLast4Valid
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - Card Info Inputs
                    GroupBox(label: Label("Card Info", systemImage: "creditcard")
                        .font(.headline)) {
                        VStack(spacing: 12) {
                            HStack{
                                TextField("Institution", text: $institution)
                                    .textFieldStyle(.roundedBorder)
                                
                                Picker("Account Type", selection: $accountType) {
                                    ForEach(AccountType.allCases) { type in
                                        Text(type.displayName).tag(type)
                                    }
                                }
                                .pickerStyle(.menu)
                            }
                            TextField("Balance", text: $balance)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(.roundedBorder)

                            VStack(alignment: .leading, spacing: 4) {
                                TextField("Last 4 digits", text: $last4Digits)
                                    .keyboardType(.numberPad)
                                    .textFieldStyle(.roundedBorder)

                                if !isLast4Valid && !last4Digits.isEmpty {
                                    Text("Enter exactly 4 digits")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }

                    // MARK: - Save Button
                    Button(action: {
                        if let amount = Double(balance) {
                            let card = Card(
                                institution: institution,
                                balance: amount,
                                last4Digits: last4Digits,
                                accountType: accountType
                            )
                            store.add(card)
                            dismiss()
                        }
                    }) {
                        Text("Save")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isFormValid ? Color.accentColor : Color.gray.opacity(0.4))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .disabled(!isFormValid)

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Add Card")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
