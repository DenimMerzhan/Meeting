//
//  TapPhotoControllerViewController.swift
//  Meeting
//
//  Created by Деним Мержан on 20.07.23.
//

import UIKit

class TapPhotoControllerViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

   
    var currentController: PhotoViewController?
    
    let controllers = [
        PhotoViewController(image: UIImage(named: "K1")),
        PhotoViewController(image: UIImage(named: "KatyaS")),
        PhotoViewController(image: UIImage(named: "K2")),
        PhotoViewController(image: UIImage(named: "UserInfoLike"))
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentController = controllers[0]
        dataSource = self
        view.backgroundColor = .yellow
        setViewControllers([controllers.first!], direction: .forward, animated: false)
    }


    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = controllers.firstIndex(where: {$0 == viewController}) else {return controllers[0]}
        if index == controllers.count - 1 {return nil}
        return controllers[index + 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = controllers.firstIndex(where: {$0 == viewController}) else {return controllers[0]}
        if index == 0 {return nil}
        return controllers[index - 1]
    }
    
    func updateFrame(frame: CGRect){
        self.view.frame = frame
        for controller in controllers {
            controller.view.frame = frame
            controller.imageView.frame = frame
        }
        
    }

}


class PhotoViewController: UIViewController {
    
    let imageView = UIImageView()
    
    init(image: UIImage?) {
        super.init(nibName: nil, bundle: nil)
        imageView.image = image
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(imageView)
        imageView.frame = view.bounds
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
