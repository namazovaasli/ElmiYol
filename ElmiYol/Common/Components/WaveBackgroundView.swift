//
//  WaveBackgroundView.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 10.07.26.
//

import UIKit
import SnapKit

final class WaveBackgroundView: UIView {
    
    private let waveLayer1 = CAShapeLayer()
    private let waveLayer2 = CAShapeLayer()
    private let waveLayer3 = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
    }
    
    private func setupLayers() {
        clipsToBounds = true
        
        waveLayer1.fillColor = UIColor(red: 0.85, green: 0.91, blue: 0.99, alpha: 0.5).cgColor
        waveLayer2.fillColor = UIColor(red: 0.72, green: 0.84, blue: 0.98, alpha: 0.7).cgColor
        waveLayer3.fillColor = UIColor(red: 0.55, green: 0.74, blue: 0.96, alpha: 1).cgColor
        
        layer.addSublayer(waveLayer1)
        layer.addSublayer(waveLayer2)
        layer.addSublayer(waveLayer3)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        waveLayer1.path = wavePath(amplitude: 22, yOffset: bounds.height * 0.25, phase: 0).cgPath
        waveLayer2.path = wavePath(amplitude: 18, yOffset: bounds.height * 0.42, phase: 1.5).cgPath
        waveLayer3.path = wavePath(amplitude: 25, yOffset: bounds.height * 0.6, phase: 3).cgPath
    }
    
    func startAnimating() {
        animateWave(layer: waveLayer1, duration: 6)
        animateWave(layer: waveLayer2, duration: 8)
        animateWave(layer: waveLayer3, duration: 10)
    }
    
    private func animateWave(layer: CAShapeLayer, duration: CFTimeInterval) {
        layer.removeAnimation(forKey: "waveMove")
        let animation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.fromValue = 0
        animation.toValue = -bounds.width
        animation.duration = duration
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.isRemovedOnCompletion = false
        layer.add(animation, forKey: "waveMove")
    }
    
    private func wavePath(amplitude: CGFloat, yOffset: CGFloat, phase: CGFloat) -> UIBezierPath {
        let width = bounds.width
        let height = bounds.height
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: 0, y: yOffset))
        
        let step: CGFloat = 10
        var x: CGFloat = 0
        while x <= width {
            let y = yOffset + amplitude * sin((x / width) * .pi * 2 + phase)
            path.addLine(to: CGPoint(x: x, y: y))
            x += step
        }
        
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.close()
        
        return path
    }
}
