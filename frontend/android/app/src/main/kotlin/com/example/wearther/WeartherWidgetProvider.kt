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
            val face = widgetData.getString("widget_face", "😐") ?: "😐"
            val outfit = widgetData.getString("widget_outfit", "추천 옷차림: 확인 중") ?: "추천 옷차림: 확인 중"
            val temp = widgetData.getString("widget_temp", "기온 --°C") ?: "기온 --°C"
            val weather = widgetData.getString("widget_weather", "날씨 상태: 확인 중") ?: "날씨 상태: 확인 중"

            val views = RemoteViews(context.packageName, R.layout.wearther_widget).apply {
                setTextViewText(R.id.widget_face, face)
                setTextViewText(R.id.widget_title, "Wearther")
                setTextViewText(R.id.widget_outfit, outfit)
                setTextViewText(R.id.widget_temp, temp)
                setTextViewText(R.id.widget_weather, weather)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
