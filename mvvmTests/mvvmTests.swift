//
//  mvvmTests.swift
//  mvvmTests
//
//  Created by YinHao on 16/6/15.
//  Copyright © 2016年 Suzhou Qier Network Technology Co., Ltd. All rights reserved.
//

import XCTest
@testable import mvvm

class mvvmTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
//        http().header([
//            "Content-Type":"application/json",
//            "X-LC-Id":"OMmHuevA9FzseHV6B6OA229M-gzGzoHsz",
//            "X-LC-Key":"5dGiqJbb3M13oPCRGiwJQs2f"
//            ]).get("https://api.leancloud.cn/1.1/login", params: ["username":"yinhao","password":"123123"]) { (data, response, error) in
//                print(try? NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments))
//            }.sync {
//                    print("complete")
//        }
        http().header([
            "Content-Type":"application/json",
            "apikey":"cc6292bdbd0b8fc836480104219a2522"
            ]).get("http://apis.baidu.com/apistore/idservice/id", params: ["id":"340403199207021416"]) { (data, response, error) in
                let rep = try? NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
            }.sync {
                print("complete")
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            

        }
    }
    
}
