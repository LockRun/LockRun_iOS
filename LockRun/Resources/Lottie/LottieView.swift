//
//  LottieView.swift
//  LockRun
//
//  Created by 전준영 on 10/27/25.
//

import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    let name: String
    var loopMode: LottieLoopMode = .playOnce
    var completion: (() -> Void)? = nil
    
    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        
        let animationView = LottieAnimationView(name: name)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = loopMode
        animationView.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            animationView.topAnchor.constraint(equalTo: container.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        animationView.play { finished in
            if finished { completion?() }
        }
        
        return container
    }
    
    func updateUIView(_ uiView: UIView, context: Context) { }
}

