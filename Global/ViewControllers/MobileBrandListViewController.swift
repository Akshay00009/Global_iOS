//
//  MobileBrandListViewController.swift
//  Global
//
//  Created by akshay Avati on 18/02/19.
//  Copyright © 2019 akshay Avati. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import SwiftyJSON
class MobileBrandListViewController: UIViewController,NVActivityIndicatorViewable {
    

    @IBOutlet weak var mobileListTableView: UITableView!
    var mobileBrandArray = [MobileBrandTableViewCellModel]()
    var shopId = ""
    var lat = ""
    var long = ""
    var updateArray = [[String:String]]()
    var data = ""
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
     updateStock()
    }
    @IBAction func backBtnAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func chackOutBtnAction(_ sender: Any) {
        let reportListVc = self.storyboard?.instantiateViewController(withIdentifier: "ReportListViewController") as? ReportListViewController
        reportListVc?.shopid = shopId
        self.navigationController?.pushViewController(reportListVc!, animated: true)

    }
    func updateStock() {
        startAnimating(kActivityIndicatorSize, message: kLoadingMessageForHud, type: NVActivityIndicatorType(rawValue: kActivityIndicatorNumber)! )
        let url = "http://globemobility.in/admin/Mobile/updateStock"
//        let paramsJSON = JSON(updateArray)
//        let paramsString = paramsJSON.rawString(String.Encoding.utf8, options: JSONSerialization.WritingOptions.prettyPrinted)!
       var arr = [String]()
        for dict in updateArray {
            data = getPostString(params: dict)
            arr.append(data)
        }
        print(arr)
        let Parameter = arr
        NetworkHelper.shareWithPars(parameter: Parameter ,method: .post, url: url, completion: { (result) in
            self.stopAnimating()
            let response = result as NSDictionary
            let resultValue = response["Result"] as! String
            if resultValue == "True" {
                self.showAlert(message: response["Message"] as! String, Title: "Alert")
            } else {
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
        cell.setCell(viewModel : mobdict , indexPath : indexPath)
        return cell
    }
    func showCountText(count: String, indexPath: IndexPath,show : Bool) {
        if show {
            let brandID = mobileBrandArray[indexPath.row].brandID
            let arr =  updateArray.filter({$0["brandId"] == brandID})
            print(arr)
            if let index = updateArray.index(where: {$0["brandId"] == brandID}) {
                updateArray[index]["shortqua"] = count
                mobileBrandArray[indexPath.row].stockQuantity = count
            } else {
                let param = ["shopid": mobileBrandArray[indexPath.row].sID,
                             "brandId": mobileBrandArray[indexPath.row].brandID,
                             "shortqua": count,
                             "lattude": mobileBrandArray[indexPath.row].lat,
                             "longitude": mobileBrandArray[indexPath.row].long,
                             "username": UserDefaults.standard.value(forKey: kuserName),
                             "userid": UserDefaults.standard.value(forKey: kuserId)]
                updateArray.append(param as! [String : String])
                print(data )
                mobileBrandArray[indexPath.row].stockQuantity = count
            }
            print(updateArray)
        } else {
            let brandID = mobileBrandArray[indexPath.row].brandID
            if updateArray.count != 0 {
                if let indexp = updateArray.index(where: {$0["brandId"] == brandID}){
                    updateArray.remove(at: indexp)
                    mobileBrandArray[indexPath.row].stockQuantity = ""
                    mobileListTableView.reloadData()
                }
            }
            self.showAlert(message: "Please Enter text below \([mobileBrandArray[indexPath.row].stock])", Title: "Alert")
        }
    }
    func getPostString(params:[String:Any]) -> String
    {
        var data = [String]()
        for(key, value) in params
        {
            data.append(key + " = \(value)")
        }
        return data.map { String($0) }.joined(separator: ",")
    }
    
}
