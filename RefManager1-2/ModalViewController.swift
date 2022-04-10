//
//  ModalViewController.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2022/04/10.
//

import UIKit

class ModalViewController: UIViewController {
    static private var baseArray = Food(refOrFreezer: .refrigator, kind: .other, name: String(), quantity: Int(), unit: String(), IDkey: String())
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true)
    }
    @IBAction func preserve(_ sender: Any) {
        dismiss(animated: true)
    }
}
