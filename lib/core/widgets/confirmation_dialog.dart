import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final VoidCallback onConfirm;
  final VoidCallback onDismiss;
  final Color backgroundColor;
  final Color textColor;
  final bool isConfirmEnabled;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.onConfirm,
    required this.onDismiss,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black,
    this.isConfirmEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      // CORRECCIÓN: Usamos RoundedRectangleBorder en lugar de RoundedCornerShape
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      // CORRECCIÓN: Usamos la propiedad backgroundColor del Dialog
      backgroundColor: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Botón Cancelar
                Expanded(
                  child: ElevatedButton(
                    onPressed: onDismiss,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      // CORRECCIÓN: RoundedRectangleBorder aquí también
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text("Cancelar"),
                  ),
                ),
                const SizedBox(width: 16),
                // Botón Confirmar
                Expanded(
                  child: ElevatedButton(
                    onPressed: isConfirmEnabled ? onConfirm : null,
                    style: ElevatedButton.styleFrom(
                      // Usamos un color semitransparente para dar contraste si el fondo es oscuro/colorido
                      backgroundColor: Colors.black.withOpacity(0.2),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text("Confirmar"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}