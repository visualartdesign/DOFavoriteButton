//
//  ViewController.swift
//  DOFavoriteButton-DEMO
//
//  Created by Daiki Okumura on 2015/07/09.
//  Copyright (c) 2015 Daiki Okumura. All rights reserved.
//

import UIKit
import DOFavoriteButton

class ViewController: UIViewController {
    
    /// Storyboard Button
    @IBOutlet var heartButton: DOFavoriteButton!

    /// Constant
    let selectedHeartColor = ColorRGB(254, 110, 111)
    let heartLineColor = ColorRGB(226, 96, 96)
    let selectedLikeColor = ColorRGB(52, 152, 219)
    let likeLineColor = ColorRGB(41, 128, 185)
    let selectedSmileColor = ColorRGB(45, 204, 112)
    let smileLineColor = ColorRGB(45, 195, 106)
    let buttonW: CGFloat = 44.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    func setupViews() {
        let width = (self.view.frame.width - buttonW) / 4
        var x = width / 2
        let y = self.view.frame.height / 2 - 22
        
        // star button
        let starButton = DOFavoriteButton(frame: CGRect(x: x, y: y, width: buttonW, height: buttonW), image: UIImage(named: "star"))
        starButton.addTarget(self, action: #selector(self.tappedButton), for: .touchUpInside)
        starButton.duration = 10.0
        self.view.addSubview(starButton)
        x += width
        
        // heart button
        let heartButton = DOFavoriteButton(frame: CGRect(x: x, y: y, width: buttonW, height: buttonW), image: UIImage(named: "heart"))
        heartButton.selectedColor = selectedHeartColor
        heartButton.circleColor = selectedHeartColor
        heartButton.lineColor = heartLineColor
        heartButton.addTarget(self, action: #selector(self.tappedButton), for: .touchUpInside)
        self.view.addSubview(heartButton)
        x += width
        
        // like button
        let likeButton = DOFavoriteButton(frame: CGRect(x: x, y: y, width: buttonW, height: buttonW), image: UIImage(named: "like"))
        likeButton.selectedColor = selectedLikeColor
        likeButton.circleColor = selectedLikeColor
        likeButton.lineColor = likeLineColor
        likeButton.addTarget(self, action: #selector(self.tappedButton), for: .touchUpInside)
        self.view.addSubview(likeButton)
        x += width
        
        // smile button
        let smileButton = DOFavoriteButton(frame: CGRect(x: x, y: y, width: buttonW, height: buttonW), image: UIImage(named: "smile"))
        smileButton.selectedColor = selectedSmileColor
        smileButton.circleColor = selectedSmileColor
        smileButton.lineColor = smileLineColor
        smileButton.addTarget(self, action: #selector(self.tappedButton), for: .touchUpInside)
        self.view.addSubview(smileButton)
        
        self.heartButton.addTarget(self, action: #selector(self.tappedButton), for: .touchUpInside)
    }

    // MARK: Action
    
    @objc func tappedButton(sender: DOFavoriteButton) {
        if sender.isSelected {
            sender.animateToDeselectedState()
        } else {
            sender.animateToSelectedState()
        }
    }
}

