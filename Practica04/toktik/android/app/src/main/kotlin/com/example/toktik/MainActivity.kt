package com.example.toktik

import android.content.ComponentName
import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val iconChannel = "toktik/launcher_icon"
    private val normalSuffix = "MainActivityNormal"
    private val launcherAliases: List<String> by lazy {
        listOf(
            "$packageName.$normalSuffix",
            "$packageName.MainActivityHalloween",
            "$packageName.MainActivityChristmas",
            "$packageName.MainActivityValentines",
        )
    }

    // Icono que debe quedar activo cuando la app pase a segundo plano.
    private var pendingAlias: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, iconChannel)
            .setMethodCallHandler { call, result ->
                val theme = call.arguments as? String
                if (theme == null) {
                    result.error("invalid_theme", "A launcher theme is required.", null)
                    return@setMethodCallHandler
                }
                val aliases = launcherAliases
                val selected = "$packageName.${suffixFor(theme)}"
                when (call.method) {
                    // El usuario eligió un tema: cambio inmediato.
                    "setLauncherIcon" -> {
                        if (selected !in aliases) {
                            result.error(
                                "alias_missing",
                                "La app instalada no tiene el icono '$theme'. " +
                                    "Alias solicitado: $selected.",
                                null,
                            )
                            return@setMethodCallHandler
                        }
                        pendingAlias = null
                        try {
                            applyAlias(selected, aliases)
                            result.success(null)
                        } catch (e: Exception) {
                            result.error("icon_failed", e.message, null)
                        }
                    }
                    // Revisión al abrir la app: nunca cambia el icono en caliente.
                    "syncLauncherIcon" -> {
                        pendingAlias =
                            if (isAliasActive(selected, aliases)) null
                            else selected
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    override fun onStop() {
        super.onStop()
        pendingAlias?.let {
            pendingAlias = null
            try {
                applyAlias(it, launcherAliases)
            } catch (_: Exception) {
            }
        }
    }

    private fun suffixFor(theme: String) = when (theme) {
        "halloween" -> "MainActivityHalloween"
        "christmas" -> "MainActivityChristmas"
        "valentinesDay" -> "MainActivityValentines"
        else -> normalSuffix
    }

    private fun isEnabled(alias: String): Boolean {
        val state = packageManager.getComponentEnabledSetting(ComponentName(packageName, alias))
        return when (state) {
            PackageManager.COMPONENT_ENABLED_STATE_ENABLED -> true
            // DEFAULT = valor del AndroidManifest (solo el alias Normal viene activo).
            PackageManager.COMPONENT_ENABLED_STATE_DEFAULT -> alias == "$packageName.$normalSuffix"
            else -> false
        }
    }

    /** true si [alias] es el único alias activo (no hay nada que cambiar). */
    private fun isAliasActive(alias: String, all: List<String>): Boolean =
        all.all { other -> if (other == alias) isEnabled(other) else !isEnabled(other) }

    private fun applyAlias(selected: String, all: List<String>) {
        if (isAliasActive(selected, all)) return

        // Primero se activa el nuevo y después se desactivan los demás, así
        // siempre hay al menos un icono de lanzador activo.
        packageManager.setComponentEnabledSetting(
            ComponentName(packageName, selected),
            PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
            PackageManager.DONT_KILL_APP,
        )
        all.filter { it != selected }.forEach { alias ->
            packageManager.setComponentEnabledSetting(
                ComponentName(packageName, alias),
                PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                PackageManager.DONT_KILL_APP,
            )
        }
    }
}