import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/digital_document_provider.dart';
import '../models/digital_document.dart';
import '../widgets/modern_button.dart';
import '../providers/auth_provider.dart'; // Added import for AuthProvider
import '../screens/pdf_viewer_screen.dart'; // Added import for PDFViewerScreen

class DigitalDocumentsScreen extends StatefulWidget {
  const DigitalDocumentsScreen({super.key});

  @override
  State<DigitalDocumentsScreen> createState() => _DigitalDocumentsScreenState();
}

class _DigitalDocumentsScreenState extends State<DigitalDocumentsScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _aiController;
  late AnimationController _voiceController;
  late AnimationController _pulseController;
  late AnimationController _slideController;

  bool _isListening = false;
  bool _showAIInsights = false;
  bool _showQuickActions = false;
  bool _showVoiceCommands = false;
  final String _voiceQuery = '';
  String _currentCommand = '';

  // Estados de gestos
  bool _isDragging = false;
  Offset _dragOffset = Offset.zero;

  // Estados de procesamiento
  bool _isProcessingDocument = false;
  String _processingStatus = '';
  Map<String, dynamic>? _lastProcessedDocument;

  // Comandos de voz disponibles
  final List<Map<String, dynamic>> _voiceCommands = [
    {
      'command': 'mostrar críticos',
      'action': 'filter_critical',
      'description': 'Filtrar documentos críticos',
      'icon': Icons.warning,
    },
    {
      'command': 'mostrar gastos',
      'action': 'filter_expenses',
      'description': 'Mostrar solo gastos',
      'icon': Icons.account_balance_wallet,
    },
    {
      'command': 'mostrar contratos',
      'action': 'filter_contracts',
      'description': 'Filtrar contratos',
      'icon': Icons.description,
    },
    {
      'command': 'subir documento',
      'action': 'upload_document',
      'description': 'Abrir subida de documentos',
      'icon': Icons.upload_file,
    },
    {
      'command': 'análisis completo',
      'action': 'full_analysis',
      'description': 'Ejecutar análisis completo',
      'icon': Icons.analytics,
    },
  ];

  // Acciones rápidas
  final List<Map<String, dynamic>> _quickActions = [
    {
      'title': '📸 Escanear',
      'action': 'scan',
      'color': Colors.blue,
      'icon': Icons.camera_alt,
    },
    {
      'title': '🎤 Voz',
      'action': 'voice',
      'color': Colors.purple,
      'icon': Icons.mic,
    },
    {
      'title': '🤖 IA',
      'action': 'ai',
      'color': Colors.green,
      'icon': Icons.psychology,
    },
    {
      'title': '📊 Análisis',
      'action': 'analytics',
      'color': Colors.orange,
      'icon': Icons.analytics,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    // NO cargar documentos automáticamente - solo cuando el usuario escanee
  }

  void _initializeAnimations() {
    _aiController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _voiceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _aiController.repeat();
    _pulseController.repeat(reverse: true);
  }

  void _loadDocuments() {
    // Cargar documentos existentes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DigitalDocumentProvider>().loadDocuments();
    });
  }

  @override
  void dispose() {
    _aiController.dispose();
    _voiceController.dispose();
    _pulseController.dispose();
    _slideController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: Stack(
        children: [
          // Contenido principal
          CustomScrollView(
            slivers: [
              _buildFuturisticHeader(),
              _buildQuickActionsPanel(),
              _buildVoiceCommandsPanel(),
              _buildAIPanel(),
              _buildMainContent(),
            ],
          ),

          // Overlay de comandos de voz
          if (_showVoiceCommands) _buildVoiceCommandsOverlay(),

          // Overlay de drag & drop
          if (_isDragging) _buildDragOverlay(),

          // Overlay de procesamiento
          if (_isProcessingDocument) _buildProcessingOverlay(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildFuturisticHeader() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
              Color(0xFF0F3460),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con navegación y controles
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'AI Document Hub',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
                _buildControlButton(
                  icon: Icons.touch_app,
                  onTap: () =>
                      setState(() => _showQuickActions = !_showQuickActions),
                  isActive: _showQuickActions,
                ),
                const SizedBox(width: 8),
                _buildControlButton(
                  icon: Icons.mic,
                  onTap: () =>
                      setState(() => _showVoiceCommands = !_showVoiceCommands),
                  isActive: _showVoiceCommands,
                ),
                const SizedBox(width: 8),
                _buildControlButton(
                  icon: Icons.psychology,
                  onTap: () =>
                      setState(() => _showAIInsights = !_showAIInsights),
                  isActive: _showAIInsights,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Barra de comandos de voz
            _buildVoiceCommandBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton(
      {required IconData icon,
      required VoidCallback onTap,
      required bool isActive}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isActive
                ? [Colors.purple, Colors.blue]
                : [Colors.grey.withOpacity(0.3), Colors.grey.withOpacity(0.1)],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? Colors.purple : Colors.grey.withOpacity(0.5),
          ),
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.white : Colors.grey,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildVoiceCommandBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.withOpacity(0.2),
            Colors.purple.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _toggleVoiceSearch,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isListening ? Colors.red : Colors.blue,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: (_isListening ? Colors.red : Colors.blue)
                        .withOpacity(0.3),
                    blurRadius: _isListening ? 15 : 8,
                    spreadRadius: _isListening ? 2 : 0,
                  ),
                ],
              ),
              child: Icon(
                _isListening ? Icons.stop : Icons.mic,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _isListening
                  ? 'Escuchando... Di un comando'
                  : 'Toca el micrófono y di un comando',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
          if (_currentCommand.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _currentCommand,
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsPanel() {
    if (!_showQuickActions) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Acciones Rápidas',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: _quickActions
                  .map((action) => Expanded(
                        child: GestureDetector(
                          onTap: () => _executeQuickAction(action['action']),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  action['color'].withOpacity(0.3),
                                  action['color'].withOpacity(0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: action['color'].withOpacity(0.3)),
                            ),
                            child: Column(
                              children: [
                                Icon(action['icon'],
                                    color: action['color'], size: 24),
                                const SizedBox(height: 8),
                                Text(
                                  action['title'],
                                  style: TextStyle(
                                    color: action['color'],
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceCommandsPanel() {
    if (!_showVoiceCommands) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.purple.withOpacity(0.2),
              Colors.blue.withOpacity(0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.purple.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.mic, color: Colors.purple, size: 20),
                SizedBox(width: 8),
                Text(
                  'Comandos de Voz',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._voiceCommands.map((command) => _buildVoiceCommandItem(command)),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceCommandItem(Map<String, dynamic> command) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(command['icon'], color: Colors.purple, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '"${command['command']}"',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  command['description'],
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIPanel() {
    if (!_showAIInsights) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AnimatedBuilder(
                  animation: _aiController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _aiController.value * 2 * 3.14159,
                      child: const Icon(
                        Icons.psychology,
                        color: Colors.purple,
                        size: 24,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                const Text(
                  'AI Insights',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Panel de procesamiento reciente
            if (_lastProcessedDocument != null) _buildProcessingResultCard(),

            _buildAIInsightCard(
              '⚠️ Documento Crítico',
              'Presupuesto 2026 requiere aprobación inmediata',
              'Alta',
              Colors.red,
              () => _showCriticalDocument(),
            ),
            _buildAIInsightCard(
              '📊 Análisis de Gastos',
              'Gastos mensuales 15% sobre presupuesto',
              'Media',
              Colors.orange,
              () => _showExpenseAnalysis(),
            ),
            _buildAIInsightCard(
              '🤖 IA Recomienda',
              '3 contratos próximos a vencer',
              'Baja',
              Colors.blue,
              () => _showContractAnalysis(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingResultCard() {
    final doc = _lastProcessedDocument!;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.withOpacity(0.3),
            Colors.blue.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Documento Procesado Exitosamente',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'NUEVO',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildProcessingDetail(
              'Tipo detectado', doc['type'] ?? 'Desconocido'),
          _buildProcessingDetail(
              'Monto extraído', doc['amount'] ?? 'No detectado'),
          _buildProcessingDetail('Empresa', doc['company'] ?? 'No detectada'),
          _buildProcessingDetail('Fecha', doc['date'] ?? 'No detectada'),
          _buildProcessingDetail(
              'Prioridad asignada', doc['priority'] ?? 'Media'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ModernButton(
                  text: 'Ver Documento',
                  icon: Icons.visibility,
                  onPressed: () {
                    // Obtener el documento real del provider
                    final documents = context
                        .read<DigitalDocumentProvider>()
                        .filteredDocuments;
                    final realDocument = documents.firstWhere(
                      (document) => document.title == doc['title'],
                      orElse: () => documents.first,
                    );

                    final authProvider = context.read<AuthProvider>();
                    final isDirector = authProvider.role == 'Director General';

                    // Abrir el visor PDF directamente
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PDFViewerScreen(
                          document: realDocument,
                          isDirector: isDirector,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ModernButton(
                  text: 'Escanear Otro',
                  icon: Icons.camera_alt,
                  onPressed: () => _executeQuickAction('scan'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIInsightCard(String title, String message, String priority,
      Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.2),
              color.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.info,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                priority,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Consumer<DigitalDocumentProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.blue),
                  SizedBox(height: 16),
                  Text(
                    'Cargando documentos...',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          );
        }

        final documents = provider.filteredDocuments;

        if (documents.isEmpty) {
          return SliverFillRemaining(
            child: _buildEmptyState(),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final document = documents[index];
              return _buildDocumentCard(document, provider);
            },
            childCount: documents.length,
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.withOpacity(0.3),
                  Colors.purple.withOpacity(0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.cloud_upload,
              size: 60,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No hay documentos',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Usa los comandos de voz o las acciones rápidas',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ModernButton(
                text: '📸 Escanear',
                icon: Icons.camera_alt,
                onPressed: () => _executeQuickAction('scan'),
              ),
              const SizedBox(width: 16),
              ModernButton(
                text: '🎤 Voz',
                icon: Icons.mic,
                onPressed: () => setState(() => _showVoiceCommands = true),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(
      DigitalDocument document, DigitalDocumentProvider provider) {
    return GestureDetector(
      onLongPress: () => _startDrag(document),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: InkWell(
            onTap: () => _showDocumentDetails(document),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getDocumentTypeColor(document.documentType)
                              .withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          document.documentType.displayName,
                          style: TextStyle(
                            color: _getDocumentTypeColor(document.documentType),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      _buildPriorityBadge(document.priority),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    document.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (document.description.isNotEmpty)
                    Text(
                      document.description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (document.montoTotal != null &&
                          document.montoTotal! > 0) ...[
                        const Icon(Icons.account_balance_wallet,
                            size: 16, color: Colors.green),
                        const SizedBox(width: 4),
                        Text(
                          '${document.montoTotal!.toStringAsFixed(0)} XAF',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      if (document.empresasInvolucradas?.isNotEmpty ==
                          true) ...[
                        const Icon(Icons.business,
                            size: 16, color: Colors.blue),
                        const SizedBox(width: 4),
                        Text(
                          document.empresasInvolucradas!.first,
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 14, color: Colors.white60),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(document.uploadedAt),
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      if (provider.canDeleteDocument(document))
                        IconButton(
                          onPressed: () => _confirmDelete(document),
                          icon: const Icon(Icons.delete,
                              size: 20, color: Colors.red),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(DocumentPriority priority) {
    Color color;
    IconData icon;

    switch (priority) {
      case DocumentPriority.critico:
        color = Colors.red;
        icon = Icons.priority_high;
        break;
      case DocumentPriority.alto:
        color = Colors.orange;
        icon = Icons.trending_up;
        break;
      case DocumentPriority.medio:
        color = Colors.blue;
        icon = Icons.remove;
        break;
      case DocumentPriority.bajo:
        color = Colors.green;
        icon = Icons.trending_down;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 2),
          Text(
            priority.name.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Consumer<DigitalDocumentProvider>(
      builder: (context, provider, child) {
        if (!provider.canUploadDocuments) return const SizedBox.shrink();

        return FloatingActionButton.extended(
          onPressed: _showUploadDialog,
          backgroundColor: Colors.blue,
          icon: const Icon(Icons.upload_file, color: Colors.white),
          label: const Text(
            'Subir Documento',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        );
      },
    );
  }

  Widget _buildVoiceCommandsOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.purple.withOpacity(0.9),
                Colors.blue.withOpacity(0.9),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.mic, color: Colors.white, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Comandos Disponibles',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              ..._voiceCommands
                  .map((command) => _buildOverlayCommandItem(command)),
              const SizedBox(height: 24),
              ModernButton(
                text: 'Cerrar',
                onPressed: () => setState(() => _showVoiceCommands = false),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverlayCommandItem(Map<String, dynamic> command) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(command['icon'], color: Colors.white, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '"${command['command']}"',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  command['description'],
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDragOverlay() {
    return Positioned(
      left: _dragOffset.dx,
      top: _dragOffset.dy,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.drag_handle,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }

  Widget _buildProcessingOverlay() {
    return Positioned(
      left: 0,
      top: 0,
      right: 0,
      bottom: 0,
      child: Container(
        color: Colors.black.withOpacity(0.8),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.purple.withOpacity(0.9),
                  Colors.blue.withOpacity(0.9),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_upload, color: Colors.white, size: 60),
                const SizedBox(height: 16),
                const Text(
                  'Escaneando Documento...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _processingStatus,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                const CircularProgressIndicator(color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _toggleVoiceSearch() {
    setState(() {
      _isListening = !_isListening;
      if (_isListening) {
        _voiceController.forward();
        _simulateVoiceCommand();
      } else {
        _voiceController.reverse();
        _currentCommand = '';
      }
    });
  }

  void _simulateVoiceCommand() {
    // Simular comando de voz
    Future.delayed(const Duration(seconds: 2), () {
      if (_isListening) {
        setState(() {
          _currentCommand = 'mostrar críticos';
          _isListening = false;
        });
        _executeVoiceCommand('filter_critical');
      }
    });
  }

  void _executeVoiceCommand(String action) {
    switch (action) {
      case 'filter_critical':
        context
            .read<DigitalDocumentProvider>()
            .updateFilters(priority: DocumentPriority.critico);
        break;
      case 'filter_expenses':
        context
            .read<DigitalDocumentProvider>()
            .updateFilters(type: DocumentType.gastosMensuales);
        break;
      case 'filter_contracts':
        context
            .read<DigitalDocumentProvider>()
            .updateFilters(type: DocumentType.contrato);
        break;
      case 'upload_document':
        _showUploadDialog();
        break;
      case 'full_analysis':
        _showFullAnalysis();
        break;
    }
  }

  void _executeQuickAction(String action) {
    switch (action) {
      case 'scan':
        _startDocumentScan();
        break;
      case 'voice':
        setState(() => _showVoiceCommands = true);
        break;
      case 'ai':
        setState(() => _showAIInsights = true);
        break;
      case 'analytics':
        _showFullAnalysis();
        break;
    }
  }

  void _startDocumentScan() async {
    print('🔍 Iniciando escaneo de documento...');
    setState(() {
      _isProcessingDocument = true;
      _processingStatus = 'Abriendo cámara...';
    });

    try {
      // Simular tiempo de escaneo real
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _processingStatus = 'Capturando imagen...';
      });
      await Future.delayed(const Duration(milliseconds: 800));
      setState(() {
        _processingStatus = 'Procesando documento...';
      });
      await Future.delayed(const Duration(milliseconds: 1200));

      print('📸 Procesando documento con DigitalDocumentProvider...');
      // Procesar el documento real
      await context.read<DigitalDocumentProvider>().uploadDocumentFromCamera();

      setState(() {
        _isProcessingDocument = false;
        _processingStatus = '';
      });

      print('✅ Documento procesado, obteniendo lista de documentos...');
      // Obtener el documento recién creado y mostrar información REAL
      final documents =
          context.read<DigitalDocumentProvider>().filteredDocuments;
      print('📄 Documentos encontrados: ${documents.length}');

      if (documents.isNotEmpty) {
        final lastDocument = documents.first;
        print('🎯 Mostrando diálogo para documento: ${lastDocument.title}');

        // Mostrar diálogo con información REAL del documento
        _showRealDocumentDialog(lastDocument);
      } else {
        print('❌ No se encontraron documentos después del escaneo');
        _showErrorDialog('No se pudo procesar el documento');
      }
    } catch (e) {
      print('💥 Error durante el escaneo: $e');
      setState(() {
        _isProcessingDocument = false;
        _processingStatus = '';
      });

      _showErrorDialog('Error al escanear: $e');
    }
  }

  void _showRealDocumentDialog(DigitalDocument document) {
    print(
        '🎯 _showRealDocumentDialog llamado con documento: ${document.title}');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 24),
            SizedBox(width: 8),
            Text(
              '¡Documento Escaneado!',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'El documento ha sido procesado exitosamente:',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Título', document.title),
            _buildDetailRow('Tipo', document.documentType.displayName),
            _buildDetailRow(
                'Monto',
                document.montoTotal != null
                    ? '${document.montoTotal!.toStringAsFixed(0)} XAF'
                    : 'No aplica'),
            _buildDetailRow(
                'Empresa',
                document.empresasInvolucradas?.isNotEmpty == true
                    ? document.empresasInvolucradas!.first
                    : 'No aplica'),
            _buildDetailRow('Prioridad', document.priority.displayName),
            _buildDetailRow('Fecha', _formatDate(document.uploadedAt)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info, color: Colors.green, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'El documento está ahora disponible en el sistema. Toca "Ver Documento" para abrir el PDF.',
                      style: TextStyle(color: Colors.green, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Abrir el PDF del documento
              final authProvider = context.read<AuthProvider>();
              final isDirector = authProvider.role == 'Director General';

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PDFViewerScreen(
                    document: document,
                    isDirector: isDirector,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Ver Documento'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red, size: 24),
            SizedBox(width: 8),
            Text(
              'Error',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showScanSuccessDialog() {
    final documents = context.read<DigitalDocumentProvider>().filteredDocuments;
    if (documents.isEmpty) return;

    final lastDocument = documents.first;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 24),
            SizedBox(width: 8),
            Text(
              '¡Documento Escaneado!',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'El documento ha sido procesado exitosamente:',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Título', lastDocument.title),
            _buildDetailRow('Tipo', lastDocument.documentType.displayName),
            _buildDetailRow(
                'Monto',
                lastDocument.montoTotal != null
                    ? '${lastDocument.montoTotal!.toStringAsFixed(0)} XAF'
                    : 'No aplica'),
            _buildDetailRow(
                'Empresa',
                lastDocument.empresasInvolucradas?.isNotEmpty == true
                    ? lastDocument.empresasInvolucradas!.first
                    : 'No aplica'),
            _buildDetailRow('Prioridad', lastDocument.priority.displayName),
            _buildDetailRow('Fecha', _formatDate(lastDocument.uploadedAt)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info, color: Colors.green, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'El documento está ahora disponible en el sistema. Toca "Ver Resultados" para ver los detalles completos.',
                      style: TextStyle(color: Colors.green, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Mostrar los resultados en el panel de IA
              setState(() {
                _showAIInsights = true;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Ver Resultados'),
          ),
        ],
      ),
    );
  }

  void _showProcessedDocument(Map<String, dynamic> doc) {
    // Obtener el documento real del provider
    final documents = context.read<DigitalDocumentProvider>().filteredDocuments;
    final realDocument = documents.firstWhere(
      (document) => document.title == doc['title'],
      orElse: () => documents.first,
    );

    final authProvider = context.read<AuthProvider>();
    final isDirector = authProvider.role == 'Director General';

    // Abrir el visor PDF directamente
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFViewerScreen(
          document: realDocument,
          isDirector: isDirector,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _startDrag(DigitalDocument document) {
    setState(() {
      _isDragging = true;
      _dragOffset = const Offset(100, 100);
    });
  }

  void _showCriticalDocument() {
    _showAnalysisDialog(
        'Documento Crítico', 'Presupuesto 2026 requiere aprobación inmediata');
  }

  void _showExpenseAnalysis() {
    _showAnalysisDialog(
        'Análisis de Gastos', 'Gastos mensuales 15% sobre presupuesto');
  }

  void _showContractAnalysis() {
    _showAnalysisDialog(
        'Análisis de Contratos', '3 contratos próximos a vencer');
  }

  void _showFullAnalysis() {
    _showAnalysisDialog(
        'Análisis Completo', 'Análisis completo del sistema ejecutado');
  }

  void _showAnalysisDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showUploadDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A2E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade600,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Subir Documento',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ModernButton(
                      text: 'Cámara',
                      icon: Icons.camera_alt,
                      onPressed: () {
                        Navigator.pop(context);
                        context
                            .read<DigitalDocumentProvider>()
                            .uploadDocumentFromCamera();
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ModernButton(
                      text: 'Galería',
                      icon: Icons.photo_library,
                      onPressed: () {
                        Navigator.pop(context);
                        context
                            .read<DigitalDocumentProvider>()
                            .uploadDocumentFromGallery();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showDocumentDetails(DigitalDocument document) {
    final authProvider = context.read<AuthProvider>();
    final isDirector = authProvider.role == 'Director General';

    // Si el documento tiene PDF y es Director, abrir visor PDF directamente
    if (document.hasPDF && isDirector) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFViewerScreen(
            document: document,
            isDirector: isDirector,
          ),
        ),
      );
      return;
    }

    // Si no es Director o no tiene PDF, mostrar detalles
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Row(
          children: [
            Icon(
              _getDocumentIcon(document.documentType),
              color: _getDocumentColor(document.documentType),
              size: 24,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                document.title,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              document.description,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Tipo', document.documentType.displayName),
            _buildDetailRow('Estado', document.status.displayName),
            _buildDetailRow('Prioridad', document.priority.displayName),
            _buildDetailRow('Subido por', document.uploadedBy),
            _buildDetailRow('Fecha', _formatDate(document.uploadedAt)),
            if (document.montoTotal != null)
              _buildDetailRow(
                  'Monto', '${document.montoTotal!.toStringAsFixed(0)} XAF'),
            if (document.empresasInvolucradas?.isNotEmpty == true)
              _buildDetailRow('Empresa', document.empresasInvolucradas!.first),
            const SizedBox(height: 12),
            if (document.hasPDF && !isDirector) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Solo el Director puede ver este documento PDF',
                        style: TextStyle(color: Colors.orange, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (document.hasPDF && isDirector) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.picture_as_pdf, color: Colors.green, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Documento PDF disponible - Toca para abrir',
                        style: TextStyle(color: Colors.green, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          if (document.hasPDF && isDirector)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PDFViewerScreen(
                      document: document,
                      isDirector: isDirector,
                    ),
                  ),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.blue),
              child: const Text('Ver PDF'),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getDocumentIcon(DocumentType type) {
    switch (type) {
      case DocumentType.presupuesto:
        return Icons.account_balance_wallet;
      case DocumentType.contrato:
        return Icons.description;
      case DocumentType.gastosMensuales:
        return Icons.receipt;
      default:
        return Icons.picture_as_pdf;
    }
  }

  Color _getDocumentColor(DocumentType type) {
    switch (type) {
      case DocumentType.presupuesto:
        return Colors.orange;
      case DocumentType.contrato:
        return Colors.blue;
      case DocumentType.gastosMensuales:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _confirmDelete(DigitalDocument document) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Eliminar Documento',
            style: TextStyle(color: Colors.white)),
        content: Text(
          '¿Estás seguro de que quieres eliminar "${document.title}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context
                  .read<DigitalDocumentProvider>()
                  .deleteDocument(document.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Color _getDocumentTypeColor(DocumentType type) {
    switch (type) {
      case DocumentType.gastosMensuales:
        return Colors.red;
      case DocumentType.presupuesto:
        return Colors.purple;
      case DocumentType.contrato:
        return Colors.blue;
      case DocumentType.personal:
        return Colors.green;
      case DocumentType.indemnizacion:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
