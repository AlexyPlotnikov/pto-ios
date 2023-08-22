//
//  TimeCollectionCell.swift
//  TO
//
//  Created by RX Group on 20.02.2021.
//

import UIKit

class TimeCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var timeLbl: UILabel!
    
    func toggleSelected ()
        {
        if (isSelected){
                self.contentView.backgroundColor = UIColor.init(displayP3Red: 84/255, green: 69/255, blue: 96/255, alpha: 1)
                timeLbl.textColor = .white
            }else {
                self.contentView.backgroundColor = UIColor.white
                timeLbl.textColor = .black
            }
        }
}
