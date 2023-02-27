//
//  LoadingViewController.swift
//  Signly
//
//  Created by Сергей Никитин on 03.09.2022.
//

import UIKit

class LoadingViewController {
    
    static var title: String = ""
    
    private static var container: UIView = UIView()
    private static var loadingView: UIImageView = UIImageView()
    private static var titleLabel: UILabel = UILabel()
    
    private static var loadingHeight: CGFloat {
        return LoadingViewController.title.isEmpty ? 100 : 48
    }
    
    func showLoading(view: UIView, showProgress: Bool = false) {
        OperationQueue.main.addOperation {
            LoadingViewController.container.frame = view.frame
            LoadingViewController.container.center = view.center
            LoadingViewController.container.backgroundColor = UIColor(red: 0.333, green: 0.29, blue: 0.941, alpha: 0.52)
            
            LoadingViewController.loadingView.frame = CGRect(x: 0,
                                                             y: 0,
                                                             width: LoadingViewController.loadingHeight,
                                                             height: LoadingViewController.loadingHeight)
            LoadingViewController.loadingView.image = UIImage(named: "loading")
            LoadingViewController.loadingView.tintColor = .white
            LoadingViewController.loadingView.clipsToBounds = true
            LoadingViewController.loadingView.center = view.center
            LoadingViewController.loadingView.rotate()
            
            LoadingViewController.titleLabel.frame = CGRect(x: 30, y: 0, width: view.bounds.width - 60, height: 30)
            LoadingViewController.titleLabel.center = CGPoint(x: view.center.x,
                                                              y: view.center.y + LoadingViewController.loadingHeight / 2 + 25)
            LoadingViewController.titleLabel.textAlignment = .center
            LoadingViewController.titleLabel.clipsToBounds = true
            LoadingViewController.titleLabel.numberOfLines = 0
            LoadingViewController.titleLabel.textColor = .white
            LoadingViewController.titleLabel.font = .appHeadline3
            LoadingViewController.titleLabel.text = LoadingViewController.title
            
            guard LoadingViewController.title.isEmpty else {
                LoadingViewController.container.addSubview(LoadingViewController.loadingView)
                LoadingViewController.container.addSubview(LoadingViewController.titleLabel)
                view.addSubview(LoadingViewController.container)
                return
            }
        
            LoadingViewController.container.addSubview(LoadingViewController.loadingView)
            view.addSubview(LoadingViewController.container)
        }
    }
    
    func hideLoading() {
        OperationQueue.main.addOperation {
            LoadingViewController.container.removeFromSuperview()
        }
    }
}

