//
//  thread.swift
//  mvvm
//
//  Created by YinHao on 16/6/16.
//  Copyright © 2016年 Suzhou Qier Network Technology Co., Ltd. All rights reserved.
//

import Foundation
let group = dispatch_group_create()
func asyncRun(queue:dispatch_queue_t,clusure:dispatch_block_t){
    dispatch_group_async(group, queue, clusure)
    threadWatcher.watcher.add()
}
func asyncMainRun(clusure:dispatch_block_t){
    dispatch_group_async(group, dispatch_get_main_queue(), clusure)
    threadWatcher.watcher.add()
}

// MARK: timer
class timer{
    static let queue = dispatch_queue_create("com.YH.timer", DISPATCH_QUEUE_SERIAL)
    private var dispatch_source:dispatch_source_t?
    private var _statue = false
    private var inteval:UInt64 = 0
    func isRuning()->Bool{
        return _statue
    }
    init(timerinteval:UInt64){
        inteval = timerinteval
        dispatch_source = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, timer.queue)
        dispatch_source_set_timer(dispatch_source!, DISPATCH_TIME_NOW, inteval * NSEC_PER_SEC, 1 * NSEC_PER_SEC)
    }
    func run(closure:dispatch_block_t) throws{
        guard _statue == false else{
            throw NSError(domain: "timer 不可重复启动", code: 0, userInfo: nil)
        }
        dispatch_source_set_event_handler(dispatch_source!, closure)
        dispatch_resume(dispatch_source!)
        _statue = true
        
    }
    func stop(){
        _statue = false
        dispatch_source_cancel(dispatch_source!)
    }
    func suspend(){
        _statue = false
        dispatch_suspend(dispatch_source!)
    }
}
// MARK: threadWatcher
class threadWatcher{
    static let queue = dispatch_queue_create("com.YH.Watcher", DISPATCH_QUEUE_SERIAL)
    static let watcher = threadWatcher()
    private var call:dispatch_block_t? = nil
    func add(){
        if call == nil{
            return
        }
        dispatch_group_notify(group, threadWatcher.queue, call!)
    }
    func setCallBack(k:dispatch_block_t){
        call = k;
    }
}