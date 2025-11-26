import 'package:flutter/material.dart';
import 'package:habitechs/main.dart';
import 'package:iconsax/iconsax.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Política de Privacidad'),
        backgroundColor: kOxfordBlue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Iconsax.shield_tick,
                  size: 60,
                  color: kTeal,
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Center(
              child: Text(
                'Política de Privacidad',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: kOxfordBlue,
                ),
              ),
            ),

            const SizedBox(height: 8),

            Center(
              child: Text(
                'Última actualización: Noviembre 2024',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Introducción
            _buildSection(
              title: '1. Introducción',
              content:
                  'HabiTex S.R.L., con domicilio en Santa Cruz de la Sierra, '
                  'Departamento de Santa Cruz, Bolivia, se compromete a proteger la privacidad '
                  'y seguridad de los datos personales de nuestros usuarios. Esta Política de Privacidad '
                  'describe cómo recopilamos, utilizamos, almacenamos y protegemos su información personal '
                  'de acuerdo con las leyes bolivianas vigentes.',
            ),

            // Información que recopilamos
            _buildSection(
              title: '2. Información que Recopilamos',
              content: 'Recopilamos la siguiente información personal:',
            ),

            _buildBulletPoint(
                'Datos de identificación: nombre completo, número de cédula de identidad, fotografía'),
            _buildBulletPoint(
                'Datos de contacto: correo electrónico, número de teléfono, dirección de residencia'),
            _buildBulletPoint(
                'Información financiera: historial de pagos, estado de cuenta de expensas comunes'),
            _buildBulletPoint(
                'Datos de uso: interacciones con la aplicación, registros de acceso al condominio'),
            _buildBulletPoint(
                'Datos de ubicación: cuando utiliza la función de compartir ubicación'),

            const SizedBox(height: 16),

            // Uso de la información
            _buildSection(
              title: '3. Uso de la Información',
              content:
                  'Utilizamos su información personal para los siguientes propósitos:',
            ),

            _buildBulletPoint(
                'Gestionar su acceso y uso de las instalaciones del condominio'),
            _buildBulletPoint(
                'Procesar pagos de expensas comunes y servicios adicionales'),
            _buildBulletPoint(
                'Facilitar la comunicación entre residentes, administración y seguridad'),
            _buildBulletPoint('Gestionar reservas de áreas comunes'),
            _buildBulletPoint(
                'Enviar notificaciones importantes sobre su condominio'),
            _buildBulletPoint(
                'Mejorar nuestros servicios y la experiencia del usuario'),
            _buildBulletPoint(
                'Cumplir con obligaciones legales y reglamentarias'),

            const SizedBox(height: 16),

            // Compartir información
            _buildSection(
              title: '4. Compartir Información',
              content:
                  'No vendemos, alquilamos ni compartimos su información personal con terceros, '
                  'excepto en los siguientes casos:',
            ),

            _buildBulletPoint(
                'Con administradores del condominio autorizados para gestión operativa'),
            _buildBulletPoint(
                'Con personal de seguridad para control de acceso'),
            _buildBulletPoint(
                'Con proveedores de servicios de pago (bajo estrictas medidas de seguridad)'),
            _buildBulletPoint(
                'Cuando sea requerido por ley o autoridades competentes'),
            _buildBulletPoint(
                'Con su consentimiento expreso para otros propósitos'),

            const SizedBox(height: 16),

            // Seguridad de datos
            _buildSection(
              title: '5. Seguridad de los Datos',
              content:
                  'Implementamos medidas de seguridad técnicas, administrativas y físicas para '
                  'proteger su información personal contra acceso no autorizado, alteración, divulgación o destrucción. '
                  'Esto incluye:',
            ),

            _buildBulletPoint(
                'Cifrado de datos sensibles mediante protocolos SSL/TLS'),
            _buildBulletPoint('Almacenamiento seguro en servidores protegidos'),
            _buildBulletPoint(
                'Acceso restringido a información personal solo para personal autorizado'),
            _buildBulletPoint('Auditorías regulares de seguridad'),
            _buildBulletPoint(
                'Autenticación de dos factores para accesos administrativos'),

            const SizedBox(height: 16),

            // Retención de datos
            _buildSection(
              title: '6. Retención de Datos',
              content:
                  'Conservamos su información personal durante el tiempo que sea necesario para '
                  'cumplir con los propósitos descritos en esta política, a menos que la ley requiera o permita '
                  'un período de retención más prolongado. Cuando su información ya no sea necesaria, '
                  'la eliminaremos o anonimizaremos de forma segura.',
            ),

            // Derechos del usuario
            _buildSection(
              title: '7. Sus Derechos',
              content:
                  'De acuerdo con la legislación boliviana, usted tiene derecho a:',
            ),

            _buildBulletPoint(
                'Acceder a su información personal que mantenemos'),
            _buildBulletPoint(
                'Solicitar la corrección de datos inexactos o incompletos'),
            _buildBulletPoint(
                'Solicitar la eliminación de sus datos personales'),
            _buildBulletPoint(
                'Oponerse al procesamiento de sus datos personales'),
            _buildBulletPoint('Solicitar la portabilidad de sus datos'),
            _buildBulletPoint('Retirar su consentimiento en cualquier momento'),

            const SizedBox(height: 8),

            _buildInfoBox(
              'Para ejercer estos derechos, puede contactarnos a través de los medios indicados en la sección de contacto.',
            ),

            // Cookies y tecnologías similares
            _buildSection(
              title: '8. Cookies y Tecnologías Similares',
              content:
                  'Utilizamos cookies y tecnologías similares para mejorar su experiencia en la aplicación, '
                  'analizar el uso del servicio y personalizar contenido. Puede gestionar las preferencias de cookies '
                  'en la configuración de su dispositivo.',
            ),

            // Menores de edad
            _buildSection(
              title: '9. Menores de Edad',
              content:
                  'Nuestra aplicación no está dirigida a menores de 18 años. No recopilamos '
                  'intencionalmente información personal de menores. Si descubrimos que hemos recopilado '
                  'información de un menor, la eliminaremos de inmediato.',
            ),

            // Transferencias internacionales
            _buildSection(
              title: '10. Transferencias Internacionales',
              content:
                  'Sus datos personales se almacenan y procesan principalmente en servidores ubicados '
                  'en Bolivia. Si realizamos transferencias internacionales de datos, nos aseguraremos de que '
                  'existan garantías adecuadas de protección según la legislación boliviana.',
            ),

            // Cambios a la política
            _buildSection(
              title: '11. Cambios a esta Política',
              content:
                  'Nos reservamos el derecho de actualizar esta Política de Privacidad periódicamente. '
                  'Le notificaremos sobre cambios significativos mediante la aplicación o por correo electrónico. '
                  'La fecha de la última actualización se indica al inicio de este documento.',
            ),

            // Contacto
            _buildSection(
              title: '12. Contacto',
              content:
                  'Si tiene preguntas, comentarios o inquietudes sobre esta Política de Privacidad '
                  'o sobre el tratamiento de sus datos personales, puede contactarnos:',
            ),

            const SizedBox(height: 16),

            // Información de contacto destacada
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kOxfordBlue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: kOxfordBlue.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildContactItem(Iconsax.building, 'HabiTex S.R.L.'),
                  _buildContactItem(Iconsax.location,
                      'Santa Cruz de la Sierra, Santa Cruz, Bolivia'),
                  _buildContactItem(Iconsax.call, 'Teléfono: +591 77699097'),
                  _buildContactItem(
                      Iconsax.sms, 'Email: javiertorrico@gmail.com'),
                  _buildContactItem(
                      Iconsax.code, 'Responsable: Javier Torrico (Developer)'),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Consentimiento
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kTeal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: kTeal.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Iconsax.tick_circle,
                    color: kTeal,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Al utilizar HabiTex, usted acepta los términos de esta Política de Privacidad.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: kOxfordBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Footer
            Center(
              child: Text(
                '© 2024 HabiTex S.R.L.\nTodos los derechos reservados',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kOxfordBlue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
              height: 1.6,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(
              Icons.circle,
              size: 6,
              color: kTeal,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox(String text) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.shade200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Iconsax.info_circle,
            color: Colors.blue.shade700,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.blue.shade900,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: kOxfordBlue,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
