package com.sagar.nodifier

import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import androidx.annotation.NonNull
import com.google.android.gms.tasks.OnCompleteListener
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.auth.ktx.auth
import com.google.firebase.firestore.ktx.firestore
import com.google.firebase.ktx.Firebase
import com.google.firebase.messaging.FirebaseMessaging
import com.google.gson.Gson

class MainActivity : FlutterActivity() {
    private val fcmBridge = "com.sagar.nodifier/fcm"
    private val authBridge = "com.sagar.nodifier/auth"
    private val userBridge = "com.sagar.nodifier/user"
    private lateinit var auth: FirebaseAuth

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        auth = Firebase.auth
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, fcmBridge).setMethodCallHandler { call, result ->
            if (call.method == "register") {
                token(result)
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, authBridge).setMethodCallHandler { call, result ->
            if (call.method == "login") {
                login(result)
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, userBridge).setMethodCallHandler { call, result ->
            if (call.method == "data") {
                data(result)
            } else if (call.method == "update" && call.argument<List<String>>("spkcc") != null && call.argument<List<String>>("dlux") != null) {
                updateDocument(call.argument<List<String>>("spkcc") ?: listOf(), call.argument<List<String>>("dlux") ?: listOf(), result)
            }
        }
    }

    private fun token(result: MethodChannel.Result) {
        FirebaseMessaging.getInstance().token.addOnCompleteListener(OnCompleteListener { task ->
            if (!task.isSuccessful) {
                result.error("Token", "Firebase Cloud Messaging Token generation failed. ${task.exception.toString()}", "")
                return@OnCompleteListener
            }
            val token = task.result
            Log.d("FCM", "Token is $token")
            result.success("true")
        })
    }

    private fun login(result: MethodChannel.Result) {
        auth.signInAnonymously()
                .addOnCompleteListener(this) { task ->
                    if (task.isSuccessful) {
                        // Sign in success, update UI with the signed-in user's information
                        Log.d("Sign in", "signInAnonymously:success")
                        // val user = auth.currentUser
                        result.success("true")
                    } else {
                        result.error("AuthFailed", "Firebase anonymous Auth failed. ${task.exception.toString()}", "")
                    }
                }
    }

    private fun data(result: MethodChannel.Result) {
        val firebaseUser = auth.currentUser
        if (firebaseUser == null) {
            result.error("AuthFailed", "Firebase anonymous Auth failed.", "")
            return
        }
        val db = Firebase.firestore
        val docRef = db.collection("users").document(firebaseUser.uid)
        docRef.get().addOnSuccessListener { snapshot ->
            if (snapshot != null && snapshot.exists() && snapshot.data != null) {
                val token = snapshot.data?.get("token") as? String
                val spkcc = snapshot.data?.get("spkcc") as? List<String>
                val dlux = snapshot.data?.get("spkcc") as? List<String>
                if (token != null && spkcc != null && dlux != null) {
                    FirebaseMessaging.getInstance().token.addOnCompleteListener(OnCompleteListener { task ->
                        if (!task.isSuccessful) {
                            result.error("Token", "Firebase Cloud Messaging Token generation failed. ${task.exception.toString()}", "")
                            return@OnCompleteListener
                        }
                        val newToken = task.result
                        Log.d("FCM", "NewToken is $newToken")
                        if (newToken != token) {
                            updateDocument(spkcc, dlux, result)
                        } else {
                            val map = hashMapOf(
                                    "token" to token,
                                    "spkcc" to spkcc,
                                    "dlux" to dlux,
                            )
                            result.success(Gson().toJson(map).toString())
                        }
                    })
                } else {
                    newOrInvalidDocumentCase(result)
                }
            } else {
                newOrInvalidDocumentCase(result)
            }
        }.addOnFailureListener {
            result.error("Firestore", "Firebase Firestore write failed. $it", "")
        }
    }

    private fun updateDocument(spkcc: List<String>, dlux: List<String>, result: MethodChannel.Result) {
        val firebaseUser = auth.currentUser
        if (firebaseUser == null) {
            result.error("AuthFailed", "Firebase anonymous Auth failed.", "")
            return
        }
        FirebaseMessaging.getInstance().token.addOnCompleteListener(OnCompleteListener { task ->
            if (!task.isSuccessful) {
                result.error("Token", "Firebase Cloud Messaging Token generation failed. ${task.exception.toString()}", "")
                return@OnCompleteListener
            }
            val newToken = task.result
            Log.d("FCM", "NewToken is $newToken")
            val db = Firebase.firestore
            val docRef = db.collection("users").document(firebaseUser.uid)
            val map = hashMapOf(
                    "token" to newToken,
                    "spkcc" to spkcc,
                    "dlux" to dlux,
            )
            docRef.set(map).addOnSuccessListener {
                result.success(Gson().toJson(map).toString())
            }.addOnFailureListener {
                result.error("Firestore", "Firebase Firestore write failed. $it", "")
            }
        })
    }

    private fun newOrInvalidDocumentCase(result: MethodChannel.Result) {
        val firebaseUser = auth.currentUser
        if (firebaseUser == null) {
            result.error("AuthFailed", "Firebase anonymous Auth failed.", "")
            return
        }
        val db = Firebase.firestore
        val docRef = db.collection("users").document(firebaseUser.uid)
        FirebaseMessaging.getInstance().token.addOnCompleteListener(OnCompleteListener { task ->
            if (!task.isSuccessful) {
                result.error("Token", "Firebase Cloud Messaging Token generation failed. ${task.exception.toString()}", "")
                return@OnCompleteListener
            }
            val token = task.result
            Log.d("FCM", "Token is $token")
            val map = hashMapOf(
                    "token" to token,
                    "spkcc" to listOf<String>(),
                    "dlux" to listOf<String>(),
            )
            docRef.set(map).addOnSuccessListener {
                result.success(Gson().toJson(map).toString())
            }.addOnFailureListener {
                result.error("Firestore", "Firebase Firestore write failed. $it", "")
            }
        })
    }
}
