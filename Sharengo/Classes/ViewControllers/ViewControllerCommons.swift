
import Foundation
import RxCocoa
import RxSwift
import Action
import Boomerang
import UIKit
import pop
import MBProgressHUD
import SpinKit
import Localize_Swift
import AVKit

enum SharedSelectionOutput : SelectionOutput {
    case exit
    case dismiss
    case restart
    case url(URL?)
    case preview(URL?)
    case playVideo(URL?)
    case confirm(title:String,message:String,confirmTitle:String,action:((Void)->()))
}

class NavigationController : UINavigationController, UINavigationBarDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        switch UIDevice.current.userInterfaceIdiom {
        case .pad : return .landscape
        default : return .portrait
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
        
    }
    override var shouldAutorotate: Bool {
        return false
    }
}

extension UIView {
    func findFirstResponder() -> UIView? {
        if (self.isFirstResponder) {
            return self
        }
        if (self.subviews.count == 0) {
            return nil
        }
        return self.subviews.map {$0.findFirstResponder() ?? self}.filter {$0 != self}.first
    }
}

protocol KeyboardResizable  {
    var bottomConstraint:NSLayoutConstraint! {get set}
    var scrollView:UIScrollView {get}
    var keyboardResize: Observable<CGFloat> {get}
}

extension KeyboardResizable where Self : UIViewController {
    var keyboardResize: Observable<CGFloat>  {
        self.scrollView.keyboardDismissMode = .onDrag
        let original:CGFloat = self.bottomConstraint.constant
        var currentBottomSpace:CGFloat = 0.0
        let willShow = NotificationCenter.default.rx.notification(NSNotification.Name.UIKeyboardWillShow)
        let willHide = NotificationCenter.default.rx.notification(NSNotification.Name.UIKeyboardWillHide)
        let merged = Observable.of(willShow,willHide).merge()
        
        let vc = self as UIViewController
        return
            merged
                .takeUntil(vc.rx.deallocating)
                .throttle(0.1, scheduler:MainScheduler.instance)
                .scan(self.bottomConstraint.constant, accumulator: {[weak self] (value:CGFloat, notification:Notification) -> CGFloat in
                    if self == nil {
                        return 0
                    }
                    let isShowing = notification.name == .UIKeyboardWillShow
                    currentBottomSpace = isShowing ? self!.finalConstraintValueValueForKeyboardOpen(frame: (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? CGRect(x:0,y:0,width:0,height:0) ) : original
                    
                    let duration:Double = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double ?? 0.25
                    
                    let animation = POPBasicAnimation(propertyNamed: kPOPLayoutConstraintConstant)!
                    animation.duration = duration
                    animation.toValue = currentBottomSpace
                    animation.completionBlock = { animation, completed in
                        if completed {
                            let view = self?.scrollView.findFirstResponder()
                            if view != nil {
                                var frame = view!.convert(view!.frame, to: self!.scrollView)
                                frame.origin.y += 20
                                self?.scrollView.scrollRectToVisible(frame, animated: true)
                            }
                        }
                    }
                    self!.bottomConstraint.pop_add(animation, forKey: "constraint")
                    return currentBottomSpace
                })
    }
    func finalConstraintValueValueForKeyboardOpen(frame:CGRect) -> CGFloat {
        return frame.size.height
    }
}

protocol Collectionable {
    weak var collectionView:UICollectionView! {get}
    func setupCollectionView()
}

extension Collectionable where Self : UIViewController {
    func setupCollectionView() {
        self.collectionView.backgroundColor = .clear
    }
}

public class BaseViewController: UIViewController {
    override public var prefersStatusBarHidden: Bool {
        return false
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        CoreController.shared.currentViewController = self
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(BaseViewController.updateData), name: NSNotification.Name(rawValue: "updateData"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Update methods
    
    @objc fileprivate func updateData() {
        let carTrip = CoreController.shared.currentCarTrip
        let carBooking = CoreController.shared.currentCarBooking
        let dispatchTime = DispatchTime.now() + 2
        DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
            if CoreController.shared.notificationIsShowed == false {
                if CoreController.shared.allCarTrips.first != nil {
                } else if let carTrip = carTrip {
                    CoreController.shared.notificationIsShowed = true
                    NotificationsController.showNotification(title: "banner_carBookingCompletedTitle".localized(), description: String(format: "banner_carBookingCompletedDescription".localized(), carTrip.time), carTrip: carTrip, source: self)
                }
                if CoreController.shared.allCarBookings.first != nil {
                } else if carBooking != nil {
                    CoreController.shared.notificationIsShowed = true
                    NotificationsController.showNotification(title: "banner_carBookingDeletedTitle".localized(), description: "banner_carBookingDeletedDescription".localized(), carTrip: nil, source: self)
                }
            }
        }
    }
}

extension UIViewController {
    private struct AssociatedKeys {
        static var loaderCount = "loaderCount"
        static var disposeBag = "vc_disposeBag"
        static var loadingViewController = "loadingViewController"
        static var menuBackgroundView = "menuBackgroundView"
    }
    
