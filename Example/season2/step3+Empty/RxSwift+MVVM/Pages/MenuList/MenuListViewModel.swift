//
//  MenuListViewModel.swift
//  RxSwift+MVVM
//
//  Created by mac on 2022/01/31.
//  Copyright © 2022 iamchiwon. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class MenuListViewModel {
    var menuObservable = BehaviorRelay<[Menu]>(value: [])
    
    lazy var itemsCount = menuObservable.map {
        $0.map { $0.count }.reduce(0, +)
    }
    
    lazy var totalPrice = menuObservable.map {
        $0.map { $0.price * $0.count }.reduce(0, +)
    }
    
    init() {
        _ = APIService.fetchAllMenusRx()
            .map { data -> [MenuItem] in
                struct Response: Decodable {
                    let menus: [MenuItem]
                }
                
                let response = try! JSONDecoder().decode(Response.self, from: data)
                return response.menus
            }.map { menuItems -> [Menu] in
                var menus: [Menu] = []
                menuItems.enumerated().forEach { index, item in
                    let menu = Menu.fromMenuItems(id: index, item: item)
                    menus.append(menu)
                }
                return menus
            }.take(1)
            .bind(to: menuObservable)
    }
    
    func clearAllItemSelections() {
        _ = menuObservable.map { menus in
            return menus.map { menu in
                Menu(id: menu.id, name: menu.name, price: menu.price, count: 0)
            }
        }
        .take(1)
        .subscribe(onNext: {
            self.menuObservable.accept($0)
        })
    }
    
    func changeCount(item: Menu, increase: Int) {
        _ = menuObservable.map { menus in
            return menus.map { menu in
                if menu.name == item.name {
                    return Menu(id: item.id, name: menu.name, price: menu.price, count: max(menu.count+increase, 0))
                } else {
                    return Menu(id: item.id, name: menu.name, price: menu.price, count: menu.count)
                }
            }
        }
        .take(1)
        .subscribe(onNext: {
            self.menuObservable.accept ($0)
        })
    }
}
