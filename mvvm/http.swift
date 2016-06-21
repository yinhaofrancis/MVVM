//
//  http.swift
//  mvvm
//
//  Created by YinHao on 16/6/16.
//  Copyright © 2016年 Suzhou Qier Network Technology Co., Ltd. All rights reserved.
//

import Foundation
/// http 请求类
public class http:NSObject,NSURLSessionTaskDelegate{
    /**
     http请求异步回调队列
     
     - returns: NSOperationQueue
     */
    static var queue:NSOperationQueue = NSOperationQueue()
 
    private var task:NSURLSessionTask?
    /**
     http 默认配置
     
     - returns: NSURLSessionConfiguration
     */
    private var _config:NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
    /**
     同步信号量 默认值是0
     
     - returns: dispatch_semaphore_t
     */
    private var semphone = dispatch_semaphore_create(0)
    private var syncState = false
    private var success = false
    private var header:[String:String] = [:]
    private var session:NSURLSession?
    private weak var _delegate:NSURLSessionDelegate?
    public override class func initialize(){
        http.queue.name = "httpQueue"
    }
    /**
     默认配置构造http
     
     - returns: http对象
     */
    public override init(){
        super.init()
        _delegate = self
    }
    /**
        根据config，delegate 初始化http
        ps.后台模式必须设置代理
     - parameter config:   http 配置对象
     - parameter delegate: 代理
     
     - returns: http对象
     */
    public init(config:NSURLSessionConfiguration,delegate:NSURLSessionDelegate?){
        _config = config
        _delegate = delegate
        super.init()
    }
    /**
     获得URLSession
     
     - parameter delegate: URLSession delegate
     
     - returns: NSURLSession
     */
    private func getSession()->NSURLSession{
        if session == nil{
            self.session = NSURLSession(configuration:self._config, delegate: self._delegate, delegateQueue: http.queue)
        }
        return self.session!
    }
    /**
     根据request 进行http请求 callback 中会获取请求数据
     
     - parameter request:  http 请求对象
     - parameter callback: 回调闭包
     
     - returns: http 对象
     */
    public func load(request:NSURLRequest,callback:((NSData?,NSHTTPURLResponse?,NSError?)->Void)?)->http{
        self.task = self.getSession().dataTaskWithRequest(request) {[weak self](data, response, error) in
            if callback != nil{
                callback!(data,response as? NSHTTPURLResponse,error)
            }
            if self == nil{
                return
            }
            if self!.syncState{
                self!.success = true
                dispatch_semaphore_signal(self!.semphone)
            }
        }
        return self
    }
    /**
     根据 requset 进行http请求 delegate 中获取数据
     
     - parameter request: http requset
     */
    public func load(request:NSURLRequest){
        task = self.getSession().dataTaskWithRequest(request)
    }
    /**
     http 上传数据
     
     - parameter request:  http请求
     - parameter data:     上传的数据
     - parameter callback: 完成上传后的回调
     
     - returns: http 对象
     */
    public func upload(request:NSURLRequest,data:NSData,callback:((NSData?,NSHTTPURLResponse?,NSError?)->Void)?)->http{
        task = self.getSession().uploadTaskWithRequest(request, fromData: data) { [weak self](data, response, error) in
            if callback != nil{
                callback!(data,response as? NSHTTPURLResponse,error)
            }
            if self == nil{
                return
            }
            if self!.syncState{
                self!.success = true
                dispatch_semaphore_signal(self!.semphone)
            }
        }
        return self
    }
    /**
     http 上传数据
     
     - parameter request:  http请求
     - parameter data:     上传的数据
     */
    public func upload(request:NSURLRequest,data:NSData){
        task = self.getSession().uploadTaskWithRequest(request, fromData: data)
    }
    /**
     同步请求开始
     
     - parameter waitTime: 等待时间  单位秒
     - parameter complete: 请求完成后回调
     */
    public func sync(waitTime:UInt64,complete:((success:Bool)->Void)?)->NSURLSessionTask{
        syncState = true
        task?.resume()
        dispatch_semaphore_wait(self.semphone, dispatch_time(DISPATCH_TIME_NOW, Int64(waitTime * NSEC_PER_SEC)))
        if complete != nil{
            complete!(success: self.success)
        }
        return task!
    }
    /**
     异步请求开始
     */
    public func async()->NSURLSessionTask{
        task?.resume()
        return task!
    }
}
// MARK: - http 拓展
public extension http{
    /**
     get 请求
     
     - parameter urlstr: url 字符串
     - parameter params: 查询字符串
     - parameter handle: 回调closure
     
     - returns: 返回Commenthttp对象
     */
    public func get(urlstr:String,params:[String:AnyObject],handle:(NSData?,NSHTTPURLResponse?,NSError?)->Void) -> http {
        var index = 0
        let withQuery = urlstr + "?" + params.reduce("") { (r, data) -> String in
            index+=1
            return index == 1 ? r + "\(data.0)=\(data.1)" : r + "&\(data.0)=\(data.1)"
        }
        let url = NSURL(string: withQuery.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "get"
        request.allHTTPHeaderFields = self.header
        return self.load(request, callback: handle)
    }
    private func noGet(Method:String,urlstr:String,data:[String:AnyObject],handle:(NSData?,NSHTTPURLResponse?,NSError?)->Void) -> http {
        let request = NSMutableURLRequest(URL: NSURL(string: urlstr)!)
        request.HTTPMethod = Method
        request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(data, options: .PrettyPrinted)
        if request.HTTPBody == nil{
            print(" body is nil")
        }
        request.allHTTPHeaderFields = self.header
        return self.load(request, callback: handle)
    }
    /**
     post 请求
     
     - parameter urlstr: url 字符串
     - parameter json: json 数据
     - parameter handle: 回调closure
     
     - returns: 返回http对象
     */
    public func post(urlstr:String,json:[String:AnyObject],handle:(NSData?,NSHTTPURLResponse?,NSError?)->Void) -> http {
        return noGet("post", urlstr: urlstr, data: json, handle: handle)
    }
    /**
     delete 请求
     
     - parameter urlstr: url 字符串
     - parameter json: json 数据
     - parameter handle: 回调closure
     
     - returns: 返回http对象
     */
    public func delete(urlstr:String,json:[String:AnyObject],handle:(NSData?,NSHTTPURLResponse?,NSError?)->Void) -> http {
        return noGet("delete", urlstr: urlstr, data: json, handle: handle)
    }
    /**
     put 请求
     
     - parameter urlstr: url 字符串
     - parameter json: json 数据
     - parameter handle: 回调closure
     
     - returns: 返回http对象
     */
    public func put(urlstr:String,json:[String:AnyObject],handle:(NSData?,NSHTTPURLResponse?,NSError?)->Void) -> http {
        return noGet("put", urlstr: urlstr, data: json, handle: handle)
    }
    /**
     设置header 在 get post put delete 之前设置
     
     - parameter header: http header
     
     - returns: http 对象
     */
    public func header(header:[String:String])->http{
        for i in header{
            self.header[i.0] = i.1
        }
        return self
    }
}