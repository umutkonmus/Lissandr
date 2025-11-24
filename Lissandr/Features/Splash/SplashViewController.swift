//
//  SplashViewController.swift
//  Lissandr
//
//  Created by Umut Konmuş on 24.10.2025.
//

import Foundation
import UIKit
import SnapKit

final class SplashViewController: UIViewController, SplashViewProtocol {
    var presenter: SplashPresenterProtocol!
    
    private let logo = UIImageView(image: UIImage(named: "1024"))
    private let powered = UILabel()
    private let activity = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        logo.contentMode = .scaleAspectFit
        view.addSubview(logo)
        logo.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-40)
            make.width.height.equalTo(120)
        }
        
        powered.text = "splash.poweredBy".localized
        powered.textAlignment = .center
        powered.textColor = .secondaryLabel
        powered.font = .preferredFont(forTextStyle: .footnote)
        view.addSubview(powered)
        powered.snp.makeConstraints { make in
            make.top.equalTo(logo.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }
        
        activity.hidesWhenStopped = true
        view.addSubview(activity)
        activity.snp.makeConstraints { make in
            make.top.equalTo(powered.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.viewDidAppear()
    }
    
    func showLoading(_ loading: Bool) { 
        DispatchQueue.main.async { 
            loading ? self.activity.startAnimating() : self.activity.stopAnimating() 
        } 
    }
    
    func showError(_ message: String) {
        DispatchQueue.main.async { [weak self] in
            let ac = UIAlertController(title: "common.error".localized, message: message, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "common.retry".localized, style: .default, handler: { _ in 
                self?.presenter.viewDidAppear() 
            }))
            self?.present(ac, animated: true)
        }
    }
}
