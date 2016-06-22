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