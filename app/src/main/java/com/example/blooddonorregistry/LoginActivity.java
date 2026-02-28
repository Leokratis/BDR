package com.example.blooddonorregistry;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.webkit.CookieManager;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import androidx.appcompat.app.AppCompatActivity;

public class LoginActivity extends AppCompatActivity {
    private static final String PREFS = "bdr_prefs";
    private static final String TOKEN_KEY = "token";

    @SuppressLint("SetJavaScriptEnabled")
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        WebView view = new WebView(this);
        view.getSettings().setJavaScriptEnabled(true);
        setContentView(view);

        view.setWebViewClient(new WebViewClient() {
            @Override
            public void onPageFinished(WebView view, String url) {
                String cookies = CookieManager.getInstance().getCookie(url);
                if (cookies != null && cookies.contains("X-Auth-Token")) {
                    // naive token extraction
                    for (String cookie : cookies.split(";")) {
                        if (cookie.trim().startsWith("X-Auth-Token")) {
                            String token = cookie.split("=", 2)[1];
                            saveToken(token);
                        }
                    }
                }
            }

        });

        view.loadUrl("https://service.bdr.gr");
    }

    private void saveToken(String token) {
        SharedPreferences prefs = getSharedPreferences(PREFS, Context.MODE_PRIVATE);
        prefs.edit().putString(TOKEN_KEY, token).apply();
    }
}
