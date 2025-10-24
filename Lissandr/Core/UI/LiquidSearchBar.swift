//
//  LiquidSearchBar.swift
//  Lissandr
//
//  Created by Umut Konmuş on 24.10.2025.
//

import UIKit
import SnapKit

final class LiquidSearchBar: UIView, UITextFieldDelegate {
    let textField = UITextField()
    var onSubmit: ((String) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) { super.init(coder: coder); setup() }
    
    private func setup() {
        backgroundColor = UIColor.systemBackground.withAlphaComponent(0.6)
        layer.cornerRadius = 18
        layer.masksToBounds = true
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.08
        layer.shadowRadius = 12
        
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
        addSubview(blur)
        blur.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        addSubview(textField)
        textField.borderStyle = .none
        textField.placeholder = "Arayın"
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .search
        textField.delegate = self
        textField.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let q = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !q.isEmpty {
            onSubmit?(q)
        }
        textField.resignFirstResponder()
        return true
    }
}
