//
//  AsyncImageView.swift
//  UIKitBase
//
//  Created by Brian Strobach on 9/26/22.
//

public class AsyncImageView: BaseImageView {
    public var imageResolver: ImageResolving?
    public init(_ imageResolver: ImageResolving) {
        self.imageResolver = imageResolver
        super.init(callInitLifecycle: true)
    }
    public override func initProperties() {
        super.initProperties()
        contentMode = .scaleAspectFit
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func didFinishCreatingAllViews() {
        super.didFinishCreatingAllViews()
        if let imageResolver = imageResolver {
            let _ = try? self.loadImage(imageResolver)
        }
    }
}
