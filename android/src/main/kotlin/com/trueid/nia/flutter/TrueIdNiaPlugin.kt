package com.trueid.nia.flutter

import android.app.Activity
import androidx.activity.ComponentActivity
import com.trueid.sdk.selfie.CameraFacing
import com.trueid.sdk.selfie.CaptureMode
import com.trueid.sdk.selfie.FastTrackVerificationCallback
import com.trueid.sdk.selfie.FastTrackVerificationConfig
import com.trueid.sdk.selfie.ResultFormat
import com.trueid.sdk.selfie.SelfieCaptureConfig
import com.trueid.sdk.selfie.TrueIDFastTrackVerification
import com.trueid.sdk.selfie.TrueIDVerification
import com.trueid.sdk.selfie.VerificationCallback
import com.trueid.sdk.selfie.VerificationConfig
import com.trueid.sdk.selfie.VerificationError
import com.trueid.sdk.selfie.VerificationResult
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class TrueIdNiaPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private var pendingResult: Result? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "com.trueid.sdk.nia/flutter")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "verify" -> handleVerify(call, result)
            "fastTrackVerify" -> handleFastTrackVerify(call, result)
            else -> result.notImplemented()
        }
    }

    private fun buildCaptureConfig(call: MethodCall) = SelfieCaptureConfig(
        captureMode = when (call.argument<String>("captureMode")) {
            "manual" -> CaptureMode.MANUAL
            else -> CaptureMode.AUTO
        },
        initialCamera = when (call.argument<String>("initialCamera")) {
            "back" -> CameraFacing.BACK
            else -> CameraFacing.FRONT
        },
        allowCameraSwitch = call.argument<Boolean>("allowCameraSwitch") ?: true,
        showFaceMesh = call.argument<Boolean>("showFaceMesh") ?: true,
        outputWidth = call.argument<Int>("outputWidth") ?: 600,
        outputHeight = call.argument<Int>("outputHeight") ?: 800,
        jpegQuality = call.argument<Int>("jpegQuality") ?: 94,
        burstFrameCount = call.argument<Int>("burstFrameCount") ?: 4,
        burstFrameDelayMs = (call.argument<Int>("burstFrameDelayMs") ?: 90).toLong(),
        resultFormat = ResultFormat.BASE64,
    )

    private fun handleVerify(call: MethodCall, result: Result) {
        val currentActivity = activity
        if (currentActivity !is ComponentActivity) {
            result.error("INCOMPATIBLE_ACTIVITY", "Activity must be a ComponentActivity", null)
            return
        }

        if (pendingResult != null) {
            result.error("ALREADY_ACTIVE", "A verification is already in progress", null)
            return
        }

        pendingResult = result

        val config = VerificationConfig(
            forceNia = call.argument<Boolean>("forceNia") ?: false,
            enforceFaceComparison = call.argument<Boolean>("enforceFaceComparison") ?: true,
            livenessPassed = call.argument<Boolean>("livenessPassed"),
            transactionType = call.argument<String>("transactionType"),
            transactionTypes = call.argument<List<String>>("transactionTypes") ?: emptyList(),
            requireLiveness = call.argument<Boolean>("requireLiveness") ?: true,
            showGuidelines = call.argument<Boolean>("showGuidelines") ?: true,
            useOrganizationCaptureSettings =
                call.argument<Boolean>("useOrganizationCaptureSettings") ?: true,
            captureConfig = buildCaptureConfig(call),
        )

        val callback = object : VerificationCallback {
            override fun onCompleted(verificationResult: VerificationResult) {
                val map = hashMapOf<String, Any?>(
                    "verified" to verificationResult.verified,
                    "lookupSource" to verificationResult.lookupSource,
                    "scanRecordId" to verificationResult.scanRecordId,
                    "fullName" to verificationResult.fullName,
                    "documentNumber" to verificationResult.documentNumber,
                    "nationality" to verificationResult.nationality,
                    "dateOfBirth" to verificationResult.dateOfBirth,
                    "gender" to verificationResult.gender,
                    "expiryDate" to verificationResult.expiryDate,
                    "phoneNumber" to verificationResult.phoneNumber,
                    "email" to verificationResult.email,
                    "selfieUrl" to verificationResult.selfieUrl,
                    "niaPhotoUrl" to verificationResult.niaPhotoUrl,
                    "transactionType" to verificationResult.transactionType,
                    "errorMessage" to verificationResult.errorMessage,
                    "errorCode" to verificationResult.errorCode,
                )
                pendingResult?.success(map)
                pendingResult = null
            }

            override fun onCancelled() {
                pendingResult?.success(null)
                pendingResult = null
            }

            override fun onError(error: VerificationError) {
                val code = when (error) {
                    is VerificationError.SdkNotInitialized -> "SDK_NOT_INITIALIZED"
                    is VerificationError.NetworkError -> "NETWORK_ERROR"
                    is VerificationError.ApiError -> error.code ?: "API_ERROR"
                    is VerificationError.CaptureError -> "CAPTURE_ERROR"
                }
                pendingResult?.error(code, error.message, null)
                pendingResult = null
            }
        }

        TrueIDVerification.launch(currentActivity, config, callback)
    }

    private fun handleFastTrackVerify(call: MethodCall, result: Result) {
        val currentActivity = activity
        if (currentActivity !is ComponentActivity) {
            result.error("INCOMPATIBLE_ACTIVITY", "Activity must be a ComponentActivity", null)
            return
        }
        if (pendingResult != null) {
            result.error("ALREADY_ACTIVE", "A verification is already in progress", null)
            return
        }

        val individualId = call.argument<String>("individualId")
        if (individualId.isNullOrBlank()) {
            result.error("INVALID_ARGUMENT", "individualId is required", null)
            return
        }
        pendingResult = result

        val config = FastTrackVerificationConfig(
            individualId = individualId,
            useOrganizationCaptureSettings =
                call.argument<Boolean>("useOrganizationCaptureSettings") ?: true,
            requireLiveness = call.argument<Boolean>("requireLiveness") ?: true,
            captureConfig = buildCaptureConfig(call),
        )

        TrueIDFastTrackVerification.launch(currentActivity, config, object : FastTrackVerificationCallback {
            override fun onCompleted(verificationResult: com.trueid.sdk.selfie.FastTrackVerificationResult) {
                pendingResult?.success(hashMapOf<String, Any?>(
                    "verified" to verificationResult.verified,
                    "scanRecordId" to verificationResult.scanRecordId,
                    "message" to verificationResult.message,
                ))
                pendingResult = null
            }

            override fun onCancelled() {
                pendingResult?.success(null)
                pendingResult = null
            }

            override fun onError(error: VerificationError) {
                val code = when (error) {
                    is VerificationError.SdkNotInitialized -> "SDK_NOT_INITIALIZED"
                    is VerificationError.NetworkError -> "NETWORK_ERROR"
                    is VerificationError.ApiError -> error.code ?: "API_ERROR"
                    is VerificationError.CaptureError -> "CAPTURE_ERROR"
                }
                pendingResult?.error(code, error.message, null)
                pendingResult = null
            }
        })
    }
}
