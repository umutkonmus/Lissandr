//
//  WatchlistStore.swift
//  Lissandr
//
//  Created by Umut Konmuş on 24.10.2025.
//

import Foundation

final class WatchlistStore {
    static let shared = WatchlistStore()
    private init() {}
    private let key = "watchlist.items.v1"

    func load() -> [WatchItem] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        return (try? JSONDecoder().decode([WatchItem].self, from: data)) ?? []
    }

    func save(_ items: [WatchItem]) {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func add(_ item: WatchItem) {
        var items = load()
        if !items.contains(item) { items.append(item); save(items) }
    }

    func remove(gameID: String) {
        var items = load()
        items.removeAll { $0.gameID == gameID }
        save(items)
    }
}
