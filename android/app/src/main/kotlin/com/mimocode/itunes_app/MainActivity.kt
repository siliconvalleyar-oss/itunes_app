package com.mimocode.itunes_app

import android.provider.MediaStore
import android.database.Cursor
import android.net.Uri
import android.content.ContentValues
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.mpatric.mp3agic.*
import java.io.File

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.mimocode.itunes_app/scanner"
    private val META_CHANNEL = "com.mimocode.itunes_app/metadata"

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

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, META_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "writeMetadata" -> {
                    val args = call.arguments as Map<String, Any?>
                    val contentUriStr = args["contentUri"] as String?
                    val title = args["title"] as String?
                    val artist = args["artist"] as String?
                    val album = args["album"] as String?

                    if (contentUriStr == null) {
                        result.error("INVALID_ARGS", "contentUri required", null)
                        return@setMethodCallHandler
                    }

                    try {
                        val uri = Uri.parse(contentUriStr)
                        val values = ContentValues()
                        if (title != null && title.isNotEmpty()) values.put(MediaStore.Audio.Media.TITLE, title)
                        if (artist != null && artist.isNotEmpty()) values.put(MediaStore.Audio.Media.ARTIST, artist)
                        if (album != null && album.isNotEmpty()) values.put(MediaStore.Audio.Media.ALBUM, album)
                        val updated = contentResolver.update(uri, values, null, null)
                        result.success(updated > 0)
                    } catch (e: Exception) {
                        result.error("WRITE_FAILED", e.message, null)
                    }
                }
                "writeId3Tags" -> {
                    val args = call.arguments as Map<String, Any?>
                    val filePath = args["filePath"] as String?
                    val title = args["title"] as String?
                    val artist = args["artist"] as String?
                    val album = args["album"] as String?

                    if (filePath == null) {
                        result.error("INVALID_ARGS", "filePath required", null)
                        return@setMethodCallHandler
                    }

                    try {
                        val file = File(filePath)
                        if (!file.exists()) {
                            result.error("FILE_NOT_FOUND", "File not found: $filePath", null)
                            return@setMethodCallHandler
                        }

                        val mp3 = Mp3File(filePath)
                        var tag = mp3.id3v2Tag
                        if (tag == null) {
                            tag = ID3v24Tag()
                            mp3.id3v2Tag = tag
                        }
                        if (title != null && title.isNotEmpty()) tag.title = title
                        if (artist != null && artist.isNotEmpty()) tag.artist = artist
                        if (album != null && album.isNotEmpty()) tag.album = album
                        mp3.save(filePath)

                        result.success(true)
                    } catch (e: Exception) {
                        result.error("ID3_WRITE_FAILED", e.message, null)
                    }
                }
                else -> result.notImplemented()
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
