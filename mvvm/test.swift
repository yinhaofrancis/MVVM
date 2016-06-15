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
    var a = "a"
    override init() {
        super.init()
        cli.action {(sender) in
            print("haha")
        }
        NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: #selector(clean), userInfo: nil, repeats: true)
    }
    @objc func clean(){
        name ^= ""
    }
}
