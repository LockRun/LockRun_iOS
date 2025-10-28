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
    var spacing: CGFloat = 8
    var alignLeft: Bool = false
    var isIconOnly: Bool = false
    var haptic: Bool = false
    var action: () -> Void
    
    var body: some View {
        Button(action: {
            if isEnabled {
                if haptic {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                }
                action()
            }
        }) {
            HStack(spacing: isIconOnly ? 0 : spacing) {
                if let icon = icon {
                    icon
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: isIconOnly ? 16 : 20,
                               height: isIconOnly ? 16 : 20)
                        .foregroundStyle(symbolColor ?? .primary)
                }
                if let text = text, !isIconOnly {
                    Text(text.rawValue)
                        .customFont(font ?? .headline)
                        .foregroundStyle(textColor.opacity(0.85))
                }
                if alignLeft && !isIconOnly { Spacer() }
            }
            .padding(isIconOnly ? 6 : (hasInternalPadding ? 12 : 0))
            .frame(
                minWidth: isIconOnly ? nil : minWidth,
                maxWidth: isIconOnly ? nil : .infinity,
                minHeight: isIconOnly ? nil : height,
                maxHeight: isIconOnly ? nil : height
            )
            .background(isEnabled ? backgroundColor : (disabledBackgroundColor ?? backgroundColor))
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
