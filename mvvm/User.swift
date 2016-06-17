//
//  User.swift
//  mvvm
//
//  Created by YinHao on 16/6/17.
//  Copyright © 2016年 Suzhou Qier Network Technology Co., Ltd. All rights reserved.
//

import Foundation
import CoreData


class User: NSManagedObject {
//    static func load(provide: dataProvide, condition: Condition?) -> [User]? {
//        let q = provide.query!("User", condition: condition)
//        return q as? [User]
//    }
    static func insert(json: [String : AnyObject], provide: dataProvide) {
        provide.insert!(json, type: "User")
    }
    func update(provide: dataProvide) {
        provide.save!()
    }
    func del(provide: dataProvide) {
        provide.del!(self, type: "User")
    }
    override func getjson() -> [String : AnyObject] {
        return User.getSimplejson(self)
    }
}
