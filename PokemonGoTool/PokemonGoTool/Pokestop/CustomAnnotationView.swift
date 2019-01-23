//
//  CustomAnnotationView.swift
//  PokemapTool
//
//  Created by Nico on 27.02.18.
//  Copyright © 2018 NST. All rights reserved.
//

import UIKit
import MapKit

class CustomAnnotationView: MKAnnotationView {

    weak var customCalloutView: UIView?
    var label = UILabel()

    override func didMoveToSuperview() {
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 10)
        label.textAlignment = .center
        label.backgroundColor = UIColor(white: 1, alpha: 0.7)
        label.numberOfLines = 0
        label.layer.cornerRadius = 2
        label.layer.borderColor = UIColor.black.cgColor
        label.layer.borderWidth = 0.5
        label.clipsToBounds = true
        let padding: CGFloat = 5
        label.frame = CGRect(x: -label.intrinsicContentSize.width/2 + frame.width/2 - padding/2,
                             y: frame.height - 28,
                             width: label.intrinsicContentSize.width + padding,
                             height: label.intrinsicContentSize.height)
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        canShowCallout = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        canShowCallout = false
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        image = nil
        label.removeFromSuperview()
        customCalloutView?.removeFromSuperview()
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // if super passed hit test, return the result
        if let parentHitView = super.hitTest(point, with: event) { return parentHitView }
        else { // test in our custom callout.
            if customCalloutView != nil {
                return customCalloutView!.hitTest(convert(point, to: customCalloutView!), with: event)
            } else { return nil }
        }
    }
}
