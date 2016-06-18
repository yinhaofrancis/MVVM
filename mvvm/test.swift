//
//  test.swift
//  mvvm
//
//  Created by YinHao on 16/6/15.
//  Copyright © 2016年 Suzhou Qier Network Technology Co., Ltd. All rights reserved.
//

import UIKit
import CoreData
class test: ViewModule {
    var name = property<String>(v: "")
    var sd = property<Bool>(v: true)
    var insert = command()
    var query = command()
    var update = command()
    var delete = command()
    override init() {
        super.init()
        let k = CoreDataProvide.shareInstace()
        insert.action {(sender) in
            k.insert(["name":"yinhao","password":"123123","createdAt":NSDate(),"updatedAt":NSDate()], type: "User")
        }
        var user:User?
        query.action { (sender) in
            k.query("User", condition: nil, result: { (data) in
                user = data![0] as? User
                print(user?.name)
            })
        }
        update.action { (sender) in
            user?.name = "尹豪"
            user?.update(k)
        }
        delete.action { (sender) in
            k.count("User", condition: nil, Count: { (n) in
                print(n)
            })
        }
        
    }
    @objc func clean(){
        name ^= ""
    }
}
