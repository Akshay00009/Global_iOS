//
//  shopListViewController.swift
//  Global
//
//  Created by akshay Avati on 18/02/19.
//  Copyright © 2019 akshay Avati. All rights reserved.
//

import UIKit

class ShopListViewController: UIViewController,BCDropDownButtonDelegate {

    @IBOutlet weak var bcDropDownBtn: BCDropDownButton!
    @IBOutlet weak var shopListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.shopListTableView.register(UINib(nibName: "ShopListTableViewCell", bundle: nil), forCellReuseIdentifier: "ShopListTableViewCell")
        self.bcDropDownBtn.items = ["1","2","3"]
        bcDropDownBtn.delegate = self
        // Do any additional setup after loading the view.
    }
    func dropDownButton(_ button: BCDropDownButton!, didChangeValue value: String!, with index: Int) {
        print(value,index)
    }
}
