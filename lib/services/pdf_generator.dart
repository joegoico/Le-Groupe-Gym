import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:le_groupe_gym/data/models/alumno_model.dart';
import 'package:le_groupe_gym/data/models/category_exercise_model.dart';
import 'package:le_groupe_gym/data/models/routine_model.dart';
import 'package:le_groupe_gym/data/models/dia_rutina_model.dart';

class PdfGeneratorStyle {
  final String regularFontAsset;
  final String boldFontAsset;
  final String? blockSeparatorFontAsset;
  final PdfColor? blockSeparatorBackgroundColor;
  final PdfColor blockSeparatorTextColor;
  final double blockSeparatorFontSize;
  final bool blockSeparatorBold;
  final PdfColor? superserieBackgroundColor;
  final PdfColor superserieTextColor;
  final PdfColor? dayHeaderBackgroundColor;
  final PdfColor dayHeaderTextColor;

  const PdfGeneratorStyle({
    this.regularFontAsset = 'assets/Roboto/static/Roboto-Regular.ttf',
    this.boldFontAsset = 'assets/Roboto/static/Roboto-Bold.ttf',
    this.blockSeparatorFontAsset,
    this.blockSeparatorBackgroundColor = PdfColors.blueGrey100,
    this.blockSeparatorTextColor = PdfColors.blueGrey900,
    this.blockSeparatorFontSize = 12,
    this.blockSeparatorBold = true,
    this.superserieBackgroundColor = PdfColors.amber50,
    this.superserieTextColor = PdfColors.black,
    this.dayHeaderBackgroundColor = PdfColors.blueGrey800,
    this.dayHeaderTextColor = PdfColors.white,
  });
}

class PdfGenerator {
  final PdfGeneratorStyle style;

  const PdfGenerator({this.style = const PdfGeneratorStyle()});

  Future<Uint8List> generate({required Rutina rutina, Alumno? alumno}) async {
    // Cargar los bytes crudos (rápido, no bloquea el hilo principal pesadamente)
    final fontData = await rootBundle.load(style.regularFontAsset);
    final boldFontData = await rootBundle.load(style.boldFontAsset);
    final blockSepData = style.blockSeparatorFontAsset != null
        ? await rootBundle.load(style.blockSeparatorFontAsset!)
        : null;
    final logoBytes = await rootBundle.load('assets/logo.png');

    // Despachar el trabajo de dibujo del PDF (que es muy costoso) a otro hilo (Isolate)
    return await compute(_buildPdfInBackground, {
      'rutina': rutina,
      'alumno': alumno,
      'fontBytes': fontData.buffer.asUint8List(),
      'boldFontBytes': boldFontData.buffer.asUint8List(),
      'blockSepBytes': blockSepData?.buffer.asUint8List(),
      'logoBytes': logoBytes.buffer.asUint8List(),
      'style': style,
    });
  }

  static Future<Uint8List> _buildPdfInBackground(
    Map<String, dynamic> args,
  ) async {
    final generator = PdfGenerator(style: args['style'] as PdfGeneratorStyle);
    return await generator._buildDocument(
      rutina: args['rutina'] as Rutina,
      alumno: args['alumno'] as Alumno?,
      fontBytes: args['fontBytes'] as Uint8List,
      boldFontBytes: args['boldFontBytes'] as Uint8List,
      blockSepBytes: args['blockSepBytes'] as Uint8List?,
      logoBytes: args['logoBytes'] as Uint8List,
    );
  }

