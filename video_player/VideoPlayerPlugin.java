// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.videoplayer;

import android.annotation.TargetApi;
import android.media.AudioAttributes;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.os.Build;
import android.view.Surface;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.view.TextureRegistry;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class VideoPlayerPlugin implements MethodCallHandler {
  private class VideoPlayer {
    private final TextureRegistry.SurfaceTextureEntry textureEntry;
    private final MediaPlayer mediaPlayer;
    private EventChannel.EventSink eventSink;
    private final EventChannel eventChannel;
    private boolean isPlaying = false;
    private boolean isInitialized = false;
    private boolean isLooping = false;

    @TargetApi(21)
    VideoPlayer(
        final EventChannel eventChannel,
        final TextureRegistry.SurfaceTextureEntry textureEntry,
        String dataSource,
        final Result result) {
      this.eventChannel = eventChannel;
      eventChannel.setStreamHandler(
          new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object o, EventChannel.EventSink sink) {
              eventSink = sink;
              sendInitialized();
            }

            @Override
            public void onCancel(Object o) {
              eventSink = null;
            }
          });
      this.textureEntry = textureEntry;
      this.mediaPlayer = new MediaPlayer();
      try {
        mediaPlayer.setSurface(new Surface(textureEntry.surfaceTexture()));
        mediaPlayer.setDataSource(dataSource);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT_WATCH) {
          mediaPlayer.setAudioAttributes(
              new AudioAttributes.Builder()
                  .setContentType(AudioAttributes.CONTENT_TYPE_MOVIE)
                  .build());
        } else {
          mediaPlayer.setAudioStreamType(AudioManager.STREAM_MUSIC);
        }
        mediaPlayer.setOnPreparedListener(
            new MediaPlayer.OnPreparedListener() {
              @Override
              public void onPrepared(MediaPlayer mp) {
                mediaPlayer.setOnBufferingUpdateListener(
                    new MediaPlayer.OnBufferingUpdateListener() {
                      @Override
                      public void onBufferingUpdate(MediaPlayer mediaPlayer, int i) {
                        if (eventSink != null) {
                          Map<String, Object> event = new HashMap<>();
                          event.put("event", "bufferingUpdate");
                          List<Integer> range = new ArrayList<>();
                          range.add(0);
                          range.add(i * mediaPlayer.getDuration() / 100);
                          // iOS supports a list of buffered ranges, so here is a list with a single range.
                          List<List<Integer>> ranges = new ArrayList<>();
                          ranges.add(range);
                          event.put("values", ranges);
                          eventSink.success(event);
                        }
                      }
                    });
                isInitialized = true;
                sendInitialized();
              }
            });

        mediaPlayer.setOnErrorListener(
            new MediaPlayer.OnErrorListener() {
              @Override
              public boolean onError(MediaPlayer mp, int what, int extra) {
                eventSink.error(
                    "VideoError", "Video player had error " + what + " extra " + extra, null);
                return true;
              }
            });

        mediaPlayer.setOnCompletionListener(
            new MediaPlayer.OnCompletionListener() {
              @Override
              public void onCompletion(MediaPlayer mediaPlayer) {
                Map<String, Object> event = new HashMap<>();
                event.put("event", "completed");
                eventSink.success(event);
              }
            });

        mediaPlayer.prepareAsync();
      } catch (IOException e) {
        result.error("VideoError", "IOError when initializing video player " + e.toString(), null);
      }
      Map<String, Object> reply = new HashMap<>();
      reply.put("textureId", textureEntry.id());
      result.success(reply);
    }

    void play() {
      if (!mediaPlayer.isPlaying()) {
        mediaPlayer.start();
      }
    }

    void pause() {
      if (mediaPlayer.isPlaying()) {
        mediaPlayer.pause();
      }
    }

    void setLooping(boolean isLooping) {
      mediaPlayer.setLooping(isLooping);
    }

    void setVolume(double volume) {
      float bracketedVolume = (float) Math.max(0.0, Math.min(1.0, volume));
      mediaPlayer.setVolume(bracketedVolume, bracketedVolume);
    }

    void seekTo(int location) {
      mediaPlayer.seekTo(location);
    }

    int getPosition() {
      return mediaPlayer.getCurrentPosition();
    }

    private void sendInitialized() {
      if (isInitialized && eventSink != null) {
        Map<String, Object> event = new HashMap<>();
        event.put("event", "initialized");
        event.put("duration", mediaPlayer.getDuration());
        eventSink.success(event);
      }
    }

    void dispose() {
      if (isInitialized && mediaPlayer.isPlaying()) {
        mediaPlayer.stop();
      }
      mediaPlayer.reset();
      mediaPlayer.release();
      textureEntry.release();
      eventChannel.setStreamHandler(null);
    }
  }

  public static void registerWith(Registrar registrar) {
    final MethodChannel channel =
        new MethodChannel(registrar.messenger(), "flutter.io/videoPlayer");
    channel.setMethodCallHandler(
        new VideoPlayerPlugin(registrar.messenger(), registrar.textures()));
  }

  private VideoPlayerPlugin(BinaryMessenger messenger, TextureRegistry textures) {
    this.textures = textures;
    this.videoPlayers = new HashMap<>();
    this.messenger = messenger;
  }

  private final Map<Long, VideoPlayer> videoPlayers;
  private final TextureRegistry textures;
  private final BinaryMessenger messenger;

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("init")) {
      for (VideoPlayer player : videoPlayers.values()) {
        player.dispose();
      }
      videoPlayers.clear();
    } else if (call.method.equals("create")) {
      TextureRegistry.SurfaceTextureEntry handle = textures.createSurfaceTexture();
      EventChannel eventChannel =
          new EventChannel(messenger, "flutter.io/videoPlayer/videoEvents" + handle.id());
      videoPlayers.put(
          handle.id(),
          new VideoPlayer(eventChannel, handle, (String) call.argument("dataSource"), result));
    } else {
      long textureId = ((Number) call.argument("textureId")).longValue();
      VideoPlayer player = videoPlayers.get(textureId);
      if (player == null) {
        result.error(
            "Unknown textureId", "No video player associated with texture id " + textureId, null);
        return;
      }
      switch (call.method) {
        case "setLooping":
          player.setLooping((Boolean) call.argument("looping"));
          result.success(null);
          break;
        case "setVolume":
          player.setVolume((Double) call.argument("volume"));
          result.success(null);
          break;
        case "play":
          player.play();
          result.success(null);
          break;
        case "pause":
          player.pause();
          result.success(null);
          break;
        case "seekTo":
          int location = ((Number) call.argument("location")).intValue();
          player.seekTo(location);
          result.success(null);
          break;
        case "position":
          result.success(player.getPosition());
          break;
        case "dispose":
          player.dispose();
          result.success(null);
          break;
        default:
          result.notImplemented();
          break;
      }
    }
  }
}
