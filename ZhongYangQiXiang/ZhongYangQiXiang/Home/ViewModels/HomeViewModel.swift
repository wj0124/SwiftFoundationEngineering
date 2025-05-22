//
//  TestPost.swift
//  ZhongYangQiXiang
//
//  Created by 王杰 on 2025/3/21.
//

import Foundation
import Moya
import SwiftUI
import Alamofire


final class NetworkLoggerPlugin: PluginType {

    // 收到响应后调用
    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        switch result {
        case .success(let response):
            logSuccess(response: response, target: target)
        case .failure(let error):
            print("请求失败，错误信息：\(error.localizedDescription)")
        }
    }
    
    // MARK: - 打印成功响应
    private func logSuccess(response: Response, target: TargetType) {
        let url = target.baseURL.absoluteString + target.path
        
        let headers = target.headers ?? [:] // 获取请求头信息

        var parameters: [String: Any] = [:]

        switch target.task {
        case .requestPlain:
            // 没有参数
            parameters = [:]
        case let .requestData(data):
            // 如果 data 是 JSON 格式，尝试解析为字典，否则直接记录原始 data
            if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
               let jsonDict = jsonObject as? [String: Any] {
                parameters = jsonDict
            } else {
                parameters = ["rawData": data]
            }
        case let .requestParameters(params, _):
            parameters = params
        case let .requestCompositeParameters(bodyParameters, _, urlParameters):
            // 将 body 参数和 URL 参数合并，遇到相同的 key 时以 body 为准
            parameters = bodyParameters.merging(urlParameters) { (body, _) in body }
        case let .requestCompositeData(bodyData, urlParameters):
            // 尝试将 bodyData 解析为 JSON 字典，再合并 URL 参数
            if let jsonObject = try? JSONSerialization.jsonObject(with: bodyData, options: []),
               let jsonDict = jsonObject as? [String: Any] {
                parameters = jsonDict.merging(urlParameters) { (body, _) in body }
            } else {
                parameters = urlParameters
            }
        case let .uploadMultipart(multipartData):
            // 对于 multipart 上传，可以记录每个部分的基本信息，如名称、文件名、mimeType 等
            let multipartInfo = multipartData.map { data in
                return [
                    "name": data.name,
                    "fileName": data.fileName ?? "N/A",
                    "mimeType": data.mimeType
                ]
            }
            parameters = ["multipartData": multipartInfo]
        default:
            // 其他未涵盖的情况
            parameters = [:]
        }

//        let _parameters = parameters.jsonString(prettify: true) ?? "err"
        
        
        
        let logMessage = """
        -----------接口响应-----------
        方法名:   \(target)
        接口名:   \(url)
        请求类型: \(target.method.rawValue)
        请求头:   \(headers)
        请求参数: \(parameters)
        返回JSON: \(JSON(response.data))
        -----------------------------
        """
        print(logMessage)
    }
}



// MARK: - HomeViewModel

class HomeViewModel: ObservableObject {
    
    // 自定义 Session 配置，使用白名单（仅允许 "47.122.5.230"）
    private static let customSession: Moya.Session = {
        let configuration = URLSessionConfiguration.default
        let serverTrustManager = ServerTrustManager(
            allHostsMustBeEvaluated: true,
            evaluators: ["47.122.5.230": DisabledTrustEvaluator()]
        )
        return Moya.Session(configuration: configuration,
                            startRequestsImmediately: false,
                            serverTrustManager: serverTrustManager)
    }()
    
    // 使用自定义 Session 初始化 MoyaProvider，并添加日志插件
    private let provider = MoyaProvider<HomeAPI>(
        session: HomeViewModel.customSession,
        plugins: [NetworkLoggerPlugin()]
    )
    
    // 存放请求到的视频数组
    @Published var videos: [Video] = []
    @Published var responseData: Data = Data()
    
    // 存放可能的错误信息
    @Published var errorMessage: String?
    
    // 新增加载状态属性
    @Published var isLoading: Bool = false
    
    /// 从网络获取视频数据
    func fetchVideos() {
        // 请求开始前，将加载状态设置为 true
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        provider.request(.getPosts) { [weak self] result in
            guard let self = self else { return }
            // 使用 defer 确保在请求结束后将加载状态设置为 false
            defer {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
            
            switch result {
            case .success(let response):
                do {
                    self.responseData = response.data
                    // 解析顶层响应模型，获取 videos 数组
                    let homeResponse = try JSONDecoder().decode(HomeResponse.self, from: response.data)
                    DispatchQueue.main.async {
                        self.videos = homeResponse.videos
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.errorMessage = "解析失败：\(error.localizedDescription)"
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.errorMessage = "请求失败：\(error.localizedDescription)"
                }
            }
        }
    }
}
