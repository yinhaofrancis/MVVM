//
//  ViewModule.swift
//  mvvm
//
//  Created by YinHao on 16/6/15.
//  Copyright © 2016年 Suzhou Qier Network Technology Co., Ltd. All rights reserved.
//

import UIKit
// MARK: - viewModule
class ViewModule {
    func bind(k: ()->Void){
        k()
    }
}
// MARK: - 属性
class property<T>{
    var data:T
    let ob = observer<T>()
    var value:T{
        get{
            return data
        }
        set{
            data = newValue
            self.ob.go(newValue)
        }
    }
    init(v:T){
        data = v
    }
    func register(key:String)->observer<T>{
        ob.currentID = key
        return ob
    }
    func unregister(key:String) {
        ob.excs.removeValueForKey(key)
    }
}
// MARK: - 命令
class command{
    var queue:dispatch_queue_t?
    var call:((sender:NSObject)->Void)?
    @objc func doSomething(sender:NSObject){
        if queue != nil{
            dispatch_async(queue!, { [weak self] in
                if self == nil{
                    return
                }
                if self!.call != nil{
                    self!.call!(sender: sender)
                }
            })
        }else{
            if self.call != nil{
                self.call!(sender: sender)
            }
        }
    }
    func action(a:(sender:NSObject)->Void)->command{
        call = a
        return self
    }
}

// MARK: - 自定义运算符
infix operator ^= {associativity left precedence 100}
infix operator ~= {associativity left precedence 100}
infix operator <~ {associativity left precedence 100}
func ^=<T>(pro:property<T>,value:T){
    if NSThread.isMainThread(){
        pro.value = value
    }else{
        dispatch_async(dispatch_get_main_queue(), { 
            pro.value = value
        })
    }
    
}
func <~ (b:command, a:UIControl){
    a.addTarget(b, action: #selector(command.doSomething(_:)), forControlEvents: .TouchUpInside)
}
func ~=<T>(pro:property<T>,value:T){
    pro.value = value
}
// MARK: - 观察者
class observer<T>{
    var excs:[String:(T?)->Void] = [:]
    var currentID = ""
    func doSomeThing(exc:(T?)->Void){
        self.excs[currentID] = exc
    }
    func set(exc:(T?)->T){
        
    }
    func go(value:T?){
        excs.forEach { (a) in
            a.1(value)
        }
    }
}