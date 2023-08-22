//
//  YellowShadowView.swift
//  TO
//
//  Created by RX Group on 18.02.2021.
//

import UIKit

class YellowShadowView: UIView {

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

               shadowLayer.shadowColor = UIColor.init(displayP3Red: 251/255, green: 160/255, blue: 45/255, alpha: 1).cgColor
               shadowLayer.shadowPath = shadowLayer.path
               shadowLayer.shadowOffset = CGSize(width: 0.0, height: 0.0)
               shadowLayer.shadowOpacity = 1
               shadowLayer.shadowRadius = 12

               layer.insertSublayer(shadowLayer, at: 0)
               //layer.insertSublayer(shadowLayer, below: nil) // also works
           }

   }
}
