//
//  DOFavoriteButton.swift
//  DOFavoriteButton
//
//  Created by Daiki Okumura on 2015/07/09.
//  Copyright (c) 2015 Daiki Okumura. All rights reserved.
//
//  This software is released under the MIT License.
//  http://opensource.org/licenses/mit-license.php
//

import UIKit

let defaultSelectedColor = UIColor(red: 255/255, green: 172/255, blue: 51/255, alpha: 1.0)
let defaultUnSelectedColor = UIColor(red: 136/255, green: 153/255, blue: 166/255, alpha: 1.0)
let defaultLineColor = UIColor(red: 250/255, green: 120/255, blue: 68/255, alpha: 1.0)

/// Custom lại UIButton
@IBDesignable
open class DOFavoriteButton: UIButton {
    
    /// Setting 4 color cho Selected, UnSelected, màu hình tròn bung ra, màu các tia bắn ra nhỏ nhỏ
    @IBInspectable open var selectedColor: UIColor! =  defaultSelectedColor {
        didSet {
            if (isSelected) {
                imageShapeLayer.fillColor = selectedColor.cgColor
            }
        }
    }
    @IBInspectable open var unselectedColor: UIColor! = defaultUnSelectedColor  {
        didSet {
            if (isSelected == false) {
                imageShapeLayer.fillColor = unselectedColor.cgColor
            }
        }
    }
    @IBInspectable open var circleColor: UIColor! = defaultSelectedColor {
        didSet {
            circleShape.fillColor = circleColor.cgColor
        }
    }
    @IBInspectable open var lineColor: UIColor! = defaultLineColor {
        didSet {
            for line in lines {
                line.strokeColor = lineColor.cgColor
            }
        }
    }
    
    @IBInspectable open var image: UIImage! {
        didSet {
            createLayers(image: image)
        }
    }
    fileprivate var imageShapeLayer: CAShapeLayer!
    fileprivate var circleShape: CAShapeLayer!
    fileprivate var circleMask: CAShapeLayer!
    fileprivate var lines: [CAShapeLayer]!
    fileprivate let circleTransform = CAKeyframeAnimation(keyPath: "transform")
    fileprivate let circleMaskTransform = CAKeyframeAnimation(keyPath: "transform")
    fileprivate let lineStrokeStart = CAKeyframeAnimation(keyPath: "strokeStart")
    fileprivate let lineStrokeEnd = CAKeyframeAnimation(keyPath: "strokeEnd")
    fileprivate let lineOpacity = CAKeyframeAnimation(keyPath: "opacity")
    fileprivate let imageTransform = CAKeyframeAnimation(keyPath: "transform")
    
    /// Animation duration
    @IBInspectable open var duration: Double = 1.0 {
        didSet {
            circleTransform.duration = 0.333 * duration // 0.0333 * 10
            circleMaskTransform.duration = 0.333 * duration // 0.0333 * 10
            lineStrokeStart.duration = 0.6 * duration //0.0333 * 18
            lineStrokeEnd.duration = 0.6 * duration //0.0333 * 18
            lineOpacity.duration = 1.0 * duration //0.0333 * 30
            imageTransform.duration = 1.0 * duration //0.0333 * 30
        }
    }
    
    override open var isSelected : Bool {
        didSet {
            if (isSelected != oldValue) {
                if isSelected {
                    imageShapeLayer.fillColor = selectedColor.cgColor
                } else {
                    animateToDeselectedState()
                }
            }
        }
    }
    
    // MARK: Initialize
    
    public convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    public override convenience init(frame: CGRect) {
        self.init(frame: frame, image: UIImage())
    }
    
