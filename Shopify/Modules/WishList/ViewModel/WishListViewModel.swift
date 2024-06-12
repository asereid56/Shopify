//
//  WishListViewModel.swift
//  Shopify
//
//  Created by Mina on 11/06/2024.
//

import Foundation
class WishListViewModel {
    var items: [Item]?
    init() {
        items = [
            Item(photo: "forth", id: 10),
            Item(photo: "forth", id: 20),
            Item(photo: "forth", id: 30),
            Item(photo: "forth", id: 40)
        ]
    }
    func getItems() -> [Item] {
        items ?? [Item]()
    }
}
