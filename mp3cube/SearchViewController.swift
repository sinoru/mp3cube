//
//  SearchViewController.swift
//  mp3cube
//
//  Created by INSU BYEON on 2017. 7. 6..
//  Copyright © 2017년 kokonoe. All rights reserved.
//

import Alamofire
import UIKit

class SearchViewController: UIViewController {

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

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewDataSource: SearchTableViewDataSoruce!

    @IBOutlet weak var searchBar: UISearchBar!
    
    let refreshControl: UIRefreshControl = { UIRefreshControl() }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if !self.isConnected {
            errorNetwork()
        }
        
        //self.searchBar.isUserInteractionEnabled = true
        //definesPresentationContext = true
        
        self.hideKeyboardWhenTappedAround()
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]

        //tblSearchBar.allowsSelection = false
        
        self.extendedLayoutIncludesOpaqueBars = true

        // 문자열 띄울 때 아래의 코드를 지우면 됨
        // refreshControl.attributedTitle = NSAttributedString(string: "당겨서 새로고침")
        self.refreshControl.addTarget(self, action: #selector(self.refresh), for: UIControlEvents.valueChanged)
        self.tableView.addSubview(refreshControl)
        
        
    }

    // MARK: - 검색 테이블 뷰 새로고침 메서드
    func refresh(sender:AnyObject) {
        
        if searchBar.placeholder != "검색할 음악을 입력해주세요." {
            self.tableViewDataSource.search(name: searchBar.placeholder!)
        }
        
        refreshControl.endRefreshing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension SearchViewController: UISearchBarDelegate {

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

    // MARK: - 검색 버튼 클릭 이벤트
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.tableViewDataSource.search(name: searchBar.text!)

        self.searchBar.placeholder = searchBar.text!
        self.searchBar.text = nil
    }
}

extension SearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("인덱스 : \(indexPath.row)")
    }
}