    public var disposeBag: DisposeBag {
        var disposeBag: DisposeBag
        if let lookup = objc_getAssociatedObject(self, &AssociatedKeys.disposeBag) as? DisposeBag {
            disposeBag = lookup
        } else {
            disposeBag = DisposeBag()
            objc_setAssociatedObject(self, &AssociatedKeys.disposeBag, disposeBag, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        return disposeBag
    }
    
    func setup() -> UIViewController {
        let closure = {
            (self as? Collectionable)?.setupCollectionView()
            
            if ((self.navigationController?.viewControllers.count ?? 0) > 1) {
                _ = self.withBackButton()
            }
        }
        self.automaticallyAdjustsScrollViewInsets = false
        if (self.isViewLoaded) {
            closure()
        }
        else {
            _ = self.rx.methodInvoked(#selector(viewDidLoad)).delay(0.0, scheduler: MainScheduler.instance).subscribe(onNext:{_ in closure()})
        }
        return self
    }
    
    func back() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func withBackButton() -> UIViewController {
        let item = UIBarButtonItem(image: UIImage(named: "ic_back"), style: .done, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = item
        return self
    }
    
    private var loaderCount:Int {
        get { return objc_getAssociatedObject(self, &AssociatedKeys.loaderCount) as? Int ?? 0}
        set { objc_setAssociatedObject(self, &AssociatedKeys.loaderCount, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)}
    }
    
    private var loadingViewController:LoadingViewController? {
        get { return objc_getAssociatedObject(self, &AssociatedKeys.loadingViewController) as? LoadingViewController ?? nil}
        set { objc_setAssociatedObject(self, &AssociatedKeys.loadingViewController, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)}
    }
    
    private var menuBackgroundView:UIView? {
        get { return objc_getAssociatedObject(self, &AssociatedKeys.menuBackgroundView) as? UIView ?? nil}
        set { objc_setAssociatedObject(self, &AssociatedKeys.menuBackgroundView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)}
    }
    
    func loaderView() -> UIView {
        return RTSpinKitView(style: .stylePulse, color: UIColor.red, spinnerSize: 44)
    }
    
    func loaderContentView() -> UIView {
        return self.view
    }
    
    func showLoader() {
        if (self.loaderCount == 0) {
            DispatchQueue.main.async {[unowned self] in
                if self.loadingViewController != nil {
                    self.loadingViewController!.view.removeFromSuperview()
                    self.loadingViewController!.removeFromParentViewController()
                }
                self.loadingViewController = (Storyboard.main.scene(.loading))
                self.loadingViewController!.view.alpha = 0.0
                self.addChildViewController(self.loadingViewController!)
                self.loaderContentView().addSubview(self.loadingViewController!.view)
                self.loadingViewController!.view.snp.makeConstraints { (make) -> Void in
                    make.left.equalTo(self.loaderContentView().snp.left)
                    make.right.equalTo(self.loaderContentView().snp.right)
                    make.top.equalTo(self.loaderContentView().snp.top)
                    make.bottom.equalTo(self.loaderContentView().snp.bottom)
                }
                UIView.animate(withDuration: 0.2, animations: {
                    self.loadingViewController!.view.alpha = 1.0
                })
            }
        }
        self.loaderCount += 1
    }
    
    func hideLoader() {
        DispatchQueue.main.async {[weak self]  in
            if (self == nil) {
                return
            }
            self!.loaderCount = max(0, (self!.loaderCount ) - 1)
            if (self!.loaderCount == 0) {
                if self?.loadingViewController != nil {
                    self?.loadingViewController!.view.removeFromSuperview()
                    self?.loadingViewController!.removeFromParentViewController()
                }
            }
        }
    }
    
    func showMenuBackground() {
        if self.menuBackgroundView == nil {
            self.menuBackgroundView = UIView(frame: self.view.frame)
            self.menuBackgroundView!.backgroundColor = ColorBrand.green.value
            self.menuBackgroundView!.alpha = 0.0
            self.view.addSubview(self.menuBackgroundView!)
            
            UIView.animate(withDuration: 0.3, animations: {
                self.menuBackgroundView!.alpha = 0.7
            })
        }
    }
    
    func hideMenuBackground() {
        UIView.animate(withDuration: 0.3, animations: {
            if self.menuBackgroundView != nil {
                self.menuBackgroundView!.alpha = 0.0
            }
        }, completion: { (success) in
            if self.menuBackgroundView != nil {
                self.menuBackgroundView!.removeFromSuperview()
                self.menuBackgroundView = nil
            }
        })
    }
    
    func sharedSelection(_ output:SelectionOutput) {
        guard let shared = output as? SharedSelectionOutput else {
            return
        }
        switch shared {
        case .restart:
            Router.restart()
        case .url(let url) :
            Router.open(url, from: self).execute()
        case .preview(let url) :
            Router.preview(url, from: self).execute()
        case .exit:
            Router.exit(self)
        case .dismiss:
            Router.dismiss(self)
        case .confirm(let title, let message, let confirmTitle, let action) :
            Router.confirm(title: title, message: message, confirmationTitle: confirmTitle, from: self, action: action).execute()
        case .playVideo(let url):
            Router.playVideo(url, from: self).execute()
            break
        }
    }
    
    func showError(_ error:ActionError) {
    }
}
