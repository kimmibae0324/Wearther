package com.example.wearther

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class WeartherWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val characterState =
                widgetData.getString("widget_character_state", "보통_무표정") ?: "보통_무표정"

            val outfit =
                widgetData.getString("widget_outfit", "추천 옷차림: 확인 중") ?: "추천 옷차림: 확인 중"

            val temp =
                widgetData.getString("widget_temp", "기온 --°C") ?: "기온 --°C"

            val weather =
                widgetData.getString("widget_weather", "날씨 확인 중") ?: "날씨 확인 중"

            val views = RemoteViews(context.packageName, R.layout.wearther_widget).apply {
                setImageViewResource(
                    R.id.widget_face,
                    getDragonFaceRes(characterState)
                )

                setTextViewText(R.id.widget_title, "Wearther")
                setTextViewText(R.id.widget_outfit, outfit)
                setTextViewText(R.id.widget_temp, temp)
                setTextViewText(R.id.widget_weather, weather)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    private fun getDragonFaceRes(characterState: String): Int {
        return when (characterState) {
            "더움_땀뻘뻘" -> R.drawable.dragon_face_hot
            "추움_덜덜" -> R.drawable.dragon_face_cold
            "습함_불쾌" -> R.drawable.dragon_face_humid
            "쾌적_스마일" -> R.drawable.dragon_face_smile
            "보통_무표정" -> R.drawable.dragon_face_normal
            else -> R.drawable.dragon_face_normal
        }
    }
}