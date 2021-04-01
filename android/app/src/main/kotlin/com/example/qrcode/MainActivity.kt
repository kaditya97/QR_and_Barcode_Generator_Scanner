package com.example.qrcode

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import android.util.Log
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.os.Parcelable
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
  private var sharedData: String = ""
  private var sharedImage: ByteArray? = null

  override fun onCreate(
    savedInstanceState: Bundle?
  ) {
    super.onCreate(savedInstanceState)
    handleIntent()
  }

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger,
            "com.example.qrcode").setMethodCallHandler { call, result ->
              if (call.method == "getSharedData") {
                handleIntent()
                result.success(sharedData)
                sharedData = ""
              }
              if (call.method == "getSharedImage") {
                handleIntent()
                result.success(sharedImage)
                sharedImage = null
              }
            }
  }


  private fun handleIntent() {
    // intent is a property of this activity
    // Only process the intent if it's a send intent and it's of type 'text'
    if (intent?.action == Intent.ACTION_SEND) {
      if (intent.type == "text/plain") {
        intent.getStringExtra(Intent.EXTRA_TEXT)?.let { intentData ->
          sharedData = intentData
        }
      }else {
        (intent.getParcelableExtra<Parcelable>(Intent.EXTRA_STREAM) as? Uri)?.let { intentData ->
          val inputStream = contentResolver.openInputStream(intentData)
          sharedImage = inputStream.readBytes()
        }
      }
    }
  }
}