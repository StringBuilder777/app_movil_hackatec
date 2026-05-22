import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_card.dart';

class ActivityReportScreen extends StatefulWidget {
  final bool isCompleteAction;

  const ActivityReportScreen({super.key, required this.isCompleteAction});

  @override
  State<ActivityReportScreen> createState() => _ActivityReportScreenState();
}

class _ActivityReportScreenState extends State<ActivityReportScreen> {
  final _textController = TextEditingController();
  int _charCount = 0;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _charCount = _textController.text.length;
    });
  }

  void _handleSave(AppState state) {
    if (_textController.text.trim().isNotEmpty) {
      if (widget.isCompleteAction) {
        state.saveActivityReport(_textController.text);
        // This will trigger the Timer Screen pop automatic callback or we can pop here.
        Navigator.pop(context); // Pop Report Screen
      } else {
        // Just save a draft or log report (mock action)
        state.saveActivityReport(_textController.text);
        Navigator.pop(context);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor describe qué se hizo en la actividad.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final theme = Theme.of(context);

    // If activity was cleared, close
    if (state.activeActivity == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final active = state.activeActivity!;
    final String client = active['client'] ?? 'Planta GM';
    final String title = active['title'] ?? 'Mantenimiento Preventivo';
    final String todayString = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Reporte de Actividad'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                client.toUpperCase(),
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: theme.textTheme.headlineLarge?.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 20),

              // Metadata card
              CustomCard(
                color: AppColors.backgroundSecondary,
                border: Border.all(color: AppColors.borderActive),
                child: Column(
                  children: [
                    _buildMetadataRow(Icons.schedule_rounded, 'Timestamp', todayString),
                    const Divider(height: 16),
                    _buildMetadataRow(Icons.my_location_rounded, 'Ubicación GPS', '25.5562, -100.9314 (±8m)'),
                    const Divider(height: 16),
                    _buildMetadataRow(Icons.link_rounded, 'Actividad', title),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Text Area
              Text(
                '¿Qué se hizo?',
                style: theme.textTheme.headlineMedium?.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _textController,
                maxLines: 8,
                maxLength: 1000,
                buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null, // Hide default counter
                style: const TextStyle(fontSize: 15, color: AppColors.textDark),
                decoration: InputDecoration(
                  hintText: 'Describe a detalle el servicio realizado, refacciones cambiadas y estado final de la máquina...',
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
              const SizedBox(height: 6),

              // Character counter
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '$_charCount / 1000 caracteres',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: _charCount > 900 ? AppColors.danger : AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Bottom Actions
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Cancelar',
                      isPrimary: false,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      text: widget.isCompleteAction ? 'Completar' : 'Guardar',
                      onPressed: () => _handleSave(state),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetadataRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12, color: AppColors.textDark, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
