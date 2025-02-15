func notifitionLoad() {
    // 设置推送内容
    let content = UNMutableNotificationContent()
    content.body = "正在播放: 音乐标题"
    
    // 设置通知category标识符
    content.categoryIdentifier = "myNotificationCategory"
    
    // 设置通知附加信息（专辑图片URL和播放控制）
    content.userInfo = [
        "albumArtUrl": "https://ts3.cn.mm.bing.net/th?id=OIP-C.AUED-gyvYKLvyC5uIngaqQHaGE&w=80&h=80&c=1&vt=10&bgcl=2f1cb3&r=0&o=6&pid=5.1",
        "controls": ["play", "pause", "next"],
        "title": "Song Title", // 添加标题
        "abstract": "Artist Name" // 添加摘要
    ]
    
    // 设置通知触发器
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
    
    // 设置请求标识符
    let requestIdentifier = "com.soraplayer.music.notification"
    
    // 设置一个通知请求
    let request = UNNotificationRequest(identifier: requestIdentifier,
                                      content: content, trigger: trigger)
    
    // 将通知请求添加到发送中心
    UNUserNotificationCenter.current().add(request) { error in
        if error == nil {
            print("Time Interval Notification scheduled: \(requestIdentifier)")
        }
    }
}