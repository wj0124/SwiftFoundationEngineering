//
//  Untitled.swift
//  ZhongYangQiXiang
//
//  Created by 王杰 on 2025/3/21.
//

import SwiftUICore
import SwiftUI


struct DecisionView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("加载中...")
                    .padding()
            } else {
                ScrollView {
                    // 直接将 responseData 转换为 JSON 格式并显示
                    Text("\(JSON(viewModel.responseData))")
                        .padding()
                        .font(.system(.body, design: .monospaced))
                }
            }
        }
        .onAppear {
            viewModel.fetchVideos()
        }
        .navigationTitle("决策")
    }
}
