import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
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
  });
}

class PdfGenerator {
  final PdfGeneratorStyle style;

  const PdfGenerator({this.style = const PdfGeneratorStyle()});

  Future<Uint8List> generate({
    required Rutina rutina,
    required Alumno alumno,
  }) async {
    final pdf = pw.Document();

    final fontData = await rootBundle.load(style.regularFontAsset);
    final boldFontData = await rootBundle.load(style.boldFontAsset);
    final font = pw.Font.ttf(fontData);
    final boldFont = pw.Font.ttf(boldFontData);
    final blockSeparatorFont = style.blockSeparatorFontAsset == null
        ? (style.blockSeparatorBold ? boldFont : font)
        : pw.Font.ttf(await rootBundle.load(style.blockSeparatorFontAsset!));

    final logoBytes = await rootBundle.load('assets/logo.png');
    final logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());

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

                // Notas solo en última página
                if (i == rutina.dias.length - 1 &&
                    rutina.notasGenerales != null &&
                    rutina.notasGenerales!.isNotEmpty)
                  _buildNotes(rutina.notasGenerales!, baseStyle, boldStyle),

                pw.Spacer(),
                _buildFooter(baseStyle),
              ],
            );
          },
        ),
      );
    }

    return pdf.save();
  }

  pw.Widget _buildHeader(
    pw.MemoryImage logo,
    Alumno alumno,
    Rutina rutina,
    pw.TextStyle boldStyle,
    pw.TextStyle baseStyle,
  ) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Image(logo, width: 80, height: 80, fit: pw.BoxFit.contain),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(rutina.nombre, style: boldStyle.copyWith(fontSize: 20)),
            pw.SizedBox(height: 4),
            pw.Text(
              'Alumno: ${alumno.nombreCompleto}',
              style: baseStyle.copyWith(color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              'Fecha: ${_formatDate(rutina.fechaCreacion)}',
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
    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(font: boldFont, color: PdfColors.white),
      cellStyle: pw.TextStyle(font: font),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
      cellDecoration: (_, _, rowNum) {
        final row = _rowForTableIndex(filas, rowNum);
        return pw.BoxDecoration(color: _backgroundColorForRow(row?.type));
      },
      textStyleBuilder: (_, _, rowNum) {
        final row = _rowForTableIndex(filas, rowNum);
        if (row?.type == _ExerciseTableRowType.blockSeparator) {
          return pw.TextStyle(
            font: blockSeparatorFont,
            fontSize: style.blockSeparatorFontSize,
            color: style.blockSeparatorTextColor,
          );
        }
        if (row?.type == _ExerciseTableRowType.superserie) {
          return pw.TextStyle(font: font, color: style.superserieTextColor);
        }
        return pw.TextStyle(font: font);
      },
      cellHeight: 36,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.center,
        2: pw.Alignment.center,
        3: pw.Alignment.center,
        4: pw.Alignment.center,
      },
      headers: ['Ejercicio', 'Series', 'Repeticiones', 'Peso', 'Músculo'],
      data: filas.map((fila) => fila.cells).toList(growable: false),
    );
  }

  @visibleForTesting
  List<List<String>> buildExerciseTableData(Rutina rutina) {
    // Combina todas las filas de todos los días
    return rutina.dias
        .expand((dia) => _buildExerciseTableRows(dia))
        .map((fila) => fila.cells)
        .toList(growable: false);
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

  _ExerciseTableRow? _rowForTableIndex(
    List<_ExerciseTableRow> filas,
    int rowNum,
  ) {
    final dataIndex = rowNum - 1;
    if (dataIndex < 0 || dataIndex >= filas.length) return null;
    return filas[dataIndex];
  }

  PdfColor? _backgroundColorForRow(_ExerciseTableRowType? type) {
    if (type == _ExerciseTableRowType.blockSeparator) {
      return style.blockSeparatorBackgroundColor;
    }
    if (type == _ExerciseTableRowType.superserie) {
      return style.superserieBackgroundColor;
    }
    return null;
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

  pw.Widget _buildFooter(pw.TextStyle baseStyle) {
    return pw.Center(
      child: pw.Text(
        'Le Groupe Gym',
        style: baseStyle.copyWith(fontSize: 10, color: PdfColors.grey500),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
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
