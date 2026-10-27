//
//  BackButton.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 22.10.26.
//

import UIKit

final class BackButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = AppColors.surface
        tintColor = AppColors.primary
        setImage(UIImage(systemName: "arrow.left"), for: .normal)
        layer.cornerRadius = 24
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.06
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 6
        accessibilityLabel = "Geri"
    }
}
