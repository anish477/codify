package com.example.codify

import io.flutter.embedding.android.FlutterActivity
import android.content.Intent

class MainActivity: FlutterActivity() {
    // Override to forward activity results to plugins exactly once
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
    }
}