    public init(frame: CGRect, image: UIImage!) {
        super.init(frame: frame)
        self.image = image
        createLayers(image: image)
        addTargets()
    }
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        createLayers(image: UIImage())
        addTargets()
    }
    
    // MARK: Public
    
    

    open func select() {
        select(animated: true)
    }
    
    open func select(animated: Bool = true) {
        
        isSelected = true
        imageShapeLayer.fillColor = selectedColor.cgColor
        
        if !animated { return }
        CATransaction.begin()
        
        circleShape.add(circleTransform, forKey: "transform")
        circleMask.add(circleMaskTransform, forKey: "transform")
        imageShapeLayer.add(imageTransform, forKey: "transform")
        
        for i in 0 ..< 5 {
            lines[i].add(lineStrokeStart, forKey: "strokeStart")
            lines[i].add(lineStrokeEnd, forKey: "strokeEnd")
            lines[i].add(lineOpacity, forKey: "opacity")
        }
        
        CATransaction.commit()
    }
    
    open func deselect() {
        animateToDeselectedState()
    }
    
    open func animateToSelectedState() {
        isSelected = true
        imageShapeLayer.fillColor = selectedColor.cgColor
        
        CATransaction.begin()
        
        circleShape.add(circleTransform, forKey: "transform")
        circleMask.add(circleMaskTransform, forKey: "transform")
        imageShapeLayer.add(imageTransform, forKey: "transform")
        
        for i in 0 ..< 5 {
            lines[i].add(lineStrokeStart, forKey: "strokeStart")
            lines[i].add(lineStrokeEnd, forKey: "strokeEnd")
            lines[i].add(lineOpacity, forKey: "opacity")
        }
        
        CATransaction.commit()
    }
    
    open func animateToDeselectedState() {
        isSelected = false
        imageShapeLayer.fillColor = unselectedColor.cgColor
        
        // remove all animations
        circleShape.removeAllAnimations()
        circleMask.removeAllAnimations()
        imageShapeLayer.removeAllAnimations()
        lines[0].removeAllAnimations()
        lines[1].removeAllAnimations()
        lines[2].removeAllAnimations()
        lines[3].removeAllAnimations()
        lines[4].removeAllAnimations()
    }
    
    // MARK: Private
    
    fileprivate func createLayers(image: UIImage!) {
        self.layer.sublayers = nil
        
        /// Calculate ImageFrame and LineFrame
        let buttonWidth = frame.size.width
        let buttonHeight = frame.size.height
        let imageFrame = CGRect(x: buttonWidth/4,
                                y: buttonHeight/4,
                                width: buttonWidth/2,
                                height: buttonHeight/2)
        let imgCenterPoint = CGPoint(x: imageFrame.midX, y: imageFrame.midY)
        
        /// CircleLayer là 1 hình tròn (nó cũng chứa 1 UIBezierPath đó)
        /// Hình tròn này có kích thước to bằng MAIN-IMAGE
        /// Tạm thời scale về 0.0
        circleShape = OvalLayer(fillColor: circleColor.cgColor)
        circleShape.bounds = imageFrame
        circleShape.position = imgCenterPoint
        circleShape.transform = CATransform3DMakeScale(0.0, 0.0, 1.0)   /// scale width, height về 0
        self.layer.addSublayer(circleShape)
        
        ///
        /// Read more about FillRule
        /// https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CocoaDrawingGuide/Paths/Paths.html#//apple_ref/doc/uid/TP40003290-CH206-BAJIJJGD
        /// CircleMask là 1 CAShapLayer chịu trách nhiệm draw 1 UIBezierPath (là hình tròn nhỏ xíu nằm ngay giữa MAIN-IMAGE)
        circleMask = CAShapeLayer()
        circleMask.bounds = imageFrame
        circleMask.position = imgCenterPoint
        circleMask.fillRule = CAShapeLayerFillRule.evenOdd
        circleShape.mask = circleMask
        /// Tạo 1 path object là hình tròn bán kính 0.1 nằm chính giữa MAIN-IMAGE
        /// Gán path vào CAShapeLayer (circleMask)
        let maskPath = UIBezierPath(rect: imageFrame)
        maskPath.addArc(withCenter: imgCenterPoint,
                        radius: 0.1,
                        startAngle: CGFloat(0.0),
                        endAngle: CGFloat(Double.pi*2),
                        clockwise: true)
        circleMask.path = maskPath.cgPath
        
        /// Lines là list của các CAShapeLayer (~ CALayer)
        let lineFrame = CGRect(x: imageFrame.origin.x - imageFrame.width/4,
                               y: imageFrame.origin.y - imageFrame.height / 4 ,
                               width: imageFrame.width * 1.5,
                               height: imageFrame.height * 1.5)
        lines = []
        for i in 0 ..< 5 {
            let line = CAShapeLayer()
            line.bounds = lineFrame
            line.position = imgCenterPoint
            line.masksToBounds = true
            line.actions = ["strokeStart": NSNull(), "strokeEnd": NSNull()]
            line.strokeColor = lineColor.cgColor
            line.lineWidth = 1.25
            line.miterLimit = 1.25
            line.path = {
                let path = CGMutablePath()
                path.move(to: CGPoint(x: lineFrame.midX, y: lineFrame.midY))
                path.addLine(to: CGPoint(x: lineFrame.origin.x + lineFrame.width / 2, y: lineFrame.origin.y))
                return path
            }()
            line.lineCap = CAShapeLayerLineCap.round
            line.lineJoin = CAShapeLayerLineJoin.round
            line.strokeStart = 0.0
            line.strokeEnd = 0.0
            line.opacity = 0.0
            line.transform = CATransform3DMakeRotation(CGFloat(Double.pi) / 5 * (CGFloat(i) * 2 + 1), 0.0, 0.0, 1.0)
            self.layer.addSublayer(line)
            lines.append(line)
        }
        
        //===============
        // image layer
        //===============
        imageShapeLayer = CAShapeLayer()
        imageShapeLayer.bounds = imageFrame
        imageShapeLayer.position = imgCenterPoint
        imageShapeLayer.path = UIBezierPath(rect: imageFrame).cgPath
        imageShapeLayer.fillColor = unselectedColor.cgColor
        imageShapeLayer.actions = ["fillColor": NSNull()]
        self.layer.addSublayer(imageShapeLayer)
        
        imageShapeLayer.mask = CALayer()
        imageShapeLayer.mask!.contents = image.cgImage
        imageShapeLayer.mask!.bounds = imageFrame
        imageShapeLayer.mask!.position = imgCenterPoint
        
        //==============================
        // circle transform animation
        //==============================
        circleTransform.duration = 0.333 // 0.0333 * 10
        circleTransform.values = [
            NSValue(caTransform3D: CATransform3DMakeScale(0.0,  0.0,  1.0)),    //  0/10
            NSValue(caTransform3D: CATransform3DMakeScale(0.5,  0.5,  1.0)),    //  1/10
            NSValue(caTransform3D: CATransform3DMakeScale(1.0,  1.0,  1.0)),    //  2/10
            NSValue(caTransform3D: CATransform3DMakeScale(1.2,  1.2,  1.0)),    //  3/10
            NSValue(caTransform3D: CATransform3DMakeScale(1.3,  1.3,  1.0)),    //  4/10
            NSValue(caTransform3D: CATransform3DMakeScale(1.37, 1.37, 1.0)),    //  5/10
            NSValue(caTransform3D: CATransform3DMakeScale(1.4,  1.4,  1.0)),    //  6/10
            NSValue(caTransform3D: CATransform3DMakeScale(1.4,  1.4,  1.0))     // 10/10
        ]
        circleTransform.keyTimes = [
            0.0,    //  0/10
            0.1,    //  1/10
            0.2,    //  2/10
            0.3,    //  3/10
            0.4,    //  4/10
            0.5,    //  5/10
            0.6,    //  6/10
            1.0     // 10/10
        ]
        
        circleMaskTransform.duration = 0.333 // 0.0333 * 10
        circleMaskTransform.values = [
            NSValue(caTransform3D: CATransform3DIdentity),                                                              //  0/10
            NSValue(caTransform3D: CATransform3DIdentity),                                                              //  2/10
            NSValue(caTransform3D: CATransform3DMakeScale(imageFrame.width * 1.25,  imageFrame.height * 1.25,  1.0)),   //  3/10
            NSValue(caTransform3D: CATransform3DMakeScale(imageFrame.width * 2.688, imageFrame.height * 2.688, 1.0)),   //  4/10
            NSValue(caTransform3D: CATransform3DMakeScale(imageFrame.width * 3.923, imageFrame.height * 3.923, 1.0)),   //  5/10
            NSValue(caTransform3D: CATransform3DMakeScale(imageFrame.width * 4.375, imageFrame.height * 4.375, 1.0)),   //  6/10
            NSValue(caTransform3D: CATransform3DMakeScale(imageFrame.width * 4.731, imageFrame.height * 4.731, 1.0)),   //  7/10
            NSValue(caTransform3D: CATransform3DMakeScale(imageFrame.width * 5.0,   imageFrame.height * 5.0,   1.0)),   //  9/10
            NSValue(caTransform3D: CATransform3DMakeScale(imageFrame.width * 5.0,   imageFrame.height * 5.0,   1.0))    // 10/10
        ]
        circleMaskTransform.keyTimes = [
            0.0,    //  0/10
            0.2,    //  2/10
            0.3,    //  3/10
            0.4,    //  4/10
            0.5,    //  5/10
            0.6,    //  6/10
            0.7,    //  7/10
            0.9,    //  9/10
            1.0     // 10/10
        ]
        
        //==============================
        // line stroke animation
        //==============================
        lineStrokeStart.duration = 0.6 //0.0333 * 18
        lineStrokeStart.values = [
            0.0,    //  0/18
            0.0,    //  1/18
            0.18,   //  2/18
            0.2,    //  3/18
            0.26,   //  4/18
            0.32,   //  5/18
            0.4,    //  6/18
            0.6,    //  7/18
            0.71,   //  8/18
            0.89,   // 17/18
            0.92    // 18/18
        ]
        lineStrokeStart.keyTimes = [
            0.0,    //  0/18
            0.056,  //  1/18
            0.111,  //  2/18
            0.167,  //  3/18
            0.222,  //  4/18
            0.278,  //  5/18
            0.333,  //  6/18
            0.389,  //  7/18
            0.444,  //  8/18
            0.944,  // 17/18
            1.0,    // 18/18
        ]
        
        lineStrokeEnd.duration = 0.6 //0.0333 * 18
        lineStrokeEnd.values = [
            0.0,    //  0/18
            0.0,    //  1/18
            0.32,   //  2/18
            0.48,   //  3/18
            0.64,   //  4/18
            0.68,   //  5/18
            0.92,   // 17/18
            0.92    // 18/18
        ]
        lineStrokeEnd.keyTimes = [
            0.0,    //  0/18
            0.056,  //  1/18
            0.111,  //  2/18
            0.167,  //  3/18
            0.222,  //  4/18
            0.278,  //  5/18
            0.944,  // 17/18
            1.0,    // 18/18
        ]
        
        lineOpacity.duration = 1.0 //0.0333 * 30
        lineOpacity.values = [
            1.0,    //  0/30
            1.0,    // 12/30
            0.0     // 17/30
        ]
        lineOpacity.keyTimes = [
            0.0,    //  0/30
            0.4,    // 12/30
            0.567   // 17/30
        ]
        
        //==============================
        // image transform animation
        //==============================
        imageTransform.duration = 1.0 //0.0333 * 30
        imageTransform.values = [
            NSValue(caTransform3D: CATransform3DMakeScale(0.0,   0.0,   1.0)),  //  0/30
            NSValue(caTransform3D: CATransform3DMakeScale(0.0,   0.0,   1.0)),  //  3/30
            NSValue(caTransform3D: CATransform3DMakeScale(1.2,   1.2,   1.0)),  //  9/30
            NSValue(caTransform3D: CATransform3DMakeScale(1.25,  1.25,  1.0)),  // 10/30
            NSValue(caTransform3D: CATransform3DMakeScale(1.2,   1.2,   1.0)),  // 11/30
            NSValue(caTransform3D: CATransform3DMakeScale(0.9,   0.9,   1.0)),  // 14/30
            NSValue(caTransform3D: CATransform3DMakeScale(0.875, 0.875, 1.0)),  // 15/30
            NSValue(caTransform3D: CATransform3DMakeScale(0.875, 0.875, 1.0)),  // 16/30
            NSValue(caTransform3D: CATransform3DMakeScale(0.9,   0.9,   1.0)),  // 17/30
            NSValue(caTransform3D: CATransform3DMakeScale(1.013, 1.013, 1.0)),  // 20/30
            NSValue(caTransform3D: CATransform3DMakeScale(1.025, 1.025, 1.0)),  // 21/30
            NSValue(caTransform3D: CATransform3DMakeScale(1.013, 1.013, 1.0)),  // 22/30
            NSValue(caTransform3D: CATransform3DMakeScale(0.96,  0.96,  1.0)),  // 25/30
            NSValue(caTransform3D: CATransform3DMakeScale(0.95,  0.95,  1.0)),  // 26/30
            NSValue(caTransform3D: CATransform3DMakeScale(0.96,  0.96,  1.0)),  // 27/30
            NSValue(caTransform3D: CATransform3DMakeScale(0.99,  0.99,  1.0)),  // 29/30
            NSValue(caTransform3D: CATransform3DIdentity)                       // 30/30
        ]
        imageTransform.keyTimes = [
            0.0,    //  0/30
            0.1,    //  3/30
            0.3,    //  9/30
            0.333,  // 10/30
            0.367,  // 11/30
            0.467,  // 14/30
            0.5,    // 15/30
            0.533,  // 16/30
            0.567,  // 17/30
            0.667,  // 20/30
            0.7,    // 21/30
            0.733,  // 22/30
            0.833,  // 25/30
            0.867,  // 26/30
            0.9,    // 27/30
            0.967,  // 29/30
            1.0     // 30/30
        ]
    }
    
    fileprivate func addTargets() {
        //===============
        // add target
        //===============
        self.addTarget(self, action: #selector(DOFavoriteButton.touchDown(_:)), for: UIControl.Event.touchDown)
        self.addTarget(self, action: #selector(DOFavoriteButton.touchUpInside(_:)), for: UIControl.Event.touchUpInside)
        self.addTarget(self, action: #selector(DOFavoriteButton.touchDragExit(_:)), for: UIControl.Event.touchDragExit)
        self.addTarget(self, action: #selector(DOFavoriteButton.touchDragEnter(_:)), for: UIControl.Event.touchDragEnter)
        self.addTarget(self, action: #selector(DOFavoriteButton.touchCancel(_:)), for: UIControl.Event.touchCancel)
    }
    
    @objc func touchDown(_ sender: DOFavoriteButton) {
        self.layer.opacity = 0.4
    }
    
    @objc func touchUpInside(_ sender: DOFavoriteButton) {
        self.layer.opacity = 1.0
    }
    
    @objc func touchDragExit(_ sender: DOFavoriteButton) {
        self.layer.opacity = 1.0
    }
    
    @objc func touchDragEnter(_ sender: DOFavoriteButton) {
        self.layer.opacity = 0.4
    }
    
    @objc func touchCancel(_ sender: DOFavoriteButton) {
        self.layer.opacity = 1.0
    }
}
