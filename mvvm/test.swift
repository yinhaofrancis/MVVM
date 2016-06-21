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
        let h = http()
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
            h.get("http://www.baidu.com", params: [:], handle: { (data, response, error) in
                print(response?.statusCode)
            }).async()
            h.get("https://www.qq.com", params: [:], handle: { (data, response, error) in
                print(response?.statusCode)
            }).sync(10, complete: { (success) in
                print("success",success)
            })
            
        }
        delete.action { (sender) in
            h.get("http://www.baidu.com", params: [:], handle: { (data, response, error) in
                print(response?.statusCode)
            }).async()
        }
        
    }
    @objc func clean(){
        name ^= ""
    }
}
