//
//  LCCategoryViewController.swift
//  letscheers
//
//  Created by 영준 이 on 2020/07/04.
//  Copyright © 2020 leesam. All rights reserved.
//

import UIKit

class LCCategoryCollectionViewController: UIViewController {

    class Segues{
        static let toasts = "toasts";
    }
    
    class Cells{
        static let `default` = "category";
        static let ads = "ads";
        static let favorite = "favorite";
    }
    
    var categories : [LCCategory] = [];
    
    var itemSize : CGSize = .zero;
    
    @IBOutlet var shareButton: UIBarButtonItem!;
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewWillAppear(_ animated: Bool) {
        self.updateFavoriteCell();
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.loadCategories();
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.updatesItemSize();

        super.viewDidAppear(animated);
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews();
        
        self.updatesItemSize();
    }
    
    override func viewDidLayoutSubviews() {
        self.updatesItemSize();

        super.viewDidLayoutSubviews();
    }
        
    func loadCategories(){
        // MARK: Creates category list and load toasts for them
        self.categories.append(.init(name: "선창!후창~!", title: "선/후창 건배사", type: .normal, image: #imageLiteral(resourceName: "sing"), background: UIImage(named: "bg_follow.jpg")));
        self.categories.append(.init(name: "모임", title: "모임용 건배사", type: .normal, image: #imageLiteral(resourceName: "metting"), background: UIImage(named: "bg_meeting.jpg")));
        self.categories.append(.init(name: "회식", title: "회식용 건배사", type: .normal, image: #imageLiteral(resourceName: "dining"), background: UIImage(named: "bg_dining.jpg")));
        self.categories.append(.init(name: "건강", title: "건강기원 건배사", type: .normal, image: #imageLiteral(resourceName: "health"), background: UIImage(named: "bg_health.jpg")));
        self.categories.append(.init(name: Cells.ads, title: "광고", type: .ads, image: #imageLiteral(resourceName: "health")));
        self.categories.append(.init(name: Cells.favorite, title: "즐겨찾기", type: .favorite, image: #imageLiteral(resourceName: "health")));
        
//        self.categories.append(LCToastCategory(name: "선창!후창~!", title: "선/후창 건배사", image: UIImage(named: "bg_follow.jpg")));
//        self.categories.append(LCToastCategory(name: "모임", title: "모임용 건배사", image: UIImage(named: "bg_meeting.jpg")));
//        self.categories.append(LCToastCategory(name: "회식", title: "회식용 건배사", image: UIImage(named: "bg_dining.jpg")));
//        self.categories.append(LCToastCategory(name: "건강", title: "건강기원 건배사", image: UIImage(named: "bg_health.jpg")));
        //filteredCategories.accept(self.categories);
        
        // load toasts for categories
        LCExcelController.shared.categories = self.categories.compactMap{ $0.data as? LCToastCategory };
        LCExcelController.shared.loadCategories(categories: LCExcelController.shared.categories);
        guard let first = self.categories.first?.data as? LCToastCategory else{
            return;
        }
        LCExcelController.shared.loadFollowToasts(withCategory: first);
        //let follow = self.categories[0];
        //LCExcelController.shared.loadFollowToasts(withCategory: follow);
        
    }
    
    func updatesItemSize(){
        if let collectionView = self.collectionView, let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout{
            let cols : CGFloat = (UIApplication.shared.isIPad && (UIDevice.current.orientation.isLandscape || UIDevice.current.orientation.isFlat)) ? 4.0 : 2.0;
            let rows : CGFloat = (UIApplication.shared.isIPad && (UIDevice.current.orientation.isLandscape || UIDevice.current.orientation.isFlat)) ? 2.0 : 3.0;
            //UIApplication.shared.openReview()
            
            let itemsWidth = collectionView.frame.size.width - (layout.minimumLineSpacing * cols.advanced(by: -1)) - layout.sectionInset.left - layout.sectionInset.right;
            let itemsHeight = collectionView.frame.size.height - (layout.minimumInteritemSpacing * rows.advanced(by: -1)) - layout.sectionInset.top - layout.sectionInset.bottom;
//            self.itemSize = .init(width: 100, height: 100);
            self.itemSize = .init(width: itemsWidth/cols, height: itemsHeight/rows);
            layout.itemSize = self.itemSize;
            print("[\(#function)] screen[\(collectionView.frame.size)]");
            print("[\(#function)] size[\(self.itemSize)] left[\(layout.sectionInset.left)] right[\(layout.sectionInset.right)] minimumLineSpacing[\(layout.minimumLineSpacing)] minimumInteritemSpacing[\(layout.minimumInteritemSpacing)]");
        }
    }
    
    func updateFavoriteCell(){
        guard self.categories.any else{
            return;
        }
        
        let indexPath = IndexPath.init(row: self.categories.count - 1, section: 0);
        guard let cell = self.collectionView.cellForItem(at: indexPath) as? LCCategoryCollectionViewFavoriteCell else{
            return;
        }
        
        cell.updateInfo();
    }

    @IBAction func onShareButton(_ button: UIBarButtonItem){
        let isiPad = UIApplication.shared.isIPad
        self.share(["\(UIApplication.shared.urlForItunes.absoluteString)"], buttonToShow: isiPad ? button : nil, permittedArrowDirections: [.up, .down]);
//        ReviewManager.shared?.show(true);
    }
     
    @IBAction func onRandomButton(_ button: UIBarButtonItem) {
        // MARK: Shows random toast with alert
        let toast = LCExcelController.shared.randomToast();
        AppDelegate.sharedGADManager?.show(unit: .full) { [weak self](unit, ad, result) in
            self?.showAlert(title: toast.title ?? "추천 건배사", msg: toast.contents, actions: [UIAlertAction(title: "확인", style: .default, handler: nil)], style: .alert);
        }
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let view = segue.destination as? LCToastTableViewController, let cell = sender as? LCCategoryCollectionViewCell, let indexPath = self.collectionView.indexPath(for: cell){
            let category = self.categories[indexPath.row];
            view.category = category.name;
            view.navigationItem.title = category.title;
            view.background = category.background;
        }
    }
}

extension LCCategoryCollectionViewController : UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.categories.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell : UICollectionViewCell!;
        
        let category = self.categories[indexPath.row];
        
        switch category.type {
        case .ads:
            if let ads = collectionView.dequeueReusableCell(withReuseIdentifier: Cells.ads, for: indexPath) as? GADNativeCollectionViewCell{
                ads.rootViewController = self;
                ads.loadAds();
                cell = ads;
            }
            break;
        case .favorite:
            if let favorite = collectionView.dequeueReusableCell(withReuseIdentifier: Cells.favorite, for: indexPath) as? LCCategoryCollectionViewFavoriteCell{
                cell = favorite;
            }
            break;
        default:
            if let normal = collectionView.dequeueReusableCell(withReuseIdentifier: Cells.default, for: indexPath) as? LCCategoryCollectionViewCell{
                let info = self.categories[indexPath.row];
                normal.info = info;
                cell = normal;
            }
            break;
        }
        
        //cell.backgroundImageView.image = category.image;
        //cell.titleLabel.text = category.name;
        
        //print("create category cell. name[\(category.name ?? "")]");
        return cell;
    }
}

//extension LCCategoryCollectionViewController  : UICollectionViewDelegateFlowLayout{
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let value = self.itemSize;
//        print("[\(#function)] size[\(value)]");
//        return value;
//    }
//}
