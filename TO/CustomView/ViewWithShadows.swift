//
//  ViewWithShadows.swift
//  TO
//
//  Created by RX Group on 16.02.2021.
//

import UIKit

class ViewWithShadows: UIView {
    
     var shadowLayer: CAShapeLayer!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.backgroundColor = .clear
      
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
       
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if shadowLayer == nil {
                shadowLayer = CAShapeLayer()
                shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 5).cgPath
                shadowLayer.fillColor = UIColor.white.cgColor

                shadowLayer.shadowColor = UIColor.darkGray.cgColor
                shadowLayer.shadowPath = shadowLayer.path
                shadowLayer.shadowOffset = CGSize(width: 0.0, height: 0.0)
                shadowLayer.shadowOpacity = 0.2
                shadowLayer.shadowRadius = 15

                layer.insertSublayer(shadowLayer, at: 0)
                //layer.insertSublayer(shadowLayer, below: nil) // also works
            }

    }

}

