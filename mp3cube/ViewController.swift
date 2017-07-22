//
//  ViewController.swift
//  mp3cube
//
//  Created by INSU BYEON on 2017. 7. 6..
//  Copyright © 2017년 kokonoe. All rights reserved.
//
import Alamofire
import UIKit

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                 action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension ViewController {
    var isConnected :Bool {
        return NetworkReachabilityManager()!.isReachable
    }
    func errorNetwork() {
        let alertError = UIAlertController(title: "Error",
                                           message: "네트워크 연결 실패",
                                           preferredStyle: UIAlertControllerStyle.alert)
        alertError.addAction(UIAlertAction(title: "확인",
                                           style: UIAlertActionStyle.default,
                                           handler: nil))
        self.present(alertError, animated: true, completion: nil)
    }
}

extension String {
    func matchingStrings(regex: String) -> [[String]] {
        guard let regex = try? NSRegularExpression(pattern: regex, options: []) else { return [] }
        let nsString = self as NSString
        let results  = regex.matches(in: self, options: [], range: NSMakeRange(0, nsString.length))
        return results.map { result in
            (0..<result.numberOfRanges).map { result.rangeAt($0).location != NSNotFound
                ? nsString.substring(with: result.rangeAt($0))
                : ""
            }
        }
    }
}

class ViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var tblData: [String] = []
    var tblDataArtist: [String] = []
    
    let cellReuseIdentifier = "cell"
    
    let pattern = "</i>&nbsp;(.*)</td>"
    let pattern_artist = "rel=\"nofollow\">(.*)</a>"

    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tblSearchBar: UITableView!
    
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if !self.isConnected {
            errorNetwork()
        }
        
        //self.searchBar.isUserInteractionEnabled = true
        //definesPresentationContext = true
        
        self.hideKeyboardWhenTappedAround()

        searchBar.delegate = self
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]

        tblSearchBar.delegate = self
        tblSearchBar.dataSource = self

        //tblSearchBar.allowsSelection = false
        
        self.extendedLayoutIncludesOpaqueBars = true;
        
        refreshControl = UIRefreshControl()
        // 문자열 띄울 때 아래의 코드를 지우면 됨
        // refreshControl.attributedTitle = NSAttributedString(string: "당겨서 새로고침")
        refreshControl.addTarget(self, action: #selector(self.refresh), for: UIControlEvents.valueChanged)
        tblSearchBar.addSubview(refreshControl)
        
        
    }
    
    // MARK: - 검색 모드 ON / OFF
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setValue("취소", forKey: "_cancelButtonText")
        searchBar.showsCancelButton = true
        self.navigationController? .setNavigationBarHidden(true, animated: true)
        
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        self.navigationController? .setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: - 검색 테이블 뷰 새로고침 메서드
    func refresh(sender:AnyObject) {
        
        if searchBar.placeholder != "검색할 음악을 입력해주세요." {
            search(name: searchBar.placeholder!)
        }
        
        refreshControl.endRefreshing()
    }
    
    // MARK: - 검색 버튼 클릭 이벤트
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        search(name: searchBar.text!)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tblData.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SearchTableView = self.tblSearchBar.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! SearchTableView

        cell.myTitle?.text = self.tblData[indexPath.row]
        cell.myArtist?.text = self.tblDataArtist[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("인덱스 : \(indexPath.row)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func search(name: String) {
        tblData.removeAll()
        tblDataArtist.removeAll()
        tblSearchBar.reloadData()
        
        var url = "http://mp3cube.net/search/"
        let encodeQuery = name.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        url = url + encodeQuery! + ".html"
        
        Alamofire.request(url)
            .responseString { response in
                if response.result.isSuccess {
                    
                    var music_name = response.result.value!.matchingStrings(regex: self.pattern)
                    var music_artist = response.result.value!.matchingStrings(regex: self.pattern_artist)
                    if music_name.count == 0 {
                        let alertError = UIAlertController(title: "Error",
                                                           message: "해당되는 음악이 없습니다.",
                                                           preferredStyle: UIAlertControllerStyle.alert)
                        alertError.addAction(UIAlertAction(title: "확인",
                                                           style: UIAlertActionStyle.default,
                                                           handler: nil))
                        self.present(alertError, animated: true, completion: nil)
                    } else {
                        self.tblSearchBar.beginUpdates()
                        for i in 0..<music_name.count {
                        
                            self.tblData.append(music_name[i][1])
                            self.tblDataArtist.append(music_artist[i][1])
                            self.tblSearchBar.insertRows(at: [IndexPath(row: self.tblData.count - 1,
                                                                    section: 0)], with: .automatic)
                        
                        }
                        self.tblSearchBar.endUpdates()
                    }
                } else {
                    self.errorNetwork()
                }
        }
        
        searchBar.placeholder = name
        searchBar.text = nil
    }
}
