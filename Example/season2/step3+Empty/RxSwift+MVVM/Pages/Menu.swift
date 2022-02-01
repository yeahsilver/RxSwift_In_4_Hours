//
//  Menu.swift
//  RxSwift+MVVM
//
//  Created by mac on 2022/01/31.
//  Copyright © 2022 iamchiwon. All rights reserved.
//

import Foundation

// View Model
struct Menu {
    var id: Int
    var name: String
    var price: Int
    var count: Int
}

extension Menu {
    static func fromMenuItems(id: Int, item: MenuItem) -> Menu {
        return Menu(id: id, name: item.name, price: item.price, count: 0)
    }
}
