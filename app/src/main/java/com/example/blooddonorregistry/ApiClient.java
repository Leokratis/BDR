package com.example.blooddonorregistry;

import android.content.Context;
import android.content.SharedPreferences;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;

public class ApiClient {
    private static final String BASE = "https://service.blooddonorregistry.gr";
    private static final String PREFS = "bdr_prefs";
    private static final String TOKEN_KEY = "token";

    public static String getToken(Context ctx) {
        SharedPreferences prefs = ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE);
        return prefs.getString(TOKEN_KEY, null);
    }

    private static String request(String method, String path, String token, String body) {
        try {
            URL url = new URL(BASE + path);
            HttpURLConnection con = (HttpURLConnection) url.openConnection();
            con.setRequestMethod(method);
            con.setRequestProperty("Accept", "application/json");
            if (token != null) {
                con.setRequestProperty("X-Auth-Token", token);
            }
            if (body != null) {
                con.setDoOutput(true);
                OutputStream os = con.getOutputStream();
                os.write(body.getBytes());
                os.close();
            }
            BufferedReader br = new BufferedReader(new InputStreamReader(con.getInputStream()));
            StringBuilder sb = new StringBuilder();
            String line;
            while ((line = br.readLine()) != null) {
                sb.append(line);
            }
            br.close();
            return sb.toString();
        } catch (Exception e) {
            return e.toString();
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
