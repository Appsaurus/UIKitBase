import Nuke
import Swiftest
/// /
/// /  ImageDisplayable.swift
/// /  UIKitBase
/// /
/// /  Created by Brian Strobach on 12/11/18.
/// /  Copyright © 2018 Brian Strobach. All rights reserved.
/// /
//
import UIKit

public extension Nuke_ImageDisplaying where Self: UIView {
    @discardableResult
    func loadImage(_ imageResolving: ImageResolving,
                   options: ImageLoadingOptions = .shared,
                   progress: ImageTask.ProgressHandler? = nil,
                   completion: ImageTask.Completion? = nil) throws -> ImageTask?
    {
        switch imageResolving {
        case let .image(image):
            nuke_display(image: image)
            return nil
        case let .url(urlConvertible):
            return try self.loadImage(with: urlConvertible, options: options, progress: progress, completion: completion)
        }
    }

    @discardableResult
    func loadImage(_ imageResolving: ImageResolving,
                   options: ImageLoadingOptions = .shared,
                   progress: ImageTask.ProgressHandler? = nil,
                   completion: ImageTask.Completion? = nil,
                   errorImage: PlatformImage?) -> ImageTask?
    {
        do {
            return try self.loadImage(imageResolving, options: options, progress: progress, completion: completion)
        } catch {
            nuke_display(image: errorImage)
            return nil
        }
    }

    @discardableResult
    func loadImage(with url: URLConvertible,
                   options: ImageLoadingOptions = .shared,
                   progress: ImageTask.ProgressHandler? = nil,
                   completion: ImageTask.Completion? = nil) throws -> ImageTask?
    {
        return try self.loadImage(with: url.assertURL(), options: options, progress: progress, completion: completion)
    }

    @discardableResult
    func loadImage(with url: URLConvertible,
                   options: ImageLoadingOptions = .shared,
                   progress: ImageTask.ProgressHandler? = nil,
                   completion: ImageTask.Completion? = nil,
                   errorImage: PlatformImage?) -> ImageTask?
    {
        do {
            return try self.loadImage(with: url, options: options, progress: progress, completion: completion)
        } catch {
            nuke_display(image: errorImage)
            return nil
        }
    }

    @discardableResult
    func loadImage(with url: URL,
                   options: ImageLoadingOptions = .shared,
                   progress: ImageTask.ProgressHandler? = nil,
                   completion: ImageTask.Completion? = nil) -> ImageTask?
    {
        Nuke.cancelRequest(for: self)
        return Nuke.loadImage(with: url, options: options, into: self, progress: progress, completion: completion)
    }

    @discardableResult
    func loadImage(with url: URL,
                   requestOptions: ImageRequestOptions? = nil,
                   loadingOptions: ImageLoadingOptions = .shared,
                   progress: ImageTask.ProgressHandler? = nil,
                   processors: [ImageProcessing] = [],
                   completion: ImageTask.Completion? = nil) -> ImageTask?
    {
        Nuke.cancelRequest(for: self)
        let request = ImageRequest(url: url, processors: processors, options: requestOptions ?? .init())
        return Nuke.loadImage(with: request, options: loadingOptions, into: self, progress: progress, completion: completion)
    }

    func resetImage() {
        Nuke.cancelRequest(for: self)
        nuke_display(image: nil)
    }
}

extension UIButton: Nuke_ImageDisplaying {
    public func display(image: PlatformImage?) {
        imageView?.image = image
    }

    public func nuke_display(image: PlatformImage?) {
        imageView?.image = image
    }
}

public enum ImageResolving {
    case image(UIImage)
    case url(URLConvertible)
}

//
// public typealias AsyncCompletion<S, E: Error> = (success: (S) -> Void, failure: (E) -> Void)
//
// public protocol URLImageResolvable{
//    func resolve(imageAt url: URL, complete: AsyncCompletion<UIImage, ImageResolverError>)
//    func cancelRequest(forImageAt url: URL)
// }
//
// open class URLImageResolver: URLImageResolvable{
//    static var `default`: URLImageResolvable = DefaultURLImageResolver()
//    open func resolve(imageAt url: URL, complete: AsyncCompletion<UIImage, ImageResolverError>) {
//        assertionFailure(String(describing: self) + " is abstract. You must implement " + #function)
//    }
//
//    open func cancelRequest(forImageAt url: URL) {
//        assertionFailure(String(describing: self) + " is abstract. You must implement " + #function)
//    }
// }
//
// public class DefaultURLImageResolver: URLImageResolver{
//    let imageCache = NSCache<NSString, UIImage>()
//    let requestCache: [String: [AsyncCompletion<UIImage, ImageResolverError>]] = [:]
//
//    public override func resolve(imageAt url: URL, complete: AsyncCompletion<UIImage, ImageResolverError>) {
//        let key = url.absoluteString
//        if let cachedImage = imageCache.object(forKey: key.toNSString) {
//            complete.success(cachedImage)
//            return
//        }
//        URLSession.shared.dataTask(with: url, completionHandler: {[weak self] (data, response, error) in
//            guard let self = self else { return }
//            guard error == nil else {
//                complete.failure(ImageResolverError.NetworkError(error!))
//            }
//
//            guard let imageData = data, let image = UIImage(data: imageData) else {
//                complete.failure(ImageResolverError.BadImageData(error))
//            }
//
//            DispatchQueue.main.async {
//                self.imageCache.setObject(image, forKey: key.toNSString)
//                complete.success(image)
//
//            }
//        }).resume()
//    }
//
// }
//
// public enum URLConvertibleError: Error {
//    case invalidURL
// }
//
// public protocol URLConvertible {
//    var toURL: URL? { get }
//    func assertURL() throws -> URL
// }
//
// extension URLConvertible {
//    public func assertURL() throws -> URL {
//        guard let url = toURL else {
//            throw URLConvertibleError.invalidURL
//        }
//        return url
//    }
// }
//
// extension URL: URLConvertible {
//    public var toURL: URL? {
//        return self
//    }
// }
//
// extension URLComponents: URLConvertible {
//    public var toURL: URL? {
//        return url
//    }
// }
//
// extension String: URLConvertible {
//    public var toURL: URL? {
//        if let string = addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
//            return URL(string: string)
//        }
//        return URL(string: self)
//    }
// }

//
// public protocol ImageDisplayable{
//    func display(image: URLConvertible, placeholderImage: UIImage?, processing: ((UIImage) throws -> (UIImage))?)
//    func display(image: UIImage)
// }
//
// public enum ImageResolverError: Error{
//    case InvalidURL
//    case BadImageData(Error?)
//    case NetworkError(Error)
//    case ProcessingError(Error)
// }
//
//
//
// extension UIImageView: ImageDisplayable{
//
//    public func display(image: URLConvertible,
//                        placeholderImage: UIImage? = nil,
//                        processing: ((UIImage) throws -> (UIImage))? = nil) {
//
//        self.image = placeholderImage
//
//    }
//
//    public func display(image: UIImage) {
//        self.image = image
//    }
// }
//
// extension UIButton{
//    open func displayImage(withUrlString urlString: String, filter: ImageFilter? = nil, for state: UIControl.State){
//        resetImage(for: state)
//        guard let url: URL = URL(string: urlString) else { return }
//        af_setImage(for: state, url: url)
//    }
//
//    open func resetImage(for state: UIControl.State){
//        af_cancelImageRequest(for: state)
//    }
// }
//
//
