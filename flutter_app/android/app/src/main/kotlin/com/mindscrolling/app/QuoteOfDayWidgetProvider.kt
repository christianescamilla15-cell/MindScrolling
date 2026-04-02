package com.mindscrolling.app

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class QuoteOfDayWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.quote_widget)

            val quoteText = widgetData.getString("quote_text", "Swipe to discover wisdom")
            val quoteAuthor = widgetData.getString("quote_author", "MindScrolling")

            views.setTextViewText(R.id.quote_text, "\"$quoteText\"")
            views.setTextViewText(R.id.quote_author, "— $quoteAuthor")

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
