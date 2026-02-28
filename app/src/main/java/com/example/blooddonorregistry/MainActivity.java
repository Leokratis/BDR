package com.example.blooddonorregistry;

import android.content.Intent;
import android.os.Bundle;
import android.widget.Button;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;

public class MainActivity extends AppCompatActivity {
    private TextView outputView;

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

        captchaButton.setOnClickListener(v -> runApiCall(ApiClient::getCaptcha));

        coveragesButton.setOnClickListener(v -> runApiCall(() -> ApiClient.getCoverages(ApiClient.getToken(this))));

        donationsButton.setOnClickListener(v -> runApiCall(() -> ApiClient.getDonations(ApiClient.getToken(this))));

        userButton.setOnClickListener(v -> runApiCall(() -> ApiClient.getUser(ApiClient.getToken(this), "me")));

        contactButton.setOnClickListener(v -> runApiCall(() -> ApiClient.postContact("Test", "test@example.com", null)));
    }

    @Override
    protected void onResume() {
        super.onResume();
        String authToken = ApiClient.getToken(this);
        TextView tokenView = findViewById(R.id.tokenLabel);
        tokenView.setText(authToken == null ? "Not logged in" : "Token: " + authToken);
    }

    private void runApiCall(ApiCall apiCall) {
        new Thread(() -> {
            String response = apiCall.run();
            runOnUiThread(() -> outputView.setText(response));
        }).start();
    }

    private interface ApiCall {
        String run();
    }
}
