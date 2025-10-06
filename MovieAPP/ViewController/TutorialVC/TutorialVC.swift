//
//  TutorialVC.swift
//  MovieAPP
//
//  Created by Anwin Km  on 06/10/25.
//

import UIKit

class TutorialVC: UIViewController {
    
    @IBOutlet weak var btnGetStart: UIButton!{
        didSet{
            btnGetStart.layer.cornerRadius = 14
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    @IBAction func btnClickedGetStarted(_ sender: Any) {
        let home  = HomeVC()
        self.navigationController?.pushViewController(home, animated: true)
    }
}
