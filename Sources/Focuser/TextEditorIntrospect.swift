//
//  SwiftUIView.swift
//  
//
//  Created by Augustinas Malinauskas on 13/09/2021.
//

import SwiftUI

class TextViewObserver: NSObject, UITextViewDelegate {
    var didBeginEditing: (() -> Void)?
    weak var forwardToDelegate: UITextViewDelegate?

    @available(iOS 2.0, *)
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        forwardToDelegate?.textViewShouldBeginEditing?(textView) ?? true
    }

    @available(iOS 2.0, *)
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        forwardToDelegate?.textViewShouldEndEditing?(textView) ?? true
    }

    @available(iOS 2.0, *)
    func textViewDidBeginEditing(_ textView: UITextView) {
        didBeginEditing?()
        forwardToDelegate?.textViewDidBeginEditing?(textView)
    }

    @available(iOS 2.0, *)
    func textViewDidEndEditing(_ textView: UITextView) {
        forwardToDelegate?.textViewDidEndEditing?(textView)
    }

    @available(iOS 2.0, *)
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        forwardToDelegate?.textView?(textView, shouldChangeTextIn: range, replacementText: text) ?? true
    }

    @available(iOS 2.0, *)
    func textViewDidChange(_ textView: UITextView) {
        forwardToDelegate?.textViewDidChange?(textView)
    }

    
    @available(iOS 2.0, *)
    func textViewDidChangeSelection(_ textView: UITextView) {
        forwardToDelegate?.textViewDidChangeSelection?(textView)
    }

    @available(iOS 10.0, *)
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return forwardToDelegate?.textView?(textView, shouldInteractWith: URL, in: characterRange, interaction: interaction) ?? true
    }

    @available(iOS 10.0, *)
    func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return forwardToDelegate?.textView?(textView, shouldInteractWith: textAttachment, in: characterRange, interaction: interaction) ?? true
    }

    @available(iOS 16.0, *)
    func textView(_ textView: UITextView, editMenuForTextIn range: NSRange, suggestedActions: [UIMenuElement]) -> UIMenu? {
        return forwardToDelegate?.textView?(textView, editMenuForTextIn: range, suggestedActions: suggestedActions) ?? nil
    }

    @available(iOS 16.0, *)
    func textView(_ textView: UITextView, willPresentEditMenuWith animator: UIEditMenuInteractionAnimating) {
        forwardToDelegate?.textView?(textView, willPresentEditMenuWith: animator)
    }

    @available(iOS 16.0, *)
    func textView(_ textView: UITextView, willDismissEditMenuWith animator: UIEditMenuInteractionAnimating) {
        forwardToDelegate?.textView?(textView, willDismissEditMenuWith: animator)
    }
}

public struct FocusModifierTextEditor<Value: Hashable>: ViewModifier {
    @Binding var focusedField: Value?
    var equals: Value
    @State var observer = TextViewObserver()
    
    public func body(content: Content) -> some View {
        content
            .introspectTextView { tv in
                if !(tv.delegate is TextViewObserver) {
                    observer.forwardToDelegate = tv.delegate
                    tv.delegate = observer
                }
                
                observer.didBeginEditing = {
                    if focusedField != equals {
                        focusedField = equals
                    }
                }
                
                if focusedField == equals {
                    if !tv.isFirstResponder {
                        tv.becomeFirstResponder()
                    }
                }
            }
            .simultaneousGesture(TapGesture().onEnded {
                if focusedField != equals {
                    focusedField = equals
                }
            })
    }
}
