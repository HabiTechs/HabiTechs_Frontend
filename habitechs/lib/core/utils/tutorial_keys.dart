import 'package:flutter/material.dart';

class TutorialKeys {
  // Keys de la Pantalla Principal
  static final GlobalKey appBarTitle = GlobalKey(); // Título Bienvenida
  static final GlobalKey menuBtn = GlobalKey(); // 3 Rayas
  static final GlobalKey logoutBtn = GlobalKey(); // Puerta Salida
  static final GlobalKey bottomNav = GlobalKey(); // Barra Inferior (General)

  // Keys Específicas del Bottom Navigation Bar
  static final GlobalKey navInicio = GlobalKey();
  static final GlobalKey navAnuncios = GlobalKey();
  static final GlobalKey navFinanzas = GlobalKey();
  static final GlobalKey navReservas = GlobalKey();
  static final GlobalKey navTickets = GlobalKey();

  // Keys de Tarjetas (Dashboard)
  static final GlobalKey qrCard = GlobalKey();
  static final GlobalKey finanzasCard = GlobalKey();
  static final GlobalKey anunciosCard = GlobalKey();
  static final GlobalKey ticketsCard = GlobalKey();

  // Keys dentro del Menú Flotante
  static final GlobalKey menuPerfil = GlobalKey();
  static final GlobalKey menuContactos = GlobalKey();
  static final GlobalKey menuChatAdmin = GlobalKey(); // Nuevo
  static final GlobalKey menuChatSeguridad = GlobalKey(); // Nuevo
  static final GlobalKey menuTutorial = GlobalKey();
  static final GlobalKey menuSalir = GlobalKey();
}
