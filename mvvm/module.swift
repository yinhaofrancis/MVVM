//
//  module.swift
//  mvvm
//
//  Created by YinHao on 16/6/16.
//  Copyright © 2016年 Suzhou Qier Network Technology Co., Ltd. All rights reserved.
//

import Foundation
public protocol pmodule {
    func setjson(json:[String:AnyObject])
    func getjson() -> [String : AnyObject]
}
public  class module: NSObject,pmodule {
    public func setjson(json: [String : AnyObject]) {
        for i in json{
            self.setValue(i.1, forKey: i.0)
        }
    }
    public func getjson() -> [String : AnyObject] {
        print("you should implement func getjson() -> [String : AnyObject]")
        return [:]
    }
}