  Future<Uint8List> _buildDocument({
    required Rutina rutina,
    Alumno? alumno,
    required Uint8List fontBytes,
    required Uint8List boldFontBytes,
    Uint8List? blockSepBytes,
    required Uint8List logoBytes,
  }) async {
    final pdf = pw.Document();

    final font = pw.Font.ttf(fontBytes.buffer.asByteData());
    final boldFont = pw.Font.ttf(boldFontBytes.buffer.asByteData());
    final blockSeparatorFont = blockSepBytes == null
        ? (style.blockSeparatorBold ? boldFont : font)
        : pw.Font.ttf(blockSepBytes.buffer.asByteData());

    final logoImage = pw.MemoryImage(logoBytes);

    final baseStyle = pw.TextStyle(font: font, fontSize: 12);
    final boldStyle = pw.TextStyle(font: boldFont, fontSize: 12);

    // Una página por día
    for (var i = 0; i < rutina.dias.length; i++) {
      final dia = rutina.dias[i];

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header solo en la primera página
                if (i == 0) ...[
                  _buildHeader(logoImage, alumno, rutina, boldStyle, baseStyle),
                  pw.SizedBox(height: 24),
                  pw.Divider(color: PdfColors.grey400),
                ],
                // 👇 Notas al principio — solo en primera página
                if (i == 0 &&
                    rutina.notasGenerales != null &&
                    rutina.notasGenerales!.isNotEmpty) ...[
                  pw.SizedBox(height: 16),
                  _buildNotes(rutina.notasGenerales!, baseStyle, boldStyle),
                  pw.SizedBox(height: 16),
                ],

                // Título del día
                pw.SizedBox(height: 16),
                pw.Text(
                  dia.nombre,
                  style: pw.TextStyle(font: boldFont, fontSize: 16),
                ),
                pw.SizedBox(height: 12),

                // Tabla de ejercicios del día
                _buildExerciseTable(
                  _buildExerciseTableRows(dia),
                  font,
                  boldFont,
                  blockSeparatorFont,
                ),
                pw.SizedBox(height: 24),
              ],
            );
          },
        ),
      );
    }

    return await pdf.save();
  }

  pw.Widget _buildHeader(
    pw.ImageProvider logo,
    Alumno? alumno,
    Rutina rutina,
    pw.TextStyle boldStyle,
    pw.TextStyle baseStyle,
  ) {
    // Capturamos la fecha actual y la formateamos al instante
    final fechaHoyFormateada = DateFormat('dd/MM/yyyy').format(DateTime.now());

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Image(logo, width: 80, height: 80, fit: pw.BoxFit.contain),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(rutina.nombre, style: boldStyle.copyWith(fontSize: 20)),
            if (alumno != null) ...[
              pw.SizedBox(height: 4),
              pw.Text(
                'Alumno: ${alumno.nombreCompleto}',
                style: baseStyle.copyWith(fontSize: 14),
              ),
            ],
            pw.SizedBox(height: 2),
            pw.Text(
              'Fecha: $fechaHoyFormateada', // Usamos la variable formateada acá
              style: baseStyle.copyWith(fontSize: 11, color: PdfColors.grey600),
            ),
          ],
        ),
      ],
    );
  }

  // 👇 Ahora recibe List<_ExerciseTableRow> en lugar de Rutina
  pw.Widget _buildExerciseTable(
    List<_ExerciseTableRow> filas,
    pw.Font font,
    pw.Font boldFont,
    pw.Font blockSeparatorFont,
  ) {
    final columnWidths = {
      0: const pw.FlexColumnWidth(3),
      1: const pw.FlexColumnWidth(1),
      2: const pw.FlexColumnWidth(1),
      3: const pw.FlexColumnWidth(1),
      4: const pw.FlexColumnWidth(2),
    };

    return pw.Table(
      columnWidths: columnWidths,
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
          children: ['Ejercicio', 'Series', 'Reps', 'Peso', 'Músculo']
              .map(
                (h) => pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text(
                    h,
                    style: pw.TextStyle(
                      font: boldFont,
                      color: PdfColors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
              )
              .toList(),
        ),

        // Filas
        ...filas.asMap().entries.map((entry) {
          final index = entry.key;
          final fila = entry.value;
          final isNormal =
              fila.type == _ExerciseTableRowType.normal ||
              fila.type == _ExerciseTableRowType.superserie;

          pw.TextStyle textStyle;
          PdfColor? bgColor;

          if (fila.type == _ExerciseTableRowType.blockSeparator) {
            textStyle = pw.TextStyle(
              font: blockSeparatorFont,
              fontSize: style.blockSeparatorFontSize,
              color: style.blockSeparatorTextColor,
            );
            bgColor = style.blockSeparatorBackgroundColor;
          } else if (fila.type == _ExerciseTableRowType.superserie) {
            textStyle = pw.TextStyle(
              font: font,
              fontSize: 10,
              color: style.superserieTextColor,
            );
            bgColor = style.superserieBackgroundColor;
          } else {
            textStyle = pw.TextStyle(font: font, fontSize: 10);
          }

          return pw.TableRow(
            decoration: bgColor != null
                ? pw.BoxDecoration(color: bgColor)
                : null,
            children: [
              // Columna 0 — Ejercicio
              pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text(fila.cells[0], style: textStyle),
              ),
              // Columna 1 — Series
              pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Center(
                  child: pw.Text(fila.cells[1], style: textStyle),
                ),
              ),
              // Columna 2 — Reps
              pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Center(
                  child: pw.Text(fila.cells[2], style: textStyle),
                ),
              ),
              // Columna 3 — Peso (editable solo en filas de ejercicios)
              isNormal
                  ? pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.TextField(
                        name: 'peso_$index',
                        textStyle: pw.TextStyle(font: font, fontSize: 10),
                        // 👇 sin border — el borde lo da la tabla
                      ),
                    )
                  : pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text('', style: textStyle),
                    ),
              // Columna 4 — Músculo
              pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Center(
                  child: pw.Text(fila.cells[4], style: textStyle),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  @visibleForTesting
  List<List<String>> buildExerciseTableData(Rutina rutina) {
    // Combina todas las filas de todos los días, agregando cabecera de día
    final filas = <List<String>>[];
    for (final dia in rutina.dias) {
      // Cabecera del día
      filas.add(['📅 ${dia.nombre}', '', '', '', '']);
      // Filas de bloques y ejercicios
      filas.addAll(_buildExerciseTableRows(dia).map((fila) => fila.cells));
    }
    return filas;
  }

  List<_ExerciseTableRow> _buildExerciseTableRows(DiaRutina dia) {
    final filas = <_ExerciseTableRow>[];
    var numeroTarjeta = 0;

    for (final bloque in dia.bloques) {
      if (bloque.ejercicios.isEmpty) continue;

      filas.add(
        _ExerciseTableRow.blockSeparator([
          '— ${bloque.nombre} —',
          '',
          '',
          '',
          '',
        ]),
      );

      for (final tarjeta in bloque.ejercicios) {
        numeroTarjeta++;
        if (tarjeta.esSuperserie) {
          for (var i = 0; i < tarjeta.miembros.length; i++) {
            final miembro = tarjeta.miembros[i];
            final nombre = i == 0
                ? '$numeroTarjeta. ${miembro.ejercicio.nombre} (Superserie)'
                : '   + ${miembro.ejercicio.nombre}';
            final catPrincipal = _mainMuscleName(miembro.ejercicio.categorias);
            filas.add(
              _ExerciseTableRow.superserie([
                nombre,
                miembro.series.toString(),
                miembro.repeticiones,
                '',
                catPrincipal,
              ]),
            );
          }
        } else {
          final miembro = tarjeta.miembros.first;
          final catPrincipal = _mainMuscleName(miembro.ejercicio.categorias);
          filas.add(
            _ExerciseTableRow.normal([
              '$numeroTarjeta. ${miembro.ejercicio.nombre}',
              miembro.series.toString(),
              miembro.repeticiones,
              '',
              catPrincipal,
            ]),
          );
        }
      }
    }

    return filas;
  }

  String _mainMuscleName(List<CategoriaEjercicio> categorias) {
    if (categorias.isEmpty) return '-';
    return categorias
        .firstWhere(
          (cat) => cat.tipo == 'grupo_muscular' || cat.tipo == 'grupo muscular',
          orElse: () => categorias.first,
        )
        .nombre;
  }

  pw.Widget _buildNotes(
    String notas,
    pw.TextStyle baseStyle,
    pw.TextStyle boldStyle,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Notas generales', style: boldStyle),
        pw.SizedBox(height: 6),
        pw.Text(notas, style: baseStyle),
      ],
    );
  }
}

enum _ExerciseTableRowType { blockSeparator, normal, superserie }

class _ExerciseTableRow {
  final _ExerciseTableRowType type;
  final List<String> cells;

  const _ExerciseTableRow._(this.type, this.cells);

  factory _ExerciseTableRow.blockSeparator(List<String> cells) =>
      _ExerciseTableRow._(_ExerciseTableRowType.blockSeparator, cells);

  factory _ExerciseTableRow.normal(List<String> cells) =>
      _ExerciseTableRow._(_ExerciseTableRowType.normal, cells);

  factory _ExerciseTableRow.superserie(List<String> cells) =>
      _ExerciseTableRow._(_ExerciseTableRowType.superserie, cells);
}
