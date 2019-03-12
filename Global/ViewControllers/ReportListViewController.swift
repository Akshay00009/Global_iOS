//
//  ReportListViewController.swift
//  Global
//
//  Created by akshay Avati on 18/02/19.
//  Copyright © 2019 akshay Avati. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
class ReportListViewController: UIViewController,NVActivityIndicatorViewable,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var shopNm: UILabel!
    var shopid = ""
    var shopName = ""
    var reportListArray = [ReportTableViewCellCellModel]()
    @IBOutlet weak var reporttableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        reporttableView.delegate = self
        reporttableView.dataSource = self
        self.reporttableView.register(UINib(nibName: "ReportTableViewCell", bundle: nil), forCellReuseIdentifier: "ReportTableViewCell")

        // Do any additional setup after loading the view.
    }
    
    @IBAction func backBtnAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.reporttableView.isHidden = true
        shopNm.text = shopName
        reportListApi()
    }
    
    func  reportListApi() {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let result = formatter.string(from: date)

        startAnimating(kActivityIndicatorSize, message: kLoadingMessageForHud, type: NVActivityIndicatorType(rawValue: kActivityIndicatorNumber)! )
        let url = "http://globemobility.in/admin/Mobile/todays_shop_po"
        let Parameter: [String : AnyObject] = ["shopid": shopid as AnyObject,"date": result as AnyObject]
        NetworkHelper.shareWithPars(parameter: Parameter as NSDictionary,method: .post, url: url, completion: { (result) in
            self.stopAnimating()
            let response = result as NSDictionary
            let resultValue = response["Result"] as! String
            if resultValue == "True" {
                self.reportListArray.removeAll()
                let dataArray : NSArray = response["data"] as! NSArray
                for dict in dataArray {
                    self.reportListArray.append(ReportTableViewCellCellModel(reportListDict: dict as! NSDictionary))
                }
                self.reporttableView.isHidden = false
                self.reporttableView.reloadData()
            } else {
                self.reporttableView.isHidden = true
                self.showAlert(message: response["Message"] as! String, Title: "Alert")
            }
        }, completionError:  { (error) in
            self.stopAnimating()
            self.reporttableView.isHidden = true
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return reportListArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ReportTableViewCell = reporttableView.dequeueReusableCell(withIdentifier: "ReportTableViewCell", for: indexPath) as! ReportTableViewCell
        let repdict = reportListArray[indexPath.row]
        cell.setCell(viewModel : repdict , indexPath : indexPath)
        return cell

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
