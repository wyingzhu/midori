//
//  CardListView.swift
//  Midori
//
//  Created by Wanying Zhu on 7/15/25.
//

import SwiftUI

struct CardListView: View {
    @StateObject private var store = CardStore()
    @State private var showingAddCard = false
    @State private var showDeleteAlert = false
    @State private var deleteIndexSet: IndexSet?
    @State private var selectedCard: Card?
    @State private var selectedAccountType: AccountType? = nil
    
    var filteredCards: [Card] {
        if let type = selectedAccountType {
            return store.cards.filter { $0.accountType == type }
        } else {
            return store.cards
        }
    }
    
    var availableAccountTypes: [AccountType] {
        let types = store.cards.map { $0.accountType }
        return Array(Set(types)).sorted { $0.displayName < $1.displayName }
    }

    var body: some View {
        NavigationView {
            VStack {
                if store.cards.isEmpty {
                    Text("Nothing to display")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        ForEach(filteredCards) { card in
                            CardView(card: card)
                                .listRowInsets(EdgeInsets())
                                .listRowSeparator(.hidden)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(Color.clear)
                                .onTapGesture {
                                    selectedCard = card
                                }
                        }
                        .onDelete { indexSet in
                            self.deleteIndexSet = indexSet
                            self.showDeleteAlert = true
                        }
                    }
                    .listStyle(PlainListStyle())
                    .alert("Delete Card", isPresented: $showDeleteAlert, actions: {
                        Button("Delete", role: .destructive) {
                            if let indexSet = deleteIndexSet {
                                store.delete(at: indexSet)
                            }
                        }
                        Button("Cancel", role: .cancel) { }
                    }, message: {
                        Text("This action cannot be undone.")
                    })
                }
                Spacer()
            }
            .navigationTitle("My Accounts")
            .fullScreenCover(item: $selectedCard) { card in
                NavigationView {
                    EditCardView(card: card, store: store)
                }
            }
            .toolbar {
                Menu {
                    Picker(selection: $selectedAccountType, label: EmptyView()) {
                        Text("All").tag(AccountType?.none)
                        ForEach(availableAccountTypes, id: \.self) { type in
                            Text(type.displayName).tag(Optional(type))
                        }
                    }
                } label: {
                    Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                }
                
                Button {
                    showingAddCard = true
                } label: {
                    Label("Add Card", systemImage: "plus")
                }
            }
            .sheet(isPresented: $showingAddCard) {
                AddCardView(store: store)
            }
        }
    }
}
