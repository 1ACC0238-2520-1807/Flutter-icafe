import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/repositories/proveedor_repository.dart';
import '../../domain/entities/proveedor.dart';
import '../../../../shared/widgets/custom_app_bar.dart';

class EditarProveedorScreen extends StatefulWidget {
  final Proveedor proveedor;
  final int portfolioId;
  final VoidCallback? onBack;

  const EditarProveedorScreen({
    super.key,
    required this.proveedor,
    required this.portfolioId,
    this.onBack,
  });

  @override
  State<EditarProveedorScreen> createState() => _EditarProveedorScreenState();
}

class _EditarProveedorScreenState extends State<EditarProveedorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repository = ProveedorRepository();
  late TextEditingController _nombreController;
  late TextEditingController _rucController;
  late TextEditingController _gmailController;
  late TextEditingController _telefonoController;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.proveedor.nombre);
    _rucController = TextEditingController(text: widget.proveedor.ruc);
    _gmailController = TextEditingController(text: widget.proveedor.gmail);
    _telefonoController = TextEditingController(text: widget.proveedor.telefono);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _rucController.dispose();
    _gmailController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  void _guardarCambios() {
    if (_formKey.currentState!.validate()) {
      _mostrarDialogoConfirmacion();
    }
  }

  void _mostrarDialogoConfirmacion() {
    const oliveGreen = Color(0xFF8B7355);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '¿Quiere guardar sus cambios?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Botón Aceptar
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: oliveGreen,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              Navigator.pop(context); // Cerrar diálogo
                              
                              try {
                                // Actualizar proveedor
                                final proveedorActualizado = widget.proveedor.copyWith(
                                  nombre: _nombreController.text.trim(),
                                  ruc: _rucController.text.trim(),
                                  gmail: _gmailController.text.trim(),
                                  telefono: _telefonoController.text.trim(),
                                );
                                await _repository.actualizarProveedor(proveedorActualizado, widget.portfolioId);
                                
                                if (!mounted) return;
                                
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Cambios guardados correctamente'),
                                  ),
                                );
                                
                                // Usar post frame callback para navegar de forma segura
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  if (mounted && Navigator.canPop(context)) {
                                    Navigator.pop(context); // Cerrar pantalla de editar
                                  }
                                  if (mounted && Navigator.canPop(context)) {
                                    Navigator.pop(context); // Cerrar pantalla "Ver más" y regresar a lista
                                  }
                                });
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error: ${e.toString()}'),
                                    ),
                                  );
                                }
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: const Center(
                              child: Text(
                                'Aceptar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Botón Atrás
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context); // Solo cerrar diálogo
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: const Center(
                              child: Text(
                                'Atrás',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const lightPeach = Color(0xFFF5E6D3);
    const darkBrown = Color(0xFF5D4037);

    return Scaffold(
      backgroundColor: lightPeach,
      appBar: CustomAppBar(
        title: 'Editar Proveedor',
        onBackPressed: widget.onBack,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              // Campo Nombre
              _buildLabel('Nombre'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _nombreController,
                hintText: 'Ingresa el nombre',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              // Campo RUC
              _buildLabel('RUC'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _rucController,
                hintText: 'Ingresa el RUC',
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el RUC';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              // Campo Gmail
              _buildLabel('Gmail'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _gmailController,
                hintText: 'Ingresa el correo',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el correo';
                  }
                  if (!value.contains('@')) {
                    return 'Ingresa un correo válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              // Campo Teléfono
              _buildLabel('Teléfono'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _telefonoController,
                hintText: 'Ingresa el teléfono',
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el teléfono';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              // Botón Guardar Cambios
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: darkBrown,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  onTap: _guardarCambios,
                  borderRadius: BorderRadius.circular(16),
                  child: const Center(
                    child: Text(
                      'Guardar Cambios',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF6F4E37),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

}

