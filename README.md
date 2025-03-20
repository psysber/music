# Flutter 音乐应用

这是一个使用 Flutter 开发的音乐播放器应用，直接调用 iOS 的 AVFoundation 框架实现音频播放控制，并且支持音乐通知显示。此外，应用还实现了与蓝奏云网盘的对接，用户可以直接从蓝奏云下载并播放音乐。

## 技术亮点

1. **直接调用 AVFoundation**：  
   本应用没有使用任何第三方音频播放插件，而是直接通过 Flutter 的 Platform Channel 调用 iOS 的 AVFoundation 框架，实现了音频的播放、暂停、停止、快进、快退等功能。这种方式可以更好地控制音频播放的行为，并且减少对第三方插件的依赖。

2. **音乐通知显示**：  
   应用在播放音乐时，会在系统通知栏显示当前播放的音乐信息（如歌曲名、歌手、专辑封面等），并且支持通过通知栏控制播放（播放/暂停、上一首、下一首）。

3. **蓝奏云网盘对接**：  
   应用实现了与蓝奏云网盘的对接，用户可以通过输入蓝奏云分享链接，直接下载并播放音乐文件。蓝奏云的 API 通过 Dart 的 HTTP 库进行调用，实现了文件列表获取、文件下载等功能。

4. **纯 Dart 实现**：  
   除了必要的 Platform Channel 调用 AVFoundation 外，其余功能均使用纯 Dart 实现，保证了代码的可维护性和跨平台兼容性。

## 功能列表

- 音频播放、暂停、停止、快进、快退
- 系统通知栏显示音乐信息和控制
- 蓝奏云网盘文件列表获取
- 蓝奏云文件下载
- 本地音乐文件管理
- 播放列表管理

## 如何运行

1. 克隆项目到本地：
   ```bash
   git clone https://github.com/psysber/music.git
   ```

2. 进入项目目录：
   ```bash
   cd music
   ```

3. 安装依赖：
   ```bash
   flutter pub get
   ```

4. 运行项目：
   ```bash
   flutter run
   ```

## 依赖

- `http`: 用于网络请求，调用蓝奏云 API。
- `path_provider`: 用于获取本地文件路径，管理下载的音乐文件。
## 贡献

欢迎提交 Issue 和 Pull Request。如果你有任何问题或建议，请随时联系。

## 许可证

本项目采用 MIT 许可证。详情请参阅 [LICENSE](LICENSE) 文件。

---

#真机运行界面
![image](https://github.com/user-attachments/assets/21266c69-283c-466b-8304-c7111243fd76)
![image](https://github.com/user-attachments/assets/37aa5adc-03c4-46bd-987c-3dfc9d5840e7)
![image](https://github.com/user-attachments/assets/a1187f1a-96e6-4192-aeb3-ea284bbde69e)
**Enjoy your music!** 🎵
