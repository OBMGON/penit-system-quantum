import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'dart:typed_data';
import '../services/pdf_service.dart';
import '../models/digital_document.dart';

class PDFViewerScreen extends StatefulWidget {
  final DigitalDocument document;
  final bool isDirector;

  const PDFViewerScreen({
    Key? key,
    required this.document,
    required this.isDirector,
  }) : super(key: key);

  @override
  State<PDFViewerScreen> createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  Uint8List? _pdfBytes;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPDF();
  }

  Future<void> _loadPDF() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Intentar cargar PDF desde assets basado en el tipo de documento
      String? documentId;
      switch (widget.document.documentType) {
        case DocumentType.presupuesto:
          documentId = 'presupuesto_2026';
          break;
        case DocumentType.contrato:
          documentId = 'contrato_suministros';
          break;
        case DocumentType.gastosMensuales:
          documentId = 'gastos_julio_2025';
          break;
        default:
          documentId = 'gastos_julio_2025'; // Default
      }

      final pdfBytes = await PDFService.getPDFFromAssets(documentId);

      if (pdfBytes != null) {
        setState(() {
          _pdfBytes = pdfBytes;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'No se pudo cargar el documento PDF';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error al cargar el documento: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text(
          widget.document.title,
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (widget.isDirector) ...[
            IconButton(
              icon: const Icon(Icons.download, color: Colors.white),
              onPressed: _downloadPDF,
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: _editDocument,
            ),
          ],
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.blue),
            SizedBox(height: 16),
            Text(
              'Cargando documento...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPDF,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_pdfBytes == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.picture_as_pdf, color: Colors.grey, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Documento no disponible',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Tipo: ${widget.document.documentType.displayName}',
              style: const TextStyle(color: Colors.grey),
            ),
            if (!widget.isDirector) ...[
              const SizedBox(height: 16),
              const Text(
                'Solo el Director puede ver este documento',
                style: TextStyle(color: Colors.orange),
              ),
            ],
          ],
        ),
      );
    }

    return Column(
      children: [
        // Información del documento
        Container(
          padding: const EdgeInsets.all(16),
          color: const Color(0xFF1A1A2E),
          child: Row(
            children: [
              Icon(
                _getDocumentIcon(),
                color: _getDocumentColor(),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.document.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${widget.document.documentType.displayName} • ${widget.document.priority.displayName}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.document.status.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Visor PDF
        Expanded(
          child: SfPdfViewer.memory(
            _pdfBytes!,
            enableDocumentLinkAnnotation: true,
            enableTextSelection: true,
            canShowScrollHead: true,
            canShowScrollStatus: true,
            canShowPaginationDialog: true,
          ),
        ),
      ],
    );
  }

  IconData _getDocumentIcon() {
    switch (widget.document.documentType) {
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

  Color _getDocumentColor() {
    switch (widget.document.documentType) {
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

  Color _getStatusColor() {
    switch (widget.document.status) {
      case DocumentStatus.pendiente:
        return Colors.orange;
      case DocumentStatus.aprobado:
        return Colors.green;
      case DocumentStatus.rechazado:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _downloadPDF() {
    // Implementar descarga de PDF
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Descarga iniciada...'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _editDocument() {
    // Implementar edición de documento
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Modo de edición activado'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
