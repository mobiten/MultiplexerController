import UIKit

final public class MultiplexerController<T>: UIViewController {
    var state: T
    var animationDuration: TimeInterval = 0.125

    private weak var dataSource: AnyMultiplexerControllerDataSource? = nil

    public init(initialState: T) {
        self.state = initialState

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: SCREEN SWITCHING MANAGEMENT
    private weak var presentedController: UIViewController?

    public override func viewDidLoad() {
        super.viewDidLoad()

        guard let controller = dataSource?._controller(for: self, inState: state) else {
            return
        }

        self.presentedController = controller
        insert(controller)
    }

    private weak var runningAnimation: UIViewPropertyAnimator?

    public func set(_ state: T, animated: Bool) {
        self.state = state

        guard let controller = dataSource?._controller(for: self, inState: state),
              let previouslyPresentedController = presentedController else {
            return
        }

        let preAnimationSetup = {
            self.presentedController = controller
            self.insert(controller)
            controller.view.alpha = 0.0
        }

        let duration: TimeInterval = animated ? animationDuration : 0.0

        let animator = UIViewPropertyAnimator(duration: duration, curve: .linear) {
            previouslyPresentedController.view.alpha = 0.0
            controller.view.alpha = 1.0
            self.setNeedsStatusBarAppearanceUpdate()
        }

        animator.addCompletion { (position) in
            self.remove(previouslyPresentedController)
        }

        let activateAnimator = {
            preAnimationSetup()
            self.runningAnimation = animator
            animator.startAnimation()
        }

        if let runningAnimation = runningAnimation {
            runningAnimation.addCompletion { (position) in
                if position != .end {
                    return
                }
                activateAnimator()
            }
            runningAnimation.stopAnimation(false)
            runningAnimation.finishAnimation(at: .end)
        } else {
            activateAnimator()
        }
    }

    private func remove(_ controller: UIViewController) {
        controller.willMove(toParent: nil)
        controller.view.removeFromSuperview()
        controller.removeFromParent()
    }

    private func insert(_ controller: UIViewController) {
        addChild(controller)

        let embeddedView = controller.view!

        view.addSubview(embeddedView)
        embeddedView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            embeddedView.leftAnchor.constraint(equalTo: view.leftAnchor),
            embeddedView.rightAnchor.constraint(equalTo: view.rightAnchor),
            embeddedView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            embeddedView.topAnchor.constraint(equalTo: view.topAnchor),
        ])

        controller.didMove(toParent: self)
    }

    // MARK: DATASOURCE MANAGEMENT
    public func setDataSource<S: MultiplexerControllerDataSource>(_ source: S)
            where S.StateType == T {
        self.dataSource = source
    }

    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return presentedController?.preferredStatusBarStyle ?? UIStatusBarStyle.lightContent
    }
}

// MARK: DELEGATES TO HAVE (SORT OF) GENERIC DELEGATES
public protocol AnyMultiplexerControllerDataSource: class {
    func _controller(for controller: Any, inState state: Any) -> UIViewController
}

public protocol MultiplexerControllerDataSource: AnyMultiplexerControllerDataSource {
    associatedtype StateType

    func controller(for controller: MultiplexerController<StateType>, inState state: StateType) -> UIViewController
}

public extension MultiplexerControllerDataSource {
    func _controller(for multiplexerController: Any, inState state: Any) -> UIViewController {
        if let typedState = state as? StateType,
           let typedController = multiplexerController as? MultiplexerController<StateType> {
            return self.controller(for: typedController, inState: typedState)
        } else {
            fatalError("This should not happen as type erasure should be implemented properly but just in case...")
        }
    }
}
