//
//  CardDataService.swift
//  Midori
//
//  Created by Wanying Zhu on 7/15/25.
//

import Foundation

class CardDataService {
    static let shared = CardDataService()

    private let filename = "cards.json"

    private var fileURL: URL {
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first!
        return url.appendingPathComponent(filename)
    }

    func save(cards: [Card]) {
        do {
            let data = try JSONEncoder().encode(cards)
            try data.write(to: fileURL)
        } catch {
            print("Error saving data: \(error.localizedDescription)")
        }
    }

    func load() -> [Card] {
        do {
            let data = try Data(contentsOf: fileURL)
            let cards = try JSONDecoder().decode([Card].self, from: data)
            return cards
        } catch {
            print("Failed to load or file doesn't exist: \(error.localizedDescription)")
            return []
        }
    }
}
