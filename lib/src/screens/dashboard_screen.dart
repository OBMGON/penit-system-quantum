import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/prisoner_provider.dart';
import '../providers/hospitalization_provider.dart';
import '../providers/alert_provider.dart';
import '../widgets/modern_card.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prisonerProvider = Provider.of<PrisonerProvider>(context);
    final hospProvider = Provider.of<HospitalizationProvider>(context);
    final alertProvider = Provider.of<AlertProvider>(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              'Panel de Control Nacional',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: const Color(0xFF17643A),
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications, color: Colors.white),
                onPressed: () {
                  Navigator.pushNamed(context, '/alerts');
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: () {
                  Navigator.pushNamed(context, '/settings');
                },
              ),
            ],
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.grey.shade50, Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeSection(),
                  const SizedBox(height: 24),
                  // Solo una sección de estadísticas nacionales
                  _buildStatisticsGrid(prisonerProvider),
                  const SizedBox(height: 24),
                  // Solo una sección de distribución por ciudades
                  _buildCityInmatesSection(prisonerProvider),
                  const SizedBox(height: 24),
                  // Solo un bloque de análisis de datos
                  _buildChartsSection(prisonerProvider),
                  const SizedBox(height: 24),
                  _buildFoodManagementSection(),
                  const SizedBox(height: 24),
                  _buildQuickActionsSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF17643A).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.security,
                  color: Color(0xFF17643A),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bienvenido, Director General',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Sistema Nacional de Gestión Penitenciaria',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Panel de Control 2025',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsGrid(PrisonerProvider prisonerProvider) {
    final stats = prisonerProvider.getNationalStatistics();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Estadísticas Nacionales',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: constraints.maxWidth > 400 ? 4 : 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.3,
              children: [
                _buildStatCard(
                  'Total Reclusos',
                  '${stats['totalInmates'] ?? 0}',
                  Icons.people,
                  const Color(0xFF17643A),
                ),
                _buildStatCard(
                  'Capacidad',
                  '${stats['totalCapacity'] ?? 0}',
                  Icons.business,
                  Colors.blue,
                ),
                _buildStatCard(
                  'Ocupación',
                  '${stats['occupationPercentage'] ?? 0}%',
                  Icons.analytics,
                  Colors.orange,
                ),
                _buildStatCard(
                  'Alertas',
                  '${stats['activeAlerts'] ?? 0}',
                  Icons.warning,
                  Colors.red,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsSection(PrisonerProvider prisonerProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Análisis de Datos',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ModernCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Distribución por Centros',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: _buildPieChartSections(prisonerProvider),
                    centerSpaceRadius: 40,
                    sectionsSpace: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _buildPieChartSections(PrisonerProvider provider) {
    final prisonStats = provider.getStatisticsByPrison();
    final colors = [
      const Color(0xFF17643A),
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];

    return prisonStats.entries.map((entry) {
      final index = prisonStats.keys.toList().indexOf(entry.key);
      return PieChartSectionData(
        color: colors[index % colors.length],
        value: entry.value.toDouble(),
        title: '${entry.value}',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildCityInmatesSection(PrisonerProvider prisonerProvider) {
    final cityCounts = prisonerProvider.getInmatesByFixedCities();
    final sortedCities = cityCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF17643A).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.location_city,
                color: Color(0xFF17643A),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Distribución por Ciudades',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: sortedCities.length,
            itemBuilder: (context, index) {
              final entry = sortedCities[index];
              final isHighest = index == 0;
              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 16),
                child: ModernCard(
                  onTap: () =>
                      _showCityDetails(context, entry.key, entry.value),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isHighest
                            ? [
                                const Color(0xFF17643A).withOpacity(0.1),
                                const Color(0xFF17643A).withOpacity(0.05),
                              ]
                            : [
                                Colors.blue.withOpacity(0.1),
                                Colors.blue.withOpacity(0.05),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_city,
                              color: isHighest
                                  ? const Color(0xFF17643A)
                                  : Colors.blue,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                entry.key,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isHighest
                                      ? const Color(0xFF17643A)
                                      : Colors.blue,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${entry.value}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isHighest
                                ? const Color(0xFF17643A)
                                : Colors.blue,
                          ),
                        ),
                        Text(
                          entry.value == 1 ? 'recluso' : 'reclusos',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Toca para más detalles',
                          style: TextStyle(
                            fontSize: 8,
                            color: Colors.grey.shade500,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showCityDetails(BuildContext context, String city, int inmateCount) {
    final prisonInfo = _getPrisonInfo(city);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(
              Icons.location_city,
              color: Color(0xFF17643A),
            ),
            const SizedBox(width: 8),
            Text('Centro Penitenciario de $city'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Reclusos actuales', '$inmateCount'),
            _buildInfoRow('Capacidad total', '${prisonInfo['capacity']}'),
            _buildInfoRow('Ocupación',
                '${((inmateCount / prisonInfo['capacity']) * 100).toStringAsFixed(1)}%'),
            _buildInfoRow('Director', prisonInfo['director']),
            _buildInfoRow('Teléfono', prisonInfo['phone']),
            _buildInfoRow('Dirección', prisonInfo['address']),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📊 Estadísticas de Comida',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                      'Presupuesto semanal', '\$${prisonInfo['weeklyBudget']}'),
                  _buildInfoRow('Última factura', prisonInfo['lastInvoice']),
                  _buildInfoRow('Estado', prisonInfo['foodStatus']),
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
              Navigator.pushNamed(context, '/food-management');
            },
            child: const Text('Gestionar Comida'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getPrisonInfo(String city) {
    switch (city) {
      case 'Malabo':
        return {
          'capacity': 1200,
          'director': 'Dr. Juan Carlos Obiang',
          'phone': '+240 555 1234',
          'address': 'Black Beach, Malabo',
          'weeklyBudget': '1 500 XAF',
          'lastInvoice': 'Martes 15 Jul 2025',
          'foodStatus': '✅ Al día',
        };
      case 'Bata':
        return {
          'capacity': 198,
          'director': 'Lic. María Elena Rodríguez',
          'phone': '+240 555 5678',
          'address': 'Centro de Bata',
          'weeklyBudget': '2 500 XAF',
          'lastInvoice': 'Martes 15 Jul 2025',
          'foodStatus': '⚠️ Pendiente',
        };
      case 'Mongomo':
        return {
          'capacity': 150,
          'director': 'Sr. Francisco Mangue',
          'phone': '+240 555 9012',
          'address': 'Centro de Mongomo',
          'weeklyBudget': '1 800 XAF',
          'lastInvoice': 'Martes 15 Jul 2025',
          'foodStatus': '✅ Al día',
        };
      default:
        return {
          'capacity': 0,
          'director': 'No especificado',
          'phone': 'No especificado',
          'address': 'No especificado',
          'weeklyBudget': '0 XAF',
          'lastInvoice': 'No especificado',
          'foodStatus': 'No especificado',
        };
    }
  }

  Widget _buildFoodManagementSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF17643A).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.account_balance_wallet,
                color: Color(0xFF17643A),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Control de Gastos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ModernCard(
          onTap: () {
            Navigator.pushNamed(context, '/expense-management');
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF17643A).withOpacity(0.1),
                  const Color(0xFF17643A).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet,
                        color: Color(0xFF17643A),
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Sistema Unificado de Control de Gastos',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF17643A),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Control total de gastos: Comida, Medicamentos y Movimientos Carcelarios. Sube fotos de facturas para procesamiento automático con OCR.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildExpenseTypeChip(
                          'Comida', Icons.restaurant, Colors.green),
                      const SizedBox(width: 8),
                      _buildExpenseTypeChip(
                          'Medicamentos', Icons.medical_services, Colors.blue),
                      const SizedBox(width: 8),
                      _buildExpenseTypeChip(
                          'Movimientos', Icons.directions_bus, Colors.orange),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseTypeChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
                fontSize: 10, color: color, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Acciones Rápidas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: constraints.maxWidth > 400 ? 4 : 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildActionCard(
                  'Registrar Recluso',
                  Icons.person_add,
                  const Color(0xFF17643A),
                  () {
                    Navigator.pushNamed(context, '/register');
                  },
                ),
                _buildActionCard(
                  'Buscar Recluso',
                  Icons.search,
                  Colors.blue,
                  () {
                    Navigator.pushNamed(context, '/search');
                  },
                ),
                _buildActionCard(
                  'Generar Reporte',
                  Icons.assessment,
                  Colors.orange,
                  () {
                    Navigator.pushNamed(context, '/reports');
                  },
                ),
                _buildActionCard(
                  'Configuración',
                  Icons.settings,
                  Colors.grey,
                  () {
                    Navigator.pushNamed(context, '/settings');
                  },
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return ModernCard(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
