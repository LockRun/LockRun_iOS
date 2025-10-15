//
//  CustomNavigationBarModifier.swift
//  LockRun
//
//  Created by 전준영 on 10/13/25.
//

import SwiftUI

enum NavigationBarTrailingType {
    case none
    case customView(AnyView)
}

struct CustomNavigationBarModifier: ViewModifier {
    
    @Environment(\.dismiss) private var dismiss
    let trailingType: NavigationBarTrailingType
    let title: String?
    var isPush: Bool?
    var centerTitle: Bool?
    
    init(trailingType: NavigationBarTrailingType = .none,
         isPush: Bool? = false,
         centerTitle: Bool? = false,
         title: String? = nil) {
        self.trailingType = trailingType
        self.isPush = isPush
        self.centerTitle = centerTitle
        self.title = title
    }
    
    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(isPush!)
            .toolbar {
                if isPush! == true {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .foregroundStyle(.white)
                        }
                        
                    }
                }
                
                ToolbarItem(placement: centerTitle! ? .principal : .topBarLeading) {
                    CommonText(text: title ?? "",
                               font: centerTitle! ? .regular20 : .regular24)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    switch trailingType {
                    case .none:
                        EmptyView()
                        
                    case .customView(let view):
                        view
                    }
                }
            }
    }
}

extension View {
    func customNavigationBar(
        title: String? = nil,
        trailing: NavigationBarTrailingType = .none,
        centerTitle: Bool = false,
        isPush: Bool = false,
    ) -> some View {
        self.modifier(CustomNavigationBarModifier(trailingType: trailing,
                                                  isPush: isPush,
                                                  centerTitle: centerTitle,
                                                  title: title))
    }
}
