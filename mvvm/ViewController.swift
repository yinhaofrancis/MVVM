//
//  ViewController.swift
//  mvvm
//
//  Created by YinHao on 16/6/15.
//  Copyright © 2016年 Suzhou Qier Network Technology Co., Ltd. All rights reserved.
//

import UIKit
class ViewController: UIViewController {
    
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var insert: UIButton!
    
    @IBOutlet weak var query: UIButton!
    @IBOutlet weak var update: UIButton!
    
    @IBOutlet weak var delete: UIButton!
    var vm = test()
//    var timer:dispatch_source_t?
    override func viewDidLoad() {
        super.viewDidLoad()
        vm.name.register("look").doSomeThing { [unowned self] in
            self.label.text = $0}
        vm.sd.register("sh").doSomeThing { [unowned self] in
            self.label.hidden = $0!}
        vm.insert <~ insert
        vm.query <~ query
        vm.update <~ update
        vm.delete <~ delete
    }
    @IBAction func haha(sender: AnyObject) {
        if label.text == nil{
            label.text = "haha\n"
        }else{
            label.text = label.text! + "haha\n"
        }
    }
}

