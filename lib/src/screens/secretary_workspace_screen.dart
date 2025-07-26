import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/digital_document_provider.dart';
import '../widgets/modern_card.dart';
import '../widgets/modern_button.dart';
import 'digital_documents_screen.dart';

class SecretaryWorkspaceScreen extends StatefulWidget {
  const SecretaryWorkspaceScreen({super.key});

  @override
  State<SecretaryWorkspaceScreen> createState() =>
      _SecretaryWorkspaceScreenState();
}

class _SecretaryWorkspaceScreenState extends State<SecretaryWorkspaceScreen> {
  @override
  void initState() {
    super.initState();
    // Establecer rol de secretaria en el provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DigitalDocumentProvider>().setCurrentUserRole('secretary');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Espacio de Trabajo - Secretaría'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Implementar notificaciones
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Implementar configuración
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // TODO: Implementar logout
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bienvenida
            _buildWelcomeCard(),

            const SizedBox(height: 20),

            // Acciones Rápidas
            _buildQuickActions(),

            const SizedBox(height: 20),

            // Gestión de Documentos Digitales
            _buildDigitalDocumentsSection(),

            const SizedBox(height: 20),

            // Estadísticas Rápidas
            _buildQuickStatistics(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue[100],
              child: Icon(
                Icons.person,
                size: 40,
                color: Colors.blue[800],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bienvenido, secretaria',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Secretaría - Sistema Penitenciario',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Acciones Rápidas',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ModernButton(
                text: 'Registrar Reclusos',
                icon: Icons.person_add,
                onPressed: () {
                  // TODO: Navegar a registro de reclusos
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ModernButton(
                text: 'Buscar Reclusos',
                icon: Icons.search,
                onPressed: () {
                  // TODO: Navegar a búsqueda
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ModernButton(
                text: 'Mapa de Cárcel',
                icon: Icons.map,
                onPressed: () {
                  // TODO: Navegar a mapa
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ModernButton(
                text: 'Hospitalizaciones',
                icon: Icons.local_hospital,
                onPressed: () {
                  // TODO: Navegar a hospitalizaciones
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ModernButton(
                text: 'Generar Reporte',
                icon: Icons.assessment,
                onPressed: () {
                  // TODO: Navegar a reportes
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ModernButton(
                text: 'Escáner Inteligente',
                icon: Icons.qr_code_scanner,
                onPressed: () {
                  // TODO: Navegar a escáner
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDigitalDocumentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gestión de Documentos Digitales',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        ModernCard(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.folder, color: Colors.blue[600], size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Documentos Subidos',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Solo puedes ver los documentos que has subido',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Consumer<DigitalDocumentProvider>(
                  builder: (context, provider, child) {
                    final stats = provider.getStatistics();
                    return Row(
                      children: [
                        Expanded(
                          child: _buildDocumentStat(
                            'Subidos',
                            stats['total'].toString(),
                            Icons.upload,
                            Colors.blue,
                          ),
                        ),
                        Expanded(
                          child: _buildDocumentStat(
                            'Pendientes',
                            provider.getPendingDocuments().length.toString(),
                            Icons.pending,
                            Colors.orange,
                          ),
                        ),
                        Expanded(
                          child: _buildDocumentStat(
                            'Procesados',
                            stats['processed'].toString(),
                            Icons.check_circle,
                            Colors.green,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ModernButton(
                        text: 'Ver Mis Documentos',
                        icon: Icons.folder_open,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const DigitalDocumentsScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ModernButton(
                        text: 'Subir Documento',
                        icon: Icons.upload_file,
                        onPressed: () {
                          _showUploadOptions(context);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Colors.orange[600], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Los documentos que subas serán enviados al Director para revisión. No puedes acceder a documentos de otros usuarios.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentStat(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStatistics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estadísticas Rápidas',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ModernCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(Icons.people, color: Colors.blue[600], size: 32),
                      const SizedBox(height: 8),
                      Text(
                        '1,247',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      Text(
                        'Reclusos Registrados',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ModernCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(Icons.local_hospital,
                          color: Colors.red[600], size: 32),
                      const SizedBox(height: 8),
                      Text(
                        '23',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      Text(
                        'Hospitalizaciones',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ModernCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(Icons.assessment,
                          color: Colors.green[600], size: 32),
                      const SizedBox(height: 8),
                      Text(
                        '156',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      Text(
                        'Reportes Generados',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ModernCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(Icons.upload_file,
                          color: Colors.orange[600], size: 32),
                      const SizedBox(height: 8),
                      Text(
                        '89',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      Text(
                        'Documentos Subidos',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showUploadOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Subir Documento',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ModernButton(
                    text: 'Cámara',
                    icon: Icons.camera_alt,
                    onPressed: () async {
                      Navigator.pop(context);
                      final provider = context.read<DigitalDocumentProvider>();
                      await provider.uploadDocumentFromCamera();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ModernButton(
                    text: 'Galería',
                    icon: Icons.photo_library,
                    onPressed: () async {
                      Navigator.pop(context);
                      final provider = context.read<DigitalDocumentProvider>();
                      await provider.uploadDocumentFromGallery();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ModernButton(
              text: 'Cancelar',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
