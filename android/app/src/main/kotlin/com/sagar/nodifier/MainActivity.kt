package com.sagar.nodifier

import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import androidx.annotation.NonNull
import com.google.android.gms.tasks.OnCompleteListener
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.google.firebase.auth.EmailAuthProvider
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.auth.FirebaseUser
import com.google.firebase.auth.ktx.auth
import com.google.firebase.ktx.Firebase
import com.google.firebase.messaging.FirebaseMessaging

class MainActivity : FlutterActivity() {
    private val fcmBridge = "com.sagar.nodifier/fcm"
    private val authBridge = "com.sagar.nodifier/auth"
    private val userBridge = "com.sagar.nodifier/user"
    private lateinit var auth: FirebaseAuth

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        auth = Firebase.auth
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, fcmBridge).setMethodCallHandler { call, result ->
            result
            if (call.method == "register") {
                token(result)
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, authBridge).setMethodCallHandler { call, result ->
            result
            if (call.method == "login") {
                login(result)
            }
        }
    }

    private fun token(result: MethodChannel.Result) {
        FirebaseMessaging.getInstance().token.addOnCompleteListener(OnCompleteListener { task ->
            if (!task.isSuccessful) {
                result.error("Token", "Firebase Cloud Messaging Token generation failed. ${task.exception.toString()}", "")
                return@OnCompleteListener
            }
            // val token = task.result
            result.success("true")
        })
    }

    private fun login(result: MethodChannel.Result) {
        auth.signInAnonymously()
                .addOnCompleteListener(this) { task ->
                    if (task.isSuccessful) {
                        // Sign in success, update UI with the signed-in user's information
                        Log.d("Sign in", "signInAnonymously:success")
                        val user = auth.currentUser
                        result.success("true")
                    } else {
                        result.error("AuthFailed", "Firebase anonymous Auth failed. ${task.exception.toString()}", "")
                    }
                }
    }
}
