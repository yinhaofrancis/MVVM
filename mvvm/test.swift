//
//  test.swift
//  mvvm
//
//  Created by YinHao on 16/6/15.
//  Copyright © 2016年 Suzhou Qier Network Technology Co., Ltd. All rights reserved.
//

import UIKit

class test: ViewModule {
    var name = property<String>(v: "")
    var sd = property<Bool>(v: true)
    var cli = command()
    var cli2 = command()
    
    override init() {
        super.init()
        let t = timer(timerinteval: 1)

        cli.action {[unowned self](sender) in
            print("haha")
            var k = 0
            _ = try? t.run {
                print("timer:\(k)")
                k += 1
                if k == 10{
                    self.name ^= ""
                    k = 0
                }
            }
        }
        cli2.action { (sender) in
            var k = user()
            k.name  = "Francis"
            k.age = 24
            k.phoneNum = "13915411914"
            print(user.getjson(k))
            
        }
        
    }
    @objc func clean(){
        name ^= ""
    }
}
class user:module{
    var name:String?
    var age:UInt?
    var phoneNum:String?
}
