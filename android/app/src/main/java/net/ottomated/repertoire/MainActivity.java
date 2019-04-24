package net.ottomated.repertoire;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.os.Parcel;
import android.util.Log;

import java.io.BufferedInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "receieve_share";
    private byte[] received;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);

        new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
                (call, result) -> {
                    if (call.method.equals("get")) {
                        result.success(received);
                    }
                });
        Intent intent = getIntent();
        String action = intent.getAction();
        if (Intent.ACTION_SEND.equals(action) || Intent.ACTION_VIEW.equals(action)) {
			Uri uri;
			if (Intent.ACTION_SEND.equals(action))
            	uri = intent.getParcelableExtra(Intent.EXTRA_STREAM);
			else if (Intent.ACTION_VIEW.equals(action))
				uri = intent.getData();
			else
				return;
            try {
                InputStream stream = getContentResolver().openInputStream(uri);
                ByteArrayOutputStream buffer = new ByteArrayOutputStream();
                int nRead;
                byte[] data = new byte[16384];

                while ((nRead = stream.read(data, 0, data.length)) != -1) {
                    buffer.write(data, 0, nRead);
                }
                received = buffer.toByteArray();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

}
