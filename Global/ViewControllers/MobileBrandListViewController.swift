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
import CoreLocation
class MobileBrandListViewController: UIViewController,NVActivityIndicatorViewable,CLLocationManagerDelegate {
    
    
    @IBOutlet weak var shopnm: UILabel!
    @IBOutlet weak var mobileListTableView: UITableView!
    var mobileBrandArray = [MobileBrandTableViewCellModel]()
    var shopId = ""
    var shopName = ""
    var updateArray = [[String:String]]()
    var data = ""
    var longitudeValue = ""
    var latitudeValue = ""
    var currentLocation: CLLocation! = nil
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        mobileListTableView.delegate = self
        mobileListTableView.dataSource = self
        self.mobileListTableView.register(UINib(nibName: "MobileBrandTableViewCell", bundle: nil), forCellReuseIdentifier: "MobileBrandTableViewCell")
        
        locationManager.requestAlwaysAuthorization()
        // For use when the app is open
        //locationManager.requestWhenInUseAuthorization()
        // If location services is enabled get the users location
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest // You can change the locaiton accuary here.
            locationManager.startUpdatingLocation()
            currentLocation = locationManager.location
        }
        // Do any additional setup after loading the view.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let long = location.coordinate.longitude
            let lat = location.coordinate.latitude
            latitudeValue  = (String(format: "%.8f", lat))
            longitudeValue = (String(format: "%.8f", long))
        }
    }
    
    // If we have been deined access give the user the option to change it
    @available(iOS 4.2, *)
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {
        locationManager.startUpdatingLocation()
    }

    override func viewWillAppear(_ animated: Bool) {
        shopnm.text = shopName
        if mobileBrandArray.count != 0 {
            mobileListTableView.isHidden = false
        } else {
            mobileListTableView.isHidden = true
            self.showAlert(message: "There is no data records", Title: "Alert")
        }
    }
    @IBAction func updateStockAction(_ sender: Any) {
        if mobileBrandArray.count != 0 {
            updateStock()
        } else {
            self.showAlert(message: "There is no data records", Title: "Alert")
        }
    }
    @IBAction func backBtnAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func chackOutBtnAction(_ sender: Any) {
//        let reportListVc = self.storyboard?.instantiateViewController(withIdentifier: "ReportListViewController") as? ReportListViewController
//        reportListVc?.shopid = shopId
//        reportListVc!.shopName = shopName
//        self.navigationController?.pushViewController(reportListVc!, animated: true)
            startAnimating(kActivityIndicatorSize, message: kLoadingMessageForHud, type: NVActivityIndicatorType(rawValue: kActivityIndicatorNumber)! )
            let url = "http://globemobility.in/admin/Mobile/OUT_from_shop"
            let Parameter: [String : String] = ["shopid": shopId,"latitude":latitudeValue,"longitude":longitudeValue]
            NetworkHelper.shareWithPars(parameter: Parameter ,method: .post, url: url, completion: { (result) in
                self.stopAnimating()
                let response = result as NSDictionary
                let resultValue = response["Result"] as! String
                if resultValue == "True" {
                    let loginVc = self.storyboard?.instantiateViewController(withIdentifier: "ShopListViewController") as? ShopListViewController
                    self.navigationController?.pushViewController(loginVc!, animated: true)
                    
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
                    self.showAlert(message: kSomethingGetWrong, Title: "Alert")
                }
            })
        }
    
    func updateStock() {
        startAnimating(kActivityIndicatorSize, message: kLoadingMessageForHud, type: NVActivityIndicatorType(rawValue: kActivityIndicatorNumber)! )
        let url = "http://globemobility.in/admin/Mobile/updateStock"
        var brandArr = [Any]()
        var stockQuant = [Any]()
        for dict in mobileBrandArray {
            let dic =  dict
            brandArr.append(dic.brandID)
            stockQuant.append(dic.stockQuantity)
        }
        let Parameter : [String : AnyObject] = ["brandId" : brandArr as AnyObject ,"shortqua" : stockQuant as AnyObject ,
                                                "shopid": mobileBrandArray[0].sID as AnyObject,
                                                "lattude": mobileBrandArray[0].lat as AnyObject ,
                                                "longitude": mobileBrandArray[0].long as AnyObject,
                                                "username": UserDefaults.standard.value(forKey: kuserName) as AnyObject,
                                                "userid": UserDefaults.standard.value(forKey: kuserId) as AnyObject]
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
                self.showAlert(message: kSomethingGetWrong, Title: "Alert")
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
            var cnt : Int = 0
            let brandID = mobileBrandArray[indexPath.row].brandID
            let arr =  updateArray.filter({$0["brandId"] == brandID})
            print(arr)
            let stock = Int(mobileBrandArray[indexPath.row].stock)
            let cou = Int(count)
            if count != "" {
                cnt =  stock! - cou!
                mobileBrandArray[indexPath.row].stockQuantity = String(cnt)
                mobileBrandArray[indexPath.row].temp = String(cnt)
            } else {
                mobileBrandArray[indexPath.row].stockQuantity = count
                mobileBrandArray[indexPath.row].temp = count
            }
        } else {
            mobileBrandArray[indexPath.row].stockQuantity = "null"
            mobileBrandArray[indexPath.row].temp = ""
            mobileListTableView.reloadData()
            self.showAlert(message: "Please enter value below stock level", Title: "Alert")
        }
    }
    
    func getPostString(params:[String:Any]) -> String {
        var data = [String]()
        for(key, value) in params
        {
            data.append(key + " = \(value)")
        }
        return data.map { String($0) }.joined(separator: ",")
    }
    
}
