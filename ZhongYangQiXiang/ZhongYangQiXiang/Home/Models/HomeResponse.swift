//
//  Untitled.swift
//  ZhongYangQiXiang
//
//  Created by 王杰 on 2025/3/21.
//

// MARK: - 模型定义

/// 顶层响应模型，对应 JSON 返回数据
struct HomeResponse: Codable {
    let msg: String
    let videos: [Video]   // 使用 videos 表示数据列表
    let code: Int
    let total: Int
    
    enum CodingKeys: String, CodingKey {
        case msg, code, total
        case videos = "data"  // JSON 的 key "data" 映射为 videos
    }
}

/// 视频模型，采用 JSON 数据中的字段
struct Video: Codable, Identifiable {
    var id: String { videoId }  // 使用 videoId 作为唯一标识
    let desc: String
    let createTime: String
    let videoId: String
    let author: String
    let favorites: Int
    let isFavorite: Bool
    let type: String?
    let likes: Int
    let isLike: Bool
    let previewTitle: String?
    let url: String
}
