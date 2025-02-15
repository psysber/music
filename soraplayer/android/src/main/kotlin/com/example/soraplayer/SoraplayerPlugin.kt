package com.example.soraplayer
import android.app.NotificationChannel
import android.os.Build
import android.app.NotificationManager
import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.drawable.Drawable
import android.widget.RemoteViews
import androidx.annotation.NonNull
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.bumptech.glide.Glide
import com.bumptech.glide.request.target.CustomTarget
import com.bumptech.glide.request.transition.Transition
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.File
/** SoraplayerPlugin */
public class SoraplayerPlugin: FlutterPlugin, MethodCallHandler {
  private val channelId = "sora_player_plugin"
  private val notificationId = 1
  private lateinit var channel: MethodChannel
  private lateinit var context: Context

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "sora_player_plugin")
    channel.setMethodCallHandler(this)
  }
  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {

    when (call.method) {
      "showNotification" -> {
        val title = call.argument<String>("title")
        val artist = call.argument<String>("artist")
        val imagePath = call.argument<String>("imagePath")
        val imageUrl = call.argument<String>("imageUrl")
        val isPlaying = call.argument<Boolean>("isPlaying")
        showNotification(title, artist, imagePath, imageUrl, isPlaying)
        result.success(null)
      }
      else -> result.notImplemented()
    }
  }

  private fun showNotification(title: String?, artist: String?, imagePath: String?, imageUrl: String?, isPlaying: Boolean?) {
    createNotificationChannel();
    val notificationLayout = RemoteViews(context.packageName, R.layout.notification_music)

    // Load image
    if (imagePath != null) {
      val bitmap = loadBitmapFromPath(imagePath)
      if (bitmap != null) {
        applyBlurredBackground(notificationLayout, bitmap)
        notificationLayout.setImageViewBitmap(R.id.song_cover, bitmap)
      }
    } else if (imageUrl != null) {
      loadBitmapFromUrl(imageUrl) { bitmap ->
        if (bitmap != null) {
          applyBlurredBackground(notificationLayout, bitmap)
          notificationLayout.setImageViewBitmap(R.id.song_cover, bitmap)
        }
      }

    }

    // Set song info
    notificationLayout.setTextViewText(R.id.song_title, title)
    notificationLayout.setTextViewText(R.id.song_artist, artist)

    // Set play/pause button
    val playPauseIcon = if (isPlaying == true) R.drawable.ic_pause else R.drawable.ic_play
    notificationLayout.setImageViewResource(R.id.btn_play_pause, playPauseIcon)

    // Build notification
    val notification = NotificationCompat.Builder(context, channelId)
            .setSmallIcon(R.drawable.ic_music) // 小图标
            .setCustomBigContentView(notificationLayout)
           // .setStyle(NotificationCompat.DecoratedCustomViewStyle()) // 使用自定义布局
            .setCustomContentView(notificationLayout) // 设置自定义布局
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC) // 在锁屏上显示
            .setOngoing(true) // 设置持续通知
            .build()

    NotificationManagerCompat.from(context).notify(notificationId, notification)
  }

  private fun loadBitmapFromPath(imagePath: String?): Bitmap? {
    return if (imagePath != null && File(imagePath).exists()) {
      BitmapFactory.decodeFile(imagePath)
    } else {
      null
    }
  }

  private fun loadBitmapFromUrl(imageUrl: String?, callback: (Bitmap?) -> Unit) {
    if (imageUrl == null) {
      callback(null)
      return
    }

    Glide.with(context)
            .asBitmap()
            .load(imageUrl)
            .into(object : CustomTarget<Bitmap>() {
              override fun onResourceReady(resource: Bitmap, transition: Transition<in Bitmap>?) {
                callback(resource)
              }

              override fun onLoadCleared(placeholder: Drawable?) {
                // 当 Glide 清除资源时调用
                callback(null)
              }
            })
  }

  private fun applyBlurredBackground(notificationLayout: RemoteViews, bitmap: Bitmap) {
    val blurredBitmap = BlurUtil.blur(context, bitmap)
    notificationLayout.setImageViewBitmap(R.id.background_image, blurredBitmap)
  }

  private fun createNotificationChannel() {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      val name = "Music Player"
      val descriptionText = "Music Player Notification Channel"
      val importance = NotificationManager.IMPORTANCE_LOW
      val channel = NotificationChannel(channelId, name, importance).apply {
        description = descriptionText
      }
      val notificationManager: NotificationManager =
              context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
      notificationManager.createNotificationChannel(channel)
    }
  }
}
