import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../../domain/entities/stock_movement.dart';
import '../models/inventory_models.dart';

class MovementsPdfService {
  static Future<File> generateMovementsReport({
    required List<StockMovement> movements,
    required Map<int, SupplyItemResource> supplyItemsMap,
    required String filterType,
  }) async {
    final pdf = pw.Document();

    // Colores del tema café
    final darkBrown = PdfColor.fromHex('#6F4E37');
    final olive = PdfColor.fromHex('#8B7355');
    final lightPeach = PdfColor.fromHex('#F5E6D3');
    final greenColor = PdfColor.fromHex('#10B981');
    final redColor = PdfColor.fromHex('#EF4444');

    // Calcular totales
    double totalEntradas = 0;
    double totalSalidas = 0;
    for (final m in movements) {
      if (m.isEntrada) {
        totalEntradas += m.quantity;
      } else {
        totalSalidas += m.quantity;
      }
    }

    final now = DateTime.now();
    final dateStr = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => _buildHeader(darkBrown, dateStr, timeStr, filterType),
        footer: (context) => _buildFooter(context, olive),
        build: (context) => [
          pw.SizedBox(height: 20),
          // Resumen
          _buildSummarySection(movements.length, totalEntradas, totalSalidas, lightPeach, greenColor, redColor, darkBrown),
          pw.SizedBox(height: 30),
          // Tabla de movimientos
          _buildMovementsTable(movements, supplyItemsMap, darkBrown, olive, greenColor, redColor),
        ],
      ),
    );

    // Guardar el archivo
    final output = await getApplicationDocumentsDirectory();
    final fileName = 'movimientos_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour}${now.minute}.pdf';
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  static pw.Widget _buildHeader(PdfColor darkBrown, String date, String time, String filterType) {
    String filterLabel = filterType == 'TODOS' 
        ? 'Todos los movimientos' 
        : filterType == 'ENTRADA' 
            ? 'Solo entradas' 
            : 'Solo salidas';

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'iCafé',
                  style: pw.TextStyle(
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                    color: darkBrown,
                  ),
                ),
                pw.Text(
                  'Reporte de Movimientos de Inventario',
                  style: pw.TextStyle(
                    fontSize: 14,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'Generado: $date',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                ),
                pw.Text(
                  'Hora: $time',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                ),
                pw.SizedBox(height: 4),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey200,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Text(
                    filterLabel,
                    style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                  ),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Divider(color: darkBrown, thickness: 2),
      ],
    );
  }

  static pw.Widget _buildFooter(pw.Context context, PdfColor olive) {
    return pw.Column(
      children: [
        pw.Divider(color: PdfColors.grey300),
        pw.SizedBox(height: 5),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'iCafé - Sistema de Gestión',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500),
            ),
            pw.Text(
              'Página ${context.pageNumber} de ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildSummarySection(
    int totalMovements,
    double totalEntradas,
    double totalSalidas,
    PdfColor lightPeach,
    PdfColor greenColor,
    PdfColor redColor,
    PdfColor darkBrown,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: lightPeach,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('Total Movimientos', totalMovements.toString(), darkBrown),
          _buildSummaryItem('Total Entradas', '+${totalEntradas.toStringAsFixed(0)}', greenColor),
          _buildSummaryItem('Total Salidas', '-${totalSalidas.toStringAsFixed(0)}', redColor),
        ],
      ),
    );
  }

  static pw.Widget _buildSummaryItem(String label, String value, PdfColor color) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
        ),
      ],
    );
  }

  static pw.Widget _buildMovementsTable(
    List<StockMovement> movements,
    Map<int, SupplyItemResource> supplyItemsMap,
    PdfColor darkBrown,
    PdfColor olive,
    PdfColor greenColor,
    PdfColor redColor,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(2.5),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(2),
        4: const pw.FlexColumnWidth(1.5),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: pw.BoxDecoration(color: darkBrown),
          children: [
            _buildTableHeader('Insumo'),
            _buildTableHeader('Tipo'),
            _buildTableHeader('Cantidad'),
            _buildTableHeader('Origen'),
            _buildTableHeader('Fecha'),
          ],
        ),
        // Rows
        ...movements.map((movement) {
          final supplyItem = supplyItemsMap[movement.supplyItemId];
          final itemName = supplyItem?.name ?? 'Insumo #${movement.supplyItemId}';
          final itemUnit = _formatUnit(supplyItem?.unit);
          final isEntrada = movement.isEntrada;

          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: movements.indexOf(movement) % 2 == 0 
                  ? PdfColors.white 
                  : PdfColors.grey100,
            ),
            children: [
              _buildTableCell(itemName),
              _buildTableCellColored(
                isEntrada ? 'Entrada' : 'Salida',
                isEntrada ? greenColor : redColor,
              ),
              _buildTableCellColored(
                '${isEntrada ? '+' : '-'}${movement.quantity.toStringAsFixed(0)} $itemUnit',
                isEntrada ? greenColor : redColor,
              ),
              _buildTableCell(movement.origin),
              _buildTableCell(_formatDateTime(movement.movementDate)),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _buildTableHeader(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static pw.Widget _buildTableCell(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static pw.Widget _buildTableCellColored(String text, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
          color: color,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static String _formatUnit(String? unit) {
    if (unit == null || unit.isEmpty) return '';
    switch (unit.toUpperCase()) {
      case 'GRAMOS':
        return 'g';
      case 'KILOGRAMOS':
        return 'kg';
      case 'MILILITROS':
        return 'ml';
      case 'LITROS':
        return 'L';
      case 'UNIDADES':
        return 'uds';
      case 'PIEZAS':
        return 'pzas';
      default:
        return unit.toLowerCase();
    }
  }

  static String _formatDateTime(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}\n${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  static Future<void> openPdf(File file) async {
    await OpenFile.open(file.path);
  }
}
