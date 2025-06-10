//
//  ImagePipelineManager.swift
//  Acty
//
//  Created by Sebin Kwon on 6/10/25.
//

import Foundation
import Nuke

final class ImagePipelineManager {
    static func configure(with tokenService: TokenServiceProtocol) {
        var configuration = ImagePipeline.Configuration()
        
        // 1. 커스텀 DataLoader 설정
        configuration.dataLoader = ImageDataLoader(tokenService: tokenService)
        
        // 2. 기본 캐시 설정만
        configuration.imageCache = ImageCache(
            costLimit: 100 * 1024 * 1024, // 100MB
            countLimit: 300
        )
        
        // 전역 파이프라인 설정
        ImagePipeline.shared = ImagePipeline(configuration: configuration)
    }
}
