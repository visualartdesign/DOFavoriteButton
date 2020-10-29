//
//  OvalLayer.swift
//  DOFavoriteButton
//
//  Created by Do Le Duy on 10/29/20.
//  Copyright © 2020 Daiki Okumura. All rights reserved.
//

import Foundation

class OvalLayer: CAShapeLayer {
    
    init(fillColor: CGColor) {
        super.init()
        self.fillColor = fillColor
    }
    
    override init() {
        super.init()
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        
    }
    
    override var frame: CGRect {
        didSet {
            self.path = UIBezierPath(ovalIn: frame).cgPath
        }
    }
    
    override var bounds: CGRect {
        didSet {
            self.path = UIBezierPath(ovalIn: bounds).cgPath
        }
    }
}
