//
//  CardStore.swift
//  Midori
//
//  Created by Wanying Zhu on 7/15/25.
//

import Foundation

class CardStore: ObservableObject {
    @Published var cards: [Card] = [] {
        didSet {
            CardDataService.shared.save(cards: cards)
        }
    }

    init() {
        self.cards = CardDataService.shared.load()
    }

    func add(_ card: Card) {
        cards.append(card)
    }

    func delete(at offsets: IndexSet) {
        cards.remove(atOffsets: offsets)
    }

    func update(_ card: Card) {
        if let index = cards.firstIndex(where: { $0.id == card.id }) {
            cards[index] = card
        }
    }
}
