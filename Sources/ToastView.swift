import UIKit

open class ToastView: UIView {

  // MARK: Properties

  open var text: String? {
    get { return self.textLabel.text }
    set { self.textLabel.text = newValue }
  }

  open var attributedText: NSAttributedString? {
    get { return self.textLabel.attributedText }
    set { self.textLabel.attributedText = newValue }
  }
  

  // MARK: Appearance

  /// The background view's color.
  override open dynamic var backgroundColor: UIColor? {
    get { return self.backgroundView.backgroundColor }
    set { self.backgroundView.backgroundColor = newValue }
  }

  /// The background view's corner radius.
  @objc open dynamic var cornerRadius: CGFloat {
    get { return self.backgroundView.layer.cornerRadius }
    set { self.backgroundView.layer.cornerRadius = newValue }
  }

  /// The inset of the text label.
  @objc open dynamic var textInsets = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)

  /// The color of the text label's text.
  @objc open dynamic var textColor: UIColor? {
    get { return self.textLabel.textColor }
    set { self.textLabel.textColor = newValue }
  }

  /// The font of the text label.
  @objc open dynamic var font: UIFont? {
    get { return self.textLabel.font }
    set { self.textLabel.font = newValue }
  }

  /// The bottom offset from the screen's bottom in portrait mode.
  @objc open dynamic var bottomOffsetPortrait: CGFloat = {
    switch UIDevice.current.userInterfaceIdiom {
    // specific values
    case .phone: return 30
    case .pad: return 60
    case .tv: return 90
    case .carPlay: return 30
    // default values
    case .unspecified: fallthrough
    @unknown default: return 30
    }
  }()

  /// The bottom offset from the screen's bottom in landscape mode.
  @objc open dynamic var bottomOffsetLandscape: CGFloat = {
    switch UIDevice.current.userInterfaceIdiom {
    // specific values
    case .phone: return 20
    case .pad: return 40
    case .tv: return 60
    case .carPlay: return 20
    // default values
    case .unspecified: fallthrough
    @unknown default: return 20
    }
  }()
  
  /// If this value is `true` and SafeArea is available,
  /// `safeAreaInsets.bottom` will be added to the `bottomOffsetPortrait` and `bottomOffsetLandscape`.
  /// Default value: false
  @objc open dynamic var useSafeAreaForBottomOffset: Bool = false

  /// if this value is `true`, the toast would be showing from top of the screem
  @objc open dynamic var fromTop: Bool = false

  /// The top offset from the screen's bottom in portrait mode.
  @objc open dynamic var topOffsetPortrait: CGFloat = 0

  /// The top offset from the screen's bottom in landscape mode.
  @objc open dynamic var topOffsetLandscape: CGFloat = 0

  /// If this value is `true` and SafeArea is available,
  /// `safeAreaInsets.top` will be added to the `topOffsetPortrait` and `topOffsetLandscape`.
  /// Default value: true
  @objc open dynamic var useSafeAreaForTopOffset: Bool = true

  /// The width ratio of toast view in window, specified as a value from 0.0 to 1.0.
  /// Default value: 0.875
  @objc open dynamic var maxWidthRatio: CGFloat = (280.0 / 320.0)
  
  /// The shape of the layer’s shadow.
  @objc open dynamic var shadowPath: CGPath? {
    get { return self.layer.shadowPath }
    set { self.layer.shadowPath = newValue }
  }
  
  /// The color of the layer’s shadow.
  @objc open dynamic var shadowColor: UIColor? {
    get { return self.layer.shadowColor.flatMap { UIColor(cgColor: $0) } }
    set { self.layer.shadowColor = newValue?.cgColor }
  }
  
  /// The opacity of the layer’s shadow.
  @objc open dynamic var shadowOpacity: Float {
    get { return self.layer.shadowOpacity }
    set { self.layer.shadowOpacity = newValue }
  }
  
  /// The offset (in points) of the layer’s shadow.
  @objc open dynamic var shadowOffset: CGSize {
    get { return self.layer.shadowOffset }
    set { self.layer.shadowOffset = newValue }
  }
  
  /// The blur radius (in points) used to render the layer’s shadow.
  @objc open dynamic var shadowRadius: CGFloat {
    get { return self.layer.shadowRadius }
    set { self.layer.shadowRadius = newValue }
  }

  // MARK: UI

  private let backgroundView: UIView = {
    let `self` = UIView()
    self.backgroundColor = UIColor(white: 0, alpha: 0.7)
    self.layer.cornerRadius = 5
    self.clipsToBounds = true
    return self
  }()
  
  private let textLabel: UILabel = {
    let `self` = UILabel()
    self.textColor = .white
    self.backgroundColor = .clear
    self.font = {
      switch UIDevice.current.userInterfaceIdiom {
      // specific values
      case .phone: return .systemFont(ofSize: 12)
      case .pad: return .systemFont(ofSize: 16)
      case .tv: return .systemFont(ofSize: 20)
      case .carPlay: return .systemFont(ofSize: 12)
      // default values
      case .unspecified: fallthrough
      @unknown default: return .systemFont(ofSize: 12)
      }
    }()
    self.numberOfLines = 0
    self.textAlignment = .center
    return self
  }()


  // MARK: Initializing
  var onTap: (() -> ())? {
    didSet {
      self.isUserInteractionEnabled = self.onTap != nil
    }
  }

  private let tapRecognizer = UITapGestureRecognizer()
  public init() {
    super.init(frame: .zero)
    self.isUserInteractionEnabled = true
    self.addSubview(self.backgroundView)
    self.addSubview(self.textLabel)
    tapRecognizer.addTarget(self, action: #selector(didTap))
    tapRecognizer.delegate = self
    addGestureRecognizer(self.tapRecognizer)
  }

  required convenience public init?(coder aDecoder: NSCoder) {
    self.init()
  }

  @objc
  func didTap() {
    self.onTap?()
  }

  // MARK: Layout

  override open func layoutSubviews() {
    super.layoutSubviews()
    let containerSize = ToastWindow.shared.frame.size
    let constraintSize = CGSize(
      width: containerSize.width * maxWidthRatio - self.textInsets.left - self.textInsets.right,
      height: CGFloat.greatestFiniteMagnitude
    )
    let textLabelSize = self.textLabel.sizeThatFits(constraintSize)
    self.textLabel.frame = CGRect(
      x: self.textInsets.left,
      y: self.textInsets.top,
      width: textLabelSize.width,
      height: textLabelSize.height
    )
    self.backgroundView.frame = CGRect(
      x: 0,
      y: 0,
      width: self.textLabel.frame.size.width + self.textInsets.left + self.textInsets.right,
      height: self.textLabel.frame.size.height + self.textInsets.top + self.textInsets.bottom
    )

    var x: CGFloat
    var y: CGFloat
    var width: CGFloat
    var height: CGFloat

    let orientation = UIApplication.shared.statusBarOrientation

    if fromTop {
      if orientation.isPortrait || !ToastWindow.shared.shouldRotateManually {
        width = containerSize.width
        height = containerSize.height
        y = self.topOffsetPortrait
      } else {
        width = containerSize.height
        height = containerSize.width
        y = self.topOffsetLandscape
      }
      if #available(iOS 11.0, *), useSafeAreaForTopOffset {
        y += ToastWindow.shared.safeAreaInsets.top
      }

      let backgroundViewSize = self.backgroundView.frame.size
      x = (width - backgroundViewSize.width) * 0.5
      self.frame = CGRect(
        x: x,
        y: y,
        width: backgroundViewSize.width,
        height: backgroundViewSize.height
      )
    } else {
      if orientation.isPortrait || !ToastWindow.shared.shouldRotateManually {
        width = containerSize.width
        height = containerSize.height
        y = self.bottomOffsetPortrait
      } else {
        width = containerSize.height
        height = containerSize.width
        y = self.bottomOffsetLandscape
      }
      if #available(iOS 11.0, *), useSafeAreaForBottomOffset {
        y += ToastWindow.shared.safeAreaInsets.bottom
      }

      let backgroundViewSize = self.backgroundView.frame.size
      x = (width - backgroundViewSize.width) * 0.5
      y = height - (backgroundViewSize.height + y)
      self.frame = CGRect(
        x: x,
        y: y,
        width: backgroundViewSize.width,
        height: backgroundViewSize.height
      )
    }
  }

  override open func hitTest(_ point: CGPoint, with event: UIEvent!) -> UIView? {
    if let superview = self.superview {
      let pointInWindow = self.convert(point, to: superview)
      let contains = self.frame.contains(pointInWindow)
      if contains && self.isUserInteractionEnabled {
        return self
      }
    }
    return nil
  }

}

extension ToastView: UIGestureRecognizerDelegate {
}
