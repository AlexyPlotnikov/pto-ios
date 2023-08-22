//
//  CardCell.swift
//  TO
//
//  Created by RX Group on 20.02.2021.
//

import UIKit

class CardCell: UITableViewCell {

    @IBOutlet weak var bottomView: ViewWithShadows!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var adressLbl: UILabel!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var pathBtn: UIButton!
    @IBOutlet weak var callbtn: UIButton!
    @IBOutlet weak var leftView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
   
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        leftView.roundCorners(corners: [.topLeft,.bottomLeft], radius: 5)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
