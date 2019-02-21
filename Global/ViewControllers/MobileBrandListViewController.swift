//
//  MobileBrandListViewController.swift
//  Global
//
//  Created by akshay Avati on 18/02/19.
//  Copyright © 2019 akshay Avati. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class MobileBrandListViewController: UIViewController,NVActivityIndicatorViewable {
    

    @IBOutlet weak var mobileListTableView: UITableView!
    var mobileBrandArray = [MobileBrandTableViewCellModel]()
    var shopId = ""
    var lat = ""
    var long = ""
    var updateArray = [[String:String]]()
    override func viewDidLoad() {
        super.viewDidLoad()
        print(shopId)
        mobileListTableView.delegate = self
        mobileListTableView.dataSource = self
        
        self.mobileListTableView.register(UINib(nibName: "MobileBrandTableViewCell", bundle: nil), forCellReuseIdentifier: "MobileBrandTableViewCell")

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        mobileListTableView.isHidden = true
        getBranndListApi()
    }
    
    func getBranndListApi() {
        startAnimating(kActivityIndicatorSize, message: kLoadingMessageForHud, type: NVActivityIndicatorType(rawValue: kActivityIndicatorNumber)! )
        let url = "http://globemobility.in/admin/Mobile/getBrandList"
        let Parameter: [String : AnyObject] = ["shopid": shopId as AnyObject,"latitude": lat as AnyObject,"longitude": long as AnyObject,]
        NetworkHelper.shareWithPars(parameter: Parameter as NSDictionary,method: .post, url: url, completion: { (result) in
            self.stopAnimating()
            let response = result as NSDictionary
            let resultValue = response["Result"] as! String
            if resultValue == "True" {
                self.mobileBrandArray.removeAll()
                let dataArray : NSArray = response["data"] as! NSArray
                for dict in dataArray {
                    self.mobileBrandArray.append(MobileBrandTableViewCellModel(mobListDict: dict as! NSDictionary))
                }
                self.mobileListTableView.isHidden = false
                self.mobileListTableView.reloadData()
            } else {
                self.mobileListTableView.isHidden = true
                self.showAlert(message: response["Message"] as! String, Title: "Alert")
            }
        }, completionError:  { (error) in
            self.stopAnimating()
            let errorResponse = error as NSDictionary
            if errorResponse.value(forKey: "errorType") as! NSNumber == 1 {
                self.present(AppUtility.showInternetErrorMessage(title: "", errorMessage: kNoInterNetMessage, completion: {
                }), animated: true, completion: nil)
            }  else if errorResponse.value(forKey: "errorType") as! NSNumber == 2 || errorResponse.value(forKey: "errorType") as! NSNumber == 3 {
                self.showAlert(message: kSomethingGetWrong, Title: "Error")
            }
        })
    }

    
    @IBAction func updateStockAction(_ sender: Any) {
        //updateStock()
    }

    func updateStock() {
        startAnimating(kActivityIndicatorSize, message: kLoadingMessageForHud, type: NVActivityIndicatorType(rawValue: kActivityIndicatorNumber)! )
        let url = "http://globemobility.in/admin/Mobile/getBrandList"
        let Parameter: [String : AnyObject] = ["shopid": shopId as AnyObject,"latitude": lat as AnyObject,"longitude": long as AnyObject,]
        NetworkHelper.shareWithPars(parameter: Parameter as NSDictionary,method: .post, url: url, completion: { (result) in
            self.stopAnimating()
            let response = result as NSDictionary
            let resultValue = response["Result"] as! String
            if resultValue == "True" {
                self.mobileBrandArray.removeAll()
                let dataArray : NSArray = response["data"] as! NSArray
                for dict in dataArray {
                    self.mobileBrandArray.append(MobileBrandTableViewCellModel(mobListDict: dict as! NSDictionary))
                }
                self.mobileListTableView.isHidden = false
                self.mobileListTableView.reloadData()
            } else {
                self.mobileListTableView.isHidden = true
                self.showAlert(message: response["Message"] as! String, Title: "Alert")
            }
        }, completionError:  { (error) in
            self.stopAnimating()
            let errorResponse = error as NSDictionary
            if errorResponse.value(forKey: "errorType") as! NSNumber == 1 {
                self.present(AppUtility.showInternetErrorMessage(title: "", errorMessage: kNoInterNetMessage, completion: {
                }), animated: true, completion: nil)
            }  else if errorResponse.value(forKey: "errorType") as! NSNumber == 2 || errorResponse.value(forKey: "errorType") as! NSNumber == 3 {
                self.showAlert(message: kSomethingGetWrong, Title: "Error")
            }
        })
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
        return mobileBrandArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MobileBrandTableViewCell = mobileListTableView.dequeueReusableCell(withIdentifier: "MobileBrandTableViewCell", for: indexPath) as! MobileBrandTableViewCell
        cell.delegateObject = self
        let mobdict = mobileBrandArray[indexPath.row]
        let cnt = Int(cell.countTxtField.text!)
        cell.setCell(viewModel : mobdict , indexPath : indexPath)
        return cell
    }
    func showCountText(count: String, indexPath: IndexPath,show : Bool) {
        if show {
            let param = ["shopid": mobileBrandArray[indexPath.row].stock,
                         "brandId": mobileBrandArray[indexPath.row].brandID,
                         "shortqua": mobileBrandArray[indexPath.row].stock,
                         "lattude": mobileBrandArray[indexPath.row].lat,
                         "longitude": mobileBrandArray[indexPath.row].long,
                         "username": UserDefaults.value(forKey: kuserName),
                         "userid": UserDefaults.value(forKey: kuserId)]
        } else {
            self.showAlert(message: "Please Enter text below \([mobileBrandArray[indexPath.row].stock])", Title: "Alert")
        }
        
    }
}
