func didReceive(_ notification: UNNotification) {
    // 处理专辑图片和播放控制
    let content = notification.request.content
    if let albumArtUrl = content.userInfo["albumArtUrl"] as? String,
       let url = URL(string: albumArtUrl) {
        DispatchQueue.main.async {
            self.imageView.image = UIImage(contentsOfFile: url.path)
        }
    }
    
    if let controls = content.userInfo["controls"] as? [String] {
        setupControls(controls: controls)
    }
    
    // 更新标题和内容摘要
    if let title = content.userInfo["title"] as? String {
        DispatchQueue.main.async {
            self.titleLabel.text = title
        }
    }
    
    if let abstract = content.userInfo["abstract"] as? String {
        DispatchQueue.main.async {
            self.abstractLabel.text = abstract
        }
    }
}