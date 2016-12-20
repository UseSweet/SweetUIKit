import UIKit

/*
 Due to how the keyboard works on iOS, to have an input bar always above it, the usual way is
 to set the _inputAccessoryView_ to the view we want to display above it and let the system take care of it.
 Sadly, this means that the input accessory view disappears from the screen if the keyboard is dismissed.
 To improve on this, what we do here is create a fake input accessory view, that has no height, and the view we wanted to use
 as the input accessory view is attached to the bottom of the screen instead.
 We use the fake accessory to access its superview (before iOS10, that was not needed, we could observe the input accessory view's own frame),
 and observe if it's _centre_ property changes. When it does, we use the superview frame to recalculate the actual input accessory view (attached
 to the main window, no the keyboard window) position. Thus, we're able to keep the input accessory always above the keyboard, but also always visible.
 */
public protocol KeyboardAwareAccessoryViewDelegate: class {
    func inputView(_ inputView: KeyboardAwareInputAccessoryView, shouldUpdatePosition keyboardMaxY: CGFloat)

    var keyboardAwareInputView: KeyboardAwareInputAccessoryView { get set }

    var inputAccessoryView: UIView? { get }
}

public class KeyboardAwareInputAccessoryView: UIView {
    public weak var delegate: KeyboardAwareAccessoryViewDelegate?

    fileprivate var storedSuperview = UIView()

    fileprivate var inputAccessoryContext = 0

    fileprivate lazy var observableKeyPath: String = {
        "self.center"
    }()

    override public func didMoveToSuperview() {
        if let superview = self.delegate?.inputAccessoryView?.superview {
            self.storedSuperview = superview
            self.storedSuperview.addObserver(self, forKeyPath: self.observableKeyPath, options: .new, context: &self.inputAccessoryContext)
        } else {
            self.storedSuperview.removeObserver(self, forKeyPath: self.observableKeyPath, context: &self.inputAccessoryContext)
        }
    }

    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == self.observableKeyPath {
            let superview = self.storedSuperview

            /*
             To get the constant we need here, to keep input view on the correct position at all times,
             we need the following:
             First, we need the visible height of the keyboard on screen. We get that by intersecting the fakeInputAccessorySuperview
             (in actuality, the UIInputSetHostView, a subview inside the keyboard window), with the app's main window.
             We then use it's negative value, as we're dealing with an inversed constraint. That's it.
             */
            guard let window = self.window else { return }
            let constant = -(superview.frame.intersection(window.bounds).height)

            self.delegate?.inputView(self, shouldUpdatePosition: constant)
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}
