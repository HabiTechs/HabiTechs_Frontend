class AppConfig {
  // ¡¡CRÍTICO!!
  // Esta es la URL especial para el Emulador de Android
  // Si usas un Emulador iOS, puedes usar 'http://localhost:5100'
  // Si usas un teléfono físico, cambia esto por la IP de tu PC en la red
  // (ej. 'http://192.168.1.100:5100')

  // --- CAMBIO PARA WEB (CHROME) ---
  // Tu navegador CHROME SÍ puede ver "localhost" directamente.
  static const String apiBaseUrl =
      'http://localhost:5100'; // ✅ Para emulador Android
  // static const String apiBaseUrl = 'http://192.168.1.XXX:5100';  // ✅ Para celular físico (reemplaza XXX con tu IP)
}
