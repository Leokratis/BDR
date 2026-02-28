package com.example.blooddonorregistry;

import android.content.Context;
import android.content.SharedPreferences;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.nio.charset.StandardCharsets;
import java.net.HttpURLConnection;
import java.net.URL;

public final class ApiClient {
    private static final String BASE = "https://service.blooddonorregistry.gr";
    private static final String PREFS = "bdr_prefs";
    private static final String TOKEN_KEY = "token";

    private ApiClient() {
    }

    public static String getToken(Context ctx) {
        SharedPreferences prefs = ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE);
        return prefs.getString(TOKEN_KEY, null);
    }

    private static String request(String method, String path, String token, String body) {
        HttpURLConnection connection = null;
        try {
            URL url = new URL(BASE + path);
            connection = (HttpURLConnection) url.openConnection();
            connection.setRequestMethod(method);
            connection.setRequestProperty("Accept", "application/json");
            if (token != null) {
                connection.setRequestProperty("X-Auth-Token", token);
            }
            if (body != null) {
                connection.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
                connection.setDoOutput(true);
                try (OutputStream os = connection.getOutputStream()) {
                    os.write(body.getBytes(StandardCharsets.UTF_8));
                }
            }

            InputStream responseStream = connection.getResponseCode() >= HttpURLConnection.HTTP_BAD_REQUEST
                    ? connection.getErrorStream()
                    : connection.getInputStream();
            if (responseStream == null) {
                int statusCode = connection.getResponseCode();
                String statusMessage = connection.getResponseMessage();
                if (statusMessage == null || statusMessage.isEmpty()) {
                    return "HTTP " + statusCode;
                } else {
                    return "HTTP " + statusCode + " " + statusMessage;
                }
            }

            try (BufferedReader br = new BufferedReader(new InputStreamReader(responseStream, StandardCharsets.UTF_8))) {
                StringBuilder sb = new StringBuilder();
                String line;
                while ((line = br.readLine()) != null) {
                    sb.append(line);
                }
                return sb.toString();
            }
        } catch (Exception e) {
            return e.toString();
        } finally {
            if (connection != null) {
                connection.disconnect();
            }
        }
    }

    public static String getCaptcha() {
        return request("GET", "/v2/captcha", null, null);
    }

    public static String getCoverages(String token) {
        return request("GET", "/v2/coverages", token, null);
    }

    public static String getDonations(String token) {
        return request("GET", "/v2/donations", token, null);
    }

    public static String getUser(String token, String id) {
        return request("GET", "/v2/user/" + id, token, null);
    }

    public static String postContact(String message, String email, String phone) {
        String json = "{\"message\":\"" + message + "\",\"email\":\"" + email + "\",\"phone\":\"" + phone + "\"}";
        return request("POST", "/v2/contact", null, json);
    }
}
