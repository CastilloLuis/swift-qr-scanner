//
//  Utils.swift
//  qr-code-scanner
//
//  Created by Luis Castillo on 3/13/23.
//

import Foundation

struct FavoritesQR: Codable, Hashable {
    var id = UUID()
    let title: String
    let link: String
}

let DEFAULT_URL = "https://google.com"

func parseFavorites(from: String) -> [FavoritesQR] {
    if (from == "[]") { return [] }
    do {
        let json = from.data(using: .utf8)!
        let parsed = try JSONDecoder().decode([FavoritesQR].self, from: json)
        return parsed
    } catch {
        print("Error while decoding: ", error)
        return []
    }
}

func stringifyFavorites(favorites: [FavoritesQR]) -> String {
    do {
        let jsonData = try JSONEncoder().encode(favorites)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        return jsonString
    } catch {
        print("Error while stringify", error)
        return "[]"
    }
}
