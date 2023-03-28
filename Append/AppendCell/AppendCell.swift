//
//  AppendCell.swift
//  RefManager1-2
//
//  Created by 加藤研太郎 on 2023/03/05.
//

import UIKit

class AppendCell: UITableViewCell {
    @IBOutlet weak var kindViewButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var quantityUnitButton: UIButton!
    @IBOutlet weak var refButton: UIButton!
    @IBOutlet weak var freezerButton: UIButton!
    @IBOutlet weak var removeButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
extension AppendCell: AppendCellProviderOutput {

}