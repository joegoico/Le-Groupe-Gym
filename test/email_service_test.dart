import 'package:flutter_test/flutter_test.dart';
import 'package:le_groupe_gym/services/email_service.dart';

void main() {
  group('EmailService Tests', () {

    test('buildPayload debe armar el body correcto para la Edge Function', () {
      // Arrange
      final service = EmailService();

      // Act
      final payload = service.buildPayload(
        pdfUrl: 'https://storage.supabase.co/rutinas-pdf/test.pdf',
        mailAlumno: 'juan@mail.com',
        nombreAlumno: 'Juan Pérez',
        nombreRutina: 'Día 1 - Empuje',
      );

      // Assert
      expect(payload['pdfUrl'], 'https://storage.supabase.co/rutinas-pdf/test.pdf');
      expect(payload['mailAlumno'], 'juan@mail.com');
      expect(payload['nombreAlumno'], 'Juan Pérez');
      expect(payload['nombreRutina'], 'Día 1 - Empuje');
    });

    test('buildPayload debe lanzar excepción si mailAlumno está vacío', () {
      // Arrange
      final service = EmailService();

      // Act + Assert
      expect(
        () => service.buildPayload(
          pdfUrl: 'https://storage.supabase.co/test.pdf',
          mailAlumno: '',
          nombreAlumno: 'Juan Pérez',
          nombreRutina: 'Día 1 - Empuje',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}