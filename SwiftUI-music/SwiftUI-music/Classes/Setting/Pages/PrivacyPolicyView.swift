//
//  PrivacyPolicyView.swift
//  SwiftUI-music
//
//  隐私政策页面
//  兼容 iOS 26+ / iPadOS / Swift 6
//

import SwiftUI

// MARK: - 隐私政策视图
struct PrivacyPolicyView: View {
    var body: some View {
        SettingsDetailContainer(title: "隐私政策") {
            VStack(alignment: .leading, spacing: 0) {
                // 更新日期
                HStack {
                    Text("最后更新日期：2026年1月1日")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 8)
                
                // 隐私政策内容
                SettingsCard {
                    VStack(alignment: .leading, spacing: 20) {
                        PolicySection(
                            title: "引言",
                            content: """
                            SwiftUI 音乐（以下简称"我们"）非常重视用户的隐私保护。本隐私政策旨在向您说明我们如何收集、使用、存储和保护您的个人信息。
                            
                            请您在使用我们的服务前，仔细阅读并理解本隐私政策的全部内容。一旦您开始使用我们的服务，即表示您已充分理解并同意本政策。
                            """
                        )
                        
                        Divider()
                        
                        PolicySection(
                            title: "一、我们收集的信息",
                            content: """
                            1. 账号信息：当您注册账号时，我们会收集您的用户名、邮箱地址、手机号码等基本信息。
                            
                            2. 设备信息：我们可能会收集您的设备型号、操作系统版本、唯一设备标识符等信息。
                            
                            3. 使用数据：包括您的播放历史、搜索记录、收藏的歌曲和歌单等使用行为数据。
                            
                            4. 位置信息：在您授权的情况下，我们可能会收集您的位置信息以提供本地化服务。
                            """
                        )
                        
                        Divider()
                        
                        PolicySection(
                            title: "二、信息的使用",
                            content: """
                            我们收集的信息将用于：
                            
                            1. 提供、维护和改进我们的服务
                            2. 个性化您的使用体验，如推荐您可能喜欢的音乐
                            3. 处理您的请求和交易
                            4. 与您沟通，包括发送服务通知
                            5. 保护我们服务的安全性
                            """
                        )
                        
                        Divider()
                        
                        PolicySection(
                            title: "三、信息的共享",
                            content: """
                            我们承诺不会将您的个人信息出售给第三方。但在以下情况下，我们可能会共享您的信息：
                            
                            1. 获得您的明确同意
                            2. 法律法规要求
                            3. 与关联公司共享以提供服务
                            4. 与授权合作伙伴共享（如支付服务商）
                            """
                        )
                        
                        Divider()
                        
                        PolicySection(
                            title: "四、信息的存储与保护",
                            content: """
                            1. 我们采用业界标准的安全技术和程序来保护您的个人信息。
                            
                            2. 您的数据存储在位于中国境内的安全服务器上。
                            
                            3. 我们会保留您的信息直到您注销账号或法律要求的期限届满。
                            """
                        )
                        
                        Divider()
                        
                        PolicySection(
                            title: "五、您的权利",
                            content: """
                            您对您的个人信息享有以下权利：
                            
                            1. 访问权：您可以随时查看您的个人信息
                            2. 更正权：您可以更新或更正不准确的信息
                            3. 删除权：您可以请求删除您的个人信息
                            4. 撤回同意：您可以随时撤回对信息处理的同意
                            """
                        )
                        
                        Divider()
                        
                        PolicySection(
                            title: "六、未成年人保护",
                            content: """
                            我们非常重视未成年人的隐私保护。如果您是未满18周岁的未成年人，请在监护人的陪同下阅读本政策，并在获得监护人同意后使用我们的服务。
                            """
                        )
                        
                        Divider()
                        
                        PolicySection(
                            title: "七、政策更新",
                            content: """
                            我们可能会不时更新本隐私政策。更新后的政策将在本页面发布，重大变更我们会通过应用内通知或其他适当方式告知您。
                            """
                        )
                        
                        Divider()
                        
                        PolicySection(
                            title: "八、联系我们",
                            content: """
                            如果您对本隐私政策有任何疑问或建议，请通过以下方式联系我们：
                            
                            邮箱：privacy@swiftui-music.com
                            地址：北京市朝阳区XXX大厦XXX室
                            电话：400-888-8888
                            """
                        )
                    }
                    .padding(16)
                }
            }
        }
    }
}

// MARK: - 政策章节
struct PolicySection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.primary)
            
            Text(content)
                .font(.system(size: 15))
                .foregroundColor(.secondary)
                .lineSpacing(6)
        }
    }
}

#Preview {
    PrivacyPolicyView()
}
