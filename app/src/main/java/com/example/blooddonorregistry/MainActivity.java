package com.example.blooddonorregistry;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.ScrollView;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;

public class MainActivity extends AppCompatActivity {
    private TextView outputView;
    private String authToken;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        outputView = findViewById(R.id.output);
        Button loginButton = findViewById(R.id.loginButton);
        Button captchaButton = findViewById(R.id.captchaButton);
        Button coveragesButton = findViewById(R.id.coveragesButton);
        Button donationsButton = findViewById(R.id.donationsButton);
        Button userButton = findViewById(R.id.userButton);
        Button contactButton = findViewById(R.id.contactButton);

        loginButton.setOnClickListener(v -> startActivity(new Intent(this, LoginActivity.class)));

        captchaButton.setOnClickListener(v -> new Thread(() -> {
            String response = ApiClient.getCaptcha();
            runOnUiThread(() -> outputView.setText(response));
        }).start());

        coveragesButton.setOnClickListener(v -> new Thread(() -> {
            String token = ApiClient.getToken(this);
            String response = ApiClient.getCoverages(token);
            runOnUiThread(() -> outputView.setText(response));
        }).start());

        donationsButton.setOnClickListener(v -> new Thread(() -> {
            String token = ApiClient.getToken(this);
            String response = ApiClient.getDonations(token);
            runOnUiThread(() -> outputView.setText(response));
        }).start());

        userButton.setOnClickListener(v -> new Thread(() -> {
            String token = ApiClient.getToken(this);
            String response = ApiClient.getUser(token, "me");
            runOnUiThread(() -> outputView.setText(response));
        }).start());

        contactButton.setOnClickListener(v -> new Thread(() -> {
            String response = ApiClient.postContact("Test", "test@example.com", null);
            runOnUiThread(() -> outputView.setText(response));
        }).start());
    }

    @Override
    protected void onResume() {
        super.onResume();
        authToken = ApiClient.getToken(this);
        TextView tokenView = findViewById(R.id.tokenLabel);
        tokenView.setText(authToken == null ? "Not logged in" : "Token: " + authToken);
    }
}
