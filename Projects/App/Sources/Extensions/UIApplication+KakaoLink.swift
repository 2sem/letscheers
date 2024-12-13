//
//  UIApplication+KakaoLink.swift
//  democracyaction
//
//  Created by 영준 이 on 2017. 7. 7..
//  Copyright © 2017년 leesam. All rights reserved.
//

import UIKit
import KakaoSDKShare
import KakaoSDKTemplate
import LSExtensions

extension UIApplication{
    func shareByKakao(){
        let kakaoLink = Link();
        let kakaoContent = Content.init(title: UIApplication.shared.displayName ?? "",
                                        imageUrl: URL(string: "https://is1-ssl.mzstatic.com/image/thumb/Purple128/v4/34/84/8f/34848fce-6239-fd4d-1be5-b10473471e69/mzl.lrcomujq.png/150x150bb.jpg")!,
                                        imageWidth: 120,
                                        imageHeight: 120,
                                        description: "회식이나 술자리, 건배제의가 들어오면 당황하셨죠?",
                                        link: kakaoLink)
        
        let kakaoTemplate = FeedTemplate.init(content: kakaoContent,
                                              buttons: [.init(title: "애플 앱스토어",
                                                              link: .init()),
                                                        .init(title: "구글플레이",
                                                                        link: .init(webUrl: URL(string: "https://play.google.com/store/apps/details?id=com.tarkarn.gbs&hl=ko"),
                                                                                    mobileWebUrl: URL(string: "https://play.google.com/store/apps/details?id=com.tarkarn.gbs&hl=ko")))])
        
        ShareApi.shared.shareDefault(templatable: kakaoTemplate) { result, error in
            guard let result = result else {
                print("kakao error[\(error.debugDescription )]")
                return
            }
        }
    }
}
