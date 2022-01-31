//
//  ViewController.swift
//  RxSwift+MVVM
//
//  Created by iamchiwon on 05/08/2019.
//  Copyright © 2019 iamchiwon. All rights reserved.
//

import RxSwift
import SwiftyJSON
import UIKit

let MEMBER_LIST_URL = "https://my.api.mockaroo.com/members_with_avatar.json?key=44ce18f0"

class 나중에생기는데이터<T> {
    private let task: (@escaping (T) -> Void) -> Void
    
    init(task: @escaping (@escaping (T) -> Void) -> Void) {
        self.task = task
    }
    
    func 나중에오면(_ f: @escaping (T) -> Void) {
        task(f)
    }
}

//class Observable<T> {
//    private let task: (@escaping (T) -> Void) -> Void
//
//    init(task: @escaping (@escaping (T) -> Void) -> Void) {
//        self.task = task
//    }
//
//    func subscribe(_ f: @escaping (T) -> Void) {
//        task(f)
//    }
//}

class ViewController: UIViewController {
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var editView: UITextView!

    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.timerLabel.text = "\(Date().timeIntervalSince1970)"
        }
    }
    private func setVisibleWithAnimation(_ v: UIView?, _ s: Bool) {
        guard let v = v else { return }
        UIView.animate(withDuration: 0.3, animations: { [weak v] in
            v?.isHidden = !s
        }, completion: { [weak self] _ in
            self?.view.layoutIfNeeded()
        })
    }

    
    func downloadJson(_ url: String) -> Observable<String> {
        // 1. 비동기로 생기는 데이터를 Observable로 감싸서 리턴하는 방법
        
        // Observable의 생명 주기
        // 1. Create
        // 2. Subscribe
        // 3. onNext
        // 4. onCompleted / onError
        // 5. Disposed
        
//        동일 코드 1
//        return Observable.just("Hello World")
//        return Observable.create { emitter in
//            emitter.onNext("Hello World")
//            emitter.onCompleted()
//            return Disposables.create()
//        }
        
        // 여러개를 넘기고 싶을 떄
//        return Observable.from(["Hello", "World"])
        
        return Observable.create() { emitter in
           let url = URL(string: url)!
            let task = URLSession.shared.dataTask(with: url) { data, _, error in
                guard error == nil else {
                    emitter.onError(error!)
                    return
                }

                if let data = data, let json = String(data: data, encoding: .utf8) {
                    emitter.onNext(json)
                }

                emitter.onCompleted()
            }

            task.resume()

            return Disposables.create() {
                task.cancel()
            }
        }
        
//        return Observable.create() { f in
//            DispatchQueue.global().async {
//                let url = URL(string: MEMBER_LIST_URL)!
//                let data = try! Data(contentsOf: url)
//                let json = String(data: data, encoding: .utf8)
//
//                DispatchQueue.main.async {
//                    f.onNext(json)
//                    f.onCompleted()
//                }
//            }
//
//            return Disposables.create()
//        }
    }
    
//    func downloadJson(_ url: String) -> 나중에생기는데이터<String?> {
//        return 나중에생기는데이터() { f in
//            DispatchQueue.global().async {
//                let url = URL(string: MEMBER_LIST_URL)!
//                let data = try! Data(contentsOf: url)
//                let json = String(data: data, encoding: .utf8)
//
//                DispatchQueue.main.async {
//                    f(json)
//                }
//            }
//        }
//    }
    
    // MARK: SYNC

    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    @IBAction func onLoad() {
        editView.text = ""
        setVisibleWithAnimation(activityIndicator, true)
        
//        json.나중에오면 { [weak self] json in
//            self?.editView.text = json
//            self?.setVisibleWithAnimation(self?.activityIndicator, false)
//        }
        
        // 2. Observable로 오는 데이터를 받아서 처리하는 방법
        let jsonObservable = downloadJson(MEMBER_LIST_URL)
        let helloObservable = Observable.just("Hello World")
        
        Observable.zip(jsonObservable, helloObservable) { $1 + "\n" + $0}
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { json in
            self.editView.text = json
            self.setVisibleWithAnimation(self.activityIndicator, false)
        }).disposed(by: disposeBag)
        
        
//        downloadJson(MEMBER_LIST_URL).subscribe { [weak self] event in
//            switch event {
//            case .next(let json):
//                DispatchQueue.main.async {
//                    self?.editView.text = json
//                    self?.setVisibleWithAnimation(self?.activityIndicator, false)
//                }
//            case .completed:
//                break
//            case .error:
//                break
//            }
//        }
    }
}
