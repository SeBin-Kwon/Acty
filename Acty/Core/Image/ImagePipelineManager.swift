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
        
        ImagePipeline.shared = ImagePipeline(configuration: configuration)
    }
}
