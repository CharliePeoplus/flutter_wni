package com.progdesigner.wni.flutter;

import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.os.Build;
import android.provider.Settings;
import android.webkit.WebSettings;
import android.webkit.WebView;

import androidx.annotation.NonNull;

import java.util.HashMap;
import java.util.Map;
import java.util.Locale;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * FlutterWNInterfacePlugin
 */
public class FlutterWNInterfacePlugin implements FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel channel;
    private Context applicationContext;
    private Map<String, Object> constants;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_wni_plugin");
        channel.setMethodCallHandler(this);
        applicationContext = flutterPluginBinding.getApplicationContext();
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if ("getProperties".equals(call.method)) {
            result.success(getProperties());
        } else {
            result.notImplemented();
        }
    }

    private Map<String, Object> getProperties() {
        if (constants != null) {
            return constants;
        }
        constants = new HashMap<>();

        PackageManager packageManager = applicationContext.getPackageManager();
        String packageName = applicationContext.getPackageName();
        String shortPackageName = packageName.substring(packageName.lastIndexOf(".") + 1);

        String applicationName = "";
        String applicationVersion = "";
        String buildVersion = "";
        String userAgent = getUserAgent();
        String packageUserAgent = userAgent;

        try {
            PackageInfo info = packageManager.getPackageInfo(packageName, 0);
            applicationName = applicationContext.getApplicationInfo().loadLabel(applicationContext.getPackageManager()).toString();
            applicationVersion = info.versionName;
            buildVersion = new Integer(info.versionCode).toString();

        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
            applicationName = "App";
            applicationVersion = "0.0.0";
            buildVersion = "0";
        }

        packageUserAgent = shortPackageName + '/' + applicationVersion + '.' + buildVersion + ' ' + userAgent;
        
        constants.put("interfaceVersion", "v1");
        constants.put("appId", packageName);
        constants.put("appName", applicationName);
        constants.put("appVersion", applicationVersion);
        constants.put("buildVersion", buildVersion);

        constants.put("osType", "Android");
        constants.put("osVersion", new Integer(Build.VERSION.SDK_INT).toString());

        constants.put("deviceId", deviceId( applicationContext ));
        constants.put("deviceLocale", deviceLocale( applicationContext ));
        constants.put("deviceModel", android.os.Build.MODEL);
        constants.put("deviceName", deviceName());
        constants.put("deviceType", "mobile");
        constants.put("deviceBrand", "android");
        
        // 이건 데이터 호환
        constants.put("systemName", "Android");
        constants.put("systemVersion", Build.VERSION.RELEASE);
        constants.put("packageName", packageName);
        constants.put("shortPackageName", shortPackageName);
        constants.put("applicationName", applicationName);
        constants.put("applicationVersion", applicationVersion);
        constants.put("packageUserAgent", packageUserAgent);
        constants.put("userAgent", userAgent);
        constants.put("webViewUserAgent", getWebViewUserAgent());

        return constants;
    }

    private String deviceId( Context context ) { 
        return Settings.Secure.getString(context.getContentResolver(), Settings.Secure.ANDROID_ID);
    }

    private String deviceLocale( Context context ) {
        Locale current;

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            current = context.getResources().getConfiguration().getLocales().get(0);
        } else {
            current = context.getResources().getConfiguration().locale;
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            return current.toLanguageTag();
        } else {
            StringBuilder builder = new StringBuilder();
            builder.append(current.getLanguage());
            if (current.getCountry() != null) {
                builder.append("-");
                builder.append(current.getCountry());
            }
            return builder.toString();
        }
    }

    private String deviceName() {
        String manufacturer = Build.MANUFACTURER;
        String model = Build.MODEL;
        if (model.startsWith(manufacturer)) {
            return model;
        }

        return manufacturer.toString() + " " + model;
    }

    private String getUserAgent() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
            return System.getProperty("http.agent");
        }

        return "";
    }

    private String getWebViewUserAgent() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
            return WebSettings.getDefaultUserAgent(applicationContext);
        }

        WebView webView = new WebView(applicationContext);
        String userAgentString = webView.getSettings().getUserAgentString();

        destroyWebView(webView);

        return userAgentString;
    }

    private void destroyWebView(WebView webView) {
        webView.loadUrl("about:blank");
        webView.stopLoading();

        webView.clearHistory();
        webView.removeAllViews();
        webView.destroyDrawingCache();

        // NOTE: This can occasionally cause a segfault below API 17 (4.2)
        webView.destroy();
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
        channel = null;
        applicationContext = null;
    }
}
