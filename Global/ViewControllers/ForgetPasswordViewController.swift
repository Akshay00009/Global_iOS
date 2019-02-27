//
//  ForgetPasswordViewController.swift
//  Global
//
//  Created by akshay Avati on 18/02/19.
//  Copyright © 2019 akshay Avati. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import GBFloatingTextField

class ForgetPasswordViewController: UIViewController,NVActivityIndicatorViewable {

    @IBOutlet weak var emailTxtfield: GBTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTxtfield.tintColor = UIColor(red: 42.0/255.0, green: 152.0/255.0, blue: 142.0/255.0, alpha: 0.8)
        emailTxtfield.lineColor = .black
        emailTxtfield.titleLabelColor = .black
        emailTxtfield.lineHeight = 1
        self.view.addSubview(emailTxtfield)

        // Do any additional setup after loading the view.
    }
    
    @IBAction func updateBtnAction(_ sender: Any) {
        updateApiCall()
    }
    
    func updateApiCall() {
        startAnimating(kActivityIndicatorSize, message: kLoadingMessageForHud, type: NVActivityIndicatorType(rawValue: kActivityIndicatorNumber)! )
        let url = "http://globemobility.in/admin/Mobile/ForgetPassword"
        let emailAdd = emailTxtfield.text!
        print(emailAdd)
        let Parameter = ["emailid": emailAdd]
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
 
    @IBAction func backBtnAvtion(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
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
