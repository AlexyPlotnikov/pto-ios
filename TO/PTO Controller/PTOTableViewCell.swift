//
//  PTOTableViewCell.swift
//  TO
//
//  Created by RX Group on 19.02.2021.
//

import UIKit

class PTOTableViewCell: UITableViewCell {

    @IBOutlet weak var circle: UIView!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var distanceLbl: UILabel!
    
    @IBOutlet weak var adressRecomend: UILabel!
    @IBOutlet weak var dateRec: UILabel!
    @IBOutlet weak var priceRec: UILabel!
    @IBOutlet weak var distanceRec: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if(circle != nil){
            circle.layer.cornerRadius = 2.5
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
