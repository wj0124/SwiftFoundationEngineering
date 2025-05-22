//
//  Untitled.swift
//  ZhongYangQiXiang
//
//  Created by 王杰 on 2025/3/21.
//

import Moya
import Foundation

/// 定义你要请求的接口
enum HomeAPI {
    case getPosts  // 获取所有帖子
}

/// 扩展 HomeAPI 来实现 Moya 的 TargetType 协议
extension HomeAPI: TargetType {
    /// 服务器地址
    var baseURL: URL {
        // 这里用 JSONPlaceholder 的测试地址
        return URL(string: "https://47.122.5.230:8089")!
    }
    
    /// 路径
    var path: String {
        switch self {
        case .getPosts:
            return "/media/api/v1/media/getDouyinListByPage"
        }
    }
    
    /// HTTP 请求方法
    var method: Moya.Method {
        switch self {
        case .getPosts:
            return .get
        }
    }
    
    /// 请求任务（携带参数等）
    var task: Task {
        switch self {
        case .getPosts:
            return .requestPlain  // 无参数
        }
    }
    
    /// 请求头
    var headers: [String : String]? {
        return ["Content-Type": "application/json"]
    }
    
    /// 用于单元测试或 mock 数据
    var sampleData: Data {
        switch self {
        case .getPosts:
            // 示例 JSON
            return """
            [
              {"id": 1, "title": "Test Title", "body": "Test Body"}
            ]
            """.data(using: .utf8)!
        }
    }
}
