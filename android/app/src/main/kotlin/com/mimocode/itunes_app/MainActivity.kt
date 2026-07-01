package com.mimocode.itunes_app

import android.provider.MediaStore
import android.database.Cursor
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.mimocode.itunes_app/scanner"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getAudioFiles") {
                val songs = getAudioFiles()
                result.success(songs)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun getAudioFiles(): List<Map<String, Any?>> {
        val songs = mutableListOf<Map<String, Any?>>()
        val uri = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI
        val projection = arrayOf(
            MediaStore.Audio.Media._ID,
            MediaStore.Audio.Media.TITLE,
            MediaStore.Audio.Media.ARTIST,
            MediaStore.Audio.Media.ALBUM,
            MediaStore.Audio.Media.DURATION,
            MediaStore.Audio.Media.SIZE,
            MediaStore.Audio.Media.DATA
        )
        val selection = "${MediaStore.Audio.Media.IS_MUSIC} = 1"
        val sortOrder = "${MediaStore.Audio.Media.TITLE} ASC"

        val cursor: Cursor? = contentResolver.query(uri, projection, selection, null, sortOrder)
        cursor?.use {
            val idCol = it.getColumnIndex(MediaStore.Audio.Media._ID)
            val titleCol = it.getColumnIndex(MediaStore.Audio.Media.TITLE)
            val artistCol = it.getColumnIndex(MediaStore.Audio.Media.ARTIST)
            val albumCol = it.getColumnIndex(MediaStore.Audio.Media.ALBUM)
            val durationCol = it.getColumnIndex(MediaStore.Audio.Media.DURATION)
            val sizeCol = it.getColumnIndex(MediaStore.Audio.Media.SIZE)
            val dataCol = it.getColumnIndex(MediaStore.Audio.Media.DATA)

            while (it.moveToNext()) {
                val id = it.getLong(idCol)
                val title = it.getString(titleCol) ?: "Desconocido"
                val artist = it.getString(artistCol) ?: "Desconocido"
                val album = it.getString(albumCol) ?: "Sin álbum"
                val duration = it.getInt(durationCol)
                val size = it.getLong(sizeCol)
                val data = it.getString(dataCol)
                val contentUri = "${MediaStore.Audio.Media.EXTERNAL_CONTENT_URI}/$id"

                songs.add(mapOf(
                    "id" to id.toString(),
                    "title" to title,
                    "artist" to artist,
                    "album" to album,
                    "duration" to duration,
                    "size" to size,
                    "filePath" to (data ?: ""),
                    "contentUri" to contentUri
                ))
            }
        }
        return songs
    }
}
