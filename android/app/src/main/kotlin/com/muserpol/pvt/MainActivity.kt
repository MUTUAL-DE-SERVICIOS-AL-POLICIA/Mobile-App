package com.muserpol.pvt

import android.app.NotificationManager
import android.content.Context
import android.net.Uri
import android.os.Bundle
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity: FlutterFragmentActivity() {

    override fun onResume() {
        super.onResume()
        closeAllNotifications()
        handleRedirectUri()
    }

    private fun closeAllNotifications() {
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.cancelAll()  // Cancela todas las notificaciones activas
    }

    private fun handleRedirectUri() {
        // Verifica si hay datos en el Intent (como la URI de redirección)
        val intent = intent
        val uri: Uri? = intent.data
        
        // Si la URI corresponde al esquema y ruta definidos en el Manifest
        if (uri != null && uri.toString().startsWith("com.muserpol.pvt:/oauth2redirect")) {
            val token = uri.getQueryParameter("token")
            val state = uri.getQueryParameter("state")
            
            // Aquí puedes procesar el token o hacer lo que necesites con la URI
            // Por ejemplo, guardarlo en SharedPreferences o redirigir a otra actividad
            // Si deseas hacer algo con los parámetros:
            // Log.d("MainActivity", "Token: $token, State: $state")
        }
    }
}
