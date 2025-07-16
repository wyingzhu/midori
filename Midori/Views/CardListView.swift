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

    var body: some View {
        NavigationView {
            VStack {
                if store.cards.isEmpty {
                    Text("Nothing to display")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        ForEach(store.cards) { card in
                            CardView(card: card)
                                .listRowInsets(EdgeInsets())       // 移除默认 padding
                                .listRowSeparator(.hidden)
                                .padding(.vertical, 8)             // 上下留白
                                .padding(.horizontal, 16)          // 左右留白
                                .background(Color.clear)           // 透明背景
                                .onTapGesture {
                                    selectedCard = card
                                }
                        }
                        .onDelete { indexSet in
                            self.deleteIndexSet = indexSet
                            self.showDeleteAlert = true
                        }
                    }
                    .listStyle(PlainListStyle())                   // 纯净列表风格
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
                Button {
                    showingAddCard = true
                } label: {
                    Label("Add account", systemImage: "plus")
                }
            }
            .sheet(isPresented: $showingAddCard) {
                AddCardView(store: store)
            }
        }
    }
}
