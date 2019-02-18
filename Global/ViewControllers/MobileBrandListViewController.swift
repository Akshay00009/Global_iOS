//
//  MobileBrandListViewController.swift
//  Global
//
//  Created by akshay Avati on 18/02/19.
//  Copyright © 2019 akshay Avati. All rights reserved.
//

import UIKit
import SwiftyJSON
class MobileBrandListViewController: UIViewController {
    

    @IBOutlet weak var mobileListTableView: UITableView!
    var mobileBrandArray = [MobileBrandTableViewCellModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        mobileListTableView.delegate = self
        mobileListTableView.dataSource = self
        
        self.mobileListTableView.register(UINib(nibName: "MobileBrandTableViewCell", bundle: nil), forCellReuseIdentifier: "MobileBrandTableViewCell")

        // Do any additional setup after loading the view.
    }
    
    @IBAction func updateStockAction(_ sender: Any) {
        
    }

    func  showAlert(message: String = "", Title: String = "") {
        let alertController = UIAlertController(title: Title, message: message, preferredStyle: UIAlertController.Style.alert)
        let retryAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: {
            alert -> Void in
            self.dismiss(animated: true, completion: nil)
        })
        alertController.addAction(retryAction)
        self.present(alertController, animated: true, completion: nil)
    }

}
extension MobileBrandListViewController : UITableViewDelegate,UITableViewDataSource,MobileBrandTableViewCellDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10//mobileBrandArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MobileBrandTableViewCell = mobileListTableView.dequeueReusableCell(withIdentifier: "MobileBrandTableViewCell", for: indexPath) as! MobileBrandTableViewCell
        cell.delegateObject = self
        let cnt = Int(cell.countTxtField.text!)
        //  cell.setupCell(dict : NSDictionary)
        return cell
    }
    func showCountText(count: String, indexPath: IndexPath) {
            self.showAlert(message: kSomethingGetWrong, Title: "Error")
        
    }
}
