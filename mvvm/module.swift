//
//  module.swift
//  mvvm
//
//  Created by YinHao on 16/6/16.
//  Copyright © 2016年 Suzhou Qier Network Technology Co., Ltd. All rights reserved.
//

import Foundation
@objc public protocol jsonmodule {
    func setjson(json: [String : AnyObject])
    optional func getjson()-> [String : AnyObject]
}
@objc public protocol modifimodule{
    optional func update(provide:dataProvide)
    optional func del(provide:dataProvide)
    optional static func insert(json:[String : AnyObject],provide:dataProvide)
}
@objc public protocol loadmodule{
    optional func load(provide:dataProvide)
    @objc optional static func load(provide:dataProvide,condition:Condition?,data:(([jsonmodule]?)->Void))
}
@objc public protocol dataProvide{
    optional func query(name:String,condition:Condition?,data:([jsonmodule]?)->Void)
    optional func insert(m:[String:AnyObject],type:String)
    optional func update(m:jsonmodule,type:String)
    optional func updateCondition(condtion:Condition?,type:String)
    optional func delCondition(condition:Condition?,type:String)
    optional func del(m:jsonmodule,type:String)
    optional func count(type:String,condition:Condition?,Count:(NSNumber?)->Void)
    optional func save()
}
public  class module: NSObject,jsonmodule,modifimodule,loadmodule {
    public required override init() {
        super.init()
    }
    
    public func setjson(json: [String : AnyObject]) {
        for i in json{
            self.setValue(i.1, forKey: i.0)
        }
    }
    public class func getSimplejson(m:module) -> [String : AnyObject] {
        var c:Mirror? = Mirror(reflecting: m)
        var result:[String:AnyObject] = [:]
        repeat{
            for i in c!.children{
                if let s = m.valueForKey(i.label!){
                    if s.getjson != nil{
                        result[i.label!] = s.getjson!()
                    }else{
                        result[i.label!] = s
                    }
                }
            }
            c = c!.superclassMirror()
        }while (c != nil)
        return result
    }
    public func getjson()-> [String : AnyObject]{
        return [:]
    }
}
public class Condition:NSObject{
    init(page:Int?,limit:Int?,compare:(key:String,op:String,value:String)?) {
        super.init()
        self.page = page
        self.limit = limit
        self.compare = compare
    }
    var page:Int?
    var limit:Int?
    var compare:(key:String,op:String,value:String)?
}
func  + <T,Y>(a:[T:Y],b:[T:Y])->[T:Y]{
    var result = a
    for i in b{
        result[i.0] = i.1
    }
    return result
}