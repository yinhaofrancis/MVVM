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
    
    @IBOutlet weak var btn: UIButton!
    var vm = test()
//    var timer:dispatch_source_t?
    override func viewDidLoad() {
        super.viewDidLoad()
        vm.name.register("look").doSomeThing { [unowned self] in
            self.label.text = $0}
        vm.sd.register("sh").doSomeThing { [unowned self] in
            self.label.hidden = $0!}
        vm.cli <~ btn
    }
    @IBAction func haha(sender: AnyObject) {
        if label.text == nil{
            label.text = "haha"
        }else{
            label.text = label.text! + "\nhaha"
        }
    }
}

