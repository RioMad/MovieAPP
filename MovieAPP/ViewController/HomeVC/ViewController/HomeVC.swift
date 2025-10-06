//
//  HomeVC.swift
//  MovieAPP
//
//  Created by Anwin Km - Technology Associate-Mobile Development on 06/10/25.
//

import UIKit

class HomeVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var searchView: UIView!{
        didSet{
            searchView.layer.cornerRadius = 14
        }
    }
    @IBOutlet weak var tfSerach: UITextField!{
        didSet{
            
            tfSerach.attributedPlaceholder = NSAttributedString(
                string: "Search Movies",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor(hexString: "#BABABA", alpha: 1.0) ?? .gray]
            )

        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tfSerach.delegate = self
        // Do any additional setup after loading the view.
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        tfSerach.resignFirstResponder() // 👈 hides the keyboard
        return true
    }
}
