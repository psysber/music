package com.example.music_player_plugin

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class SoraplayerPluginReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            "PREVIOUS" -> {
                // Handle previous action
            }
            "TOGGLE_PLAYBACK" -> {
                // Handle play/pause action
            }
            "NEXT" -> {
                // Handle next action
            }
        }
    }
}
