//
//  http.swift
//  mvvm
//
//  Created by YinHao on 16/6/16.
//  Copyright © 2016年 Suzhou Qier Network Technology Co., Ltd. All rights reserved.
//

import Foundation
public class http:NSObject,NSURLSessionTaskDelegate{
    var queue:NSOperationQueue
    var task:NSURLSessionTask?
    private var _config:NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
    private var semphone = dispatch_semaphore_create(0)
    private var syncState = false
    private var header:[String:String] = [:]
    public override init(){

        queue = NSOperationQueue()
        queue.name = "httpQueue"
        super.init()
    }
    public init(config:NSURLSessionConfiguration){
        queue = NSOperationQueue()
        queue.name = "httpQueue"
        _config = config
        super.init()
    }
    func getSession(delegate:NSURLSessionDelegate?)->NSURLSession{
        return NSURLSession(configuration:self._config, delegate: delegate, delegateQueue: queue)
    }
    public func load(request:NSURLRequest,callback:((NSData?,NSHTTPURLResponse?,NSError?)->Void)?)->http{
        self.task = self.getSession(self).dataTaskWithRequest(request) {[unowned self](data, response, error) in
            if callback != nil{
                callback!(data,response as? NSHTTPURLResponse,error)
            }
            if self.syncState{
               dispatch_semaphore_signal(self.semphone)
            }
            
        }
        return self
    }
    public func load(request:NSURLRequest,delegate:NSURLSessionDelegate?)->http{
        task = self.getSession(self).dataTaskWithRequest(request)
        return self
    }
    public func upload(request:NSURLRequest,data:NSData,callback:((NSData?,NSHTTPURLResponse?,NSError?)->Void)?)->http{
        task = self.getSession(self).uploadTaskWithRequest(request, fromData: data) { [unowned self](data, response, error) in
            if callback != nil{
                callback!(data,response as? NSHTTPURLResponse,error)
            }
            if self.syncState{
                dispatch_semaphore_signal(self.semphone)
            }
        }
        return self
    }
    public func upload(request:NSURLRequest,data:NSData,delegate:NSURLSessionDelegate?)->http{
        task = self.getSession(delegate).uploadTaskWithRequest(request, fromData: data)
        return self
    }
    
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
    public func post(urlstr:String,json:[String:AnyObject],handle:(NSData?,NSHTTPURLResponse?,NSError?)->Void) -> http {
        return noGet("post", urlstr: urlstr, data: json, handle: handle)
    }
    public func delete(urlstr:String,json:[String:AnyObject],handle:(NSData?,NSHTTPURLResponse?,NSError?)->Void) -> http {
        return noGet("post", urlstr: urlstr, data: json, handle: handle)
    }
    public func put(urlstr:String,json:[String:AnyObject],handle:(NSData?,NSHTTPURLResponse?,NSError?)->Void) -> http {
        return noGet("post", urlstr: urlstr, data: json, handle: handle)
    }
    public func header(header:[String:String])->http{
        for i in header{
            self.header[i.0] = i.1
        }
        return self
    }
    public func sync(complete:(()->Void)?){
        syncState = true
        task?.resume()
        dispatch_semaphore_wait(self.semphone, DISPATCH_TIME_FOREVER)
        if complete != nil{
            complete!()
        }
    }
    public func async(){
        task?.resume()
    }
    public func cancel(){
        self.task?.cancel()
    }
}