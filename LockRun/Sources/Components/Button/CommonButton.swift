//
//  CommonButton.swift
//  LockRun
//
//  Created by 전준영 on 10/12/25.
//

import SwiftUI

struct CommonButton: View {
    let icon: Image?
    let backgroundColor: Color
    let disabledBackgroundColor: Color? = nil
    let text: ButtonTitle?
    let textColor: Color
    let symbolColor: Color?
    let cornerRadius: CGFloat
    var font: FontType? = .headline
    var borderColor: Color = .black
    var minWidth: CGFloat? = nil
    var height: CGFloat? = nil
    var isEnabled: Bool = true
    var hasBorder: Bool = false
    var hasInternalPadding: Bool = true
    var action: () -> Void
    
    var body: some View {
        Button(action: {
            if isEnabled {
                action()
            }
        }) {
            HStack(spacing: 8) {
                if let icon = icon {
                    icon
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .foregroundStyle(symbolColor ?? .primary)
                }
                if let text = text {
                    Text(text.rawValue)
                        .customFont(font ?? .headline)
                        .foregroundStyle(textColor.opacity(0.85))
                }
            }
            .padding(hasInternalPadding ? 12 : 0)
            .applyFrame(minWidth: minWidth, height: height)
            // isEnabled에 따라 배경색: 비활성일 때 disabledBackgroundColor가 nil이면 원래 색 유지
            .background(
                (isEnabled)
                ? backgroundColor
                : (disabledBackgroundColor ?? backgroundColor)
            )
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(hasBorder ? borderColor : Color.clear, lineWidth: 1)
            )
        }
        .disabled(!isEnabled)
    }
}

private extension View {
    func applyFrame(minWidth: CGFloat?, height: CGFloat?) -> some View {
        if let minWidth = minWidth, let height = height {
            return AnyView(
                self.frame(minWidth: minWidth, maxWidth: minWidth,
                           minHeight: height, maxHeight: height)
            )
        } else if let height = height {
            return AnyView(
                self.frame(maxWidth: .infinity,
                           minHeight: height, maxHeight: height)
            )
        } else if let minWidth = minWidth {
            return AnyView(
                self.frame(minWidth: minWidth, maxWidth: minWidth)
            )
        } else {
            return AnyView(
                self.frame(maxWidth: .infinity)
            )
        }
    }
}
