//
//  ZhongYangQiXiangApp.swift
//  ZhongYangQiXiang
//
//  Created by 王杰 on 2025/3/20.
//

import SwiftUI
import UIKit

// 原来的 Tab 枚举
enum Tab: Int, CaseIterable {
    case home, weather, map, alerts, decision

    var title: String {
        switch self {
        case .home: return "首页"
        case .weather: return "天气"
        case .map: return "地图"
        case .alerts: return "预警"
        case .decision: return "决策"
        }
    }

    var imageName: (default: String, selected: String) {
        switch self {
        case .home: return ("tab_home_default", "tab_home_selected")
        case .weather: return ("tab_weather_default", "tab_weather_selected")
        case .map: return ("tab_map_default", "tab_map_selected")
        case .alerts: return ("tab_early_warning_default", "tab_early_warning_selected")
        case .decision: return ("tab_decision_making_default", "tab_decision_making_selected")
        }
    }
    
    // 注意：为避免重复嵌套 NavigationView，在这里直接返回具体视图
    var view: AnyView {
        switch self {
        case .home: return AnyView(HomeView())
        case .weather: return AnyView(WeatherView())
        case .map: return AnyView(MapView())
        case .alerts: return AnyView(AlertsView())
        case .decision: return AnyView(DecisionView())
        }
    }
}

// 自定义的 UITabBarController 封装器
struct RootView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UITabBarController {
        let tabBarController = UITabBarController()
        
        // 遍历所有标签，构建 UINavigationController 数组
        let viewControllers: [UINavigationController] = Tab.allCases.map { tab in
            let hostingController = UIHostingController(rootView: tab.view)
            let navController = UINavigationController(rootViewController: hostingController)
            navController.tabBarItem = UITabBarItem(
                title: tab.title,
                image: UIImage(named: tab.imageName.default),
                selectedImage: UIImage(named: tab.imageName.selected)
            )
            return navController
        }
        tabBarController.viewControllers = viewControllers
        return tabBarController
    }
    
    func updateUIViewController(_ uiViewController: UITabBarController, context: Context) {
        // 根据需要更新视图控制器
    }
}

// 示例 SwiftUI 视图

struct WeatherView: View {
    var body: some View {
        Text("天气")
    }
}

struct MapView: View {
    var body: some View {
        Text("地图")
    }
}

struct AlertsView: View {
    var body: some View {
        Text("预警")
    }
}


// 主入口（使用 SwiftUI App 生命周期）
@main
struct ZhongYangQiXiangApp: App {
    var body: some Scene {
        WindowGroup {
            // 直接使用 UIKit 包装器作为启动视图
            RootView()
                .edgesIgnoringSafeArea(.all)
        }
    }
}
