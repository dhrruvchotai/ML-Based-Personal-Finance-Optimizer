import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../controllers/analysis_controller.dart';

class AnalysisPage extends StatelessWidget {
  final AnalysisController controller = Get.put(AnalysisController());

  AnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Financial Analysis',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        actions: [
          // PDF Download Button
          Obx(() => controller.isGeneratingPdf.value
            ? Container(
                margin: const EdgeInsets.only(right: 16),
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                ),
              )
            : IconButton(
                icon: Icon(
                  Icons.download_rounded,
                  color: theme.colorScheme.primary,
                ),
                tooltip: 'Download PDF Report',
                onPressed: controller.generatePdfReport,
              )
          ),
        ],
      ),
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8FAFC),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
                const SizedBox(height: 16),
                Text(
                  'Error',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  controller.errorMessage.value,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.loadUserIdAndFetchTransactions(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Download Report Button
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                child: ElevatedButton.icon(
                  onPressed: controller.isGeneratingPdf.value 
                    ? null 
                    : controller.generatePdfReport,
                  icon: controller.isGeneratingPdf.value
                    ? Container(
                        width: 20,
                        height: 20,
                        margin: const EdgeInsets.only(right: 8),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.download_rounded),
                  label: Text(
                    controller.isGeneratingPdf.value
                      ? 'Generating PDF...'
                      : 'Download Financial Report',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              _buildSummaryCards(context),
              const SizedBox(height: 32),
              _buildPieChartsSection(context),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSummaryCards(BuildContext context) {
    final cards = [
      _buildSummaryCard(
        context,
        'Total Income',
        controller.totalIncome,
        Theme.of(context).colorScheme.primaryContainer,
        Icons.trending_up,
        Theme.of(context).colorScheme.onPrimaryContainer,
      ),
      _buildSummaryCard(
        context,
        'Total Expenses',
        controller.totalExpenses,
        Theme.of(context).colorScheme.errorContainer,
        Icons.trending_down,
        Theme.of(context).colorScheme.onErrorContainer,
      ),
      _buildSummaryCard(
        context,
        'Net Amount',
        controller.netAmount,
        controller.netAmount >= 0
            ? Theme.of(context).colorScheme.secondaryContainer
            : Theme.of(context).colorScheme.tertiaryContainer,
        controller.netAmount >= 0 ? Icons.account_balance : Icons.warning,
        controller.netAmount >= 0
            ? Theme.of(context).colorScheme.onSecondaryContainer
            : Theme.of(context).colorScheme.onTertiaryContainer,
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        cards[0],
        const SizedBox(height: 12),
        cards[1],
        const SizedBox(height: 12),
        cards[2],
      ],
    );
  }

  Widget _buildSummaryCard(
      BuildContext context,
      String title,
      double amount,
      Color color,
      IconData icon,
      Color iconTextColor,
      ) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconTextColor.withOpacity(0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconTextColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: iconTextColor.withOpacity(0.88),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '\$${amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: iconTextColor,
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

  Widget _buildPieChartsSection(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Category Breakdown',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        // Wrap expense chart with RepaintBoundary for PDF generation
        RepaintBoundary(
          key: controller.expenseChartKey,
          child: _buildPieChart(
            context,
            controller.getExpenseData(),
            'Expenses',
          ),
        ),
        const SizedBox(height: 32),
        // Wrap income chart with RepaintBoundary for PDF generation
        RepaintBoundary(
          key: controller.incomeChartKey,
          child: _buildPieChart(
            context,
            controller.getIncomeData(),
            'Income',
          ),
        ),
      ],
    );
  }

  Widget _buildPieChart(
      BuildContext context,
      Map<String, double> data,
      String title,
      ) {
    final theme = Theme.of(context);
    if (data.isEmpty) {
      return _buildEmptyChart(context, title);
    }

    final List<Color> colors = [
      Color(0xFFA8D5BA), // Pastel mint green (replaces theme.colorScheme.primary)
      Color(0xFFFFCBCB), // Pastel pink/peach (secondary)
      Color(0xFFFFF6B7), // Pale yellow (tertiary)
      Color(0xFFFFB6B9), // Soft red/coral (error)
      Color(0xFFD6E5FA), // Pastel sky blue (primaryContainer)
      Color(0xFFFFECD2), // Creamy orange (secondaryContainer)
      Color(0xFFC4C1E0), // Lavender pastel (surfaceVariant)
      Color(0xFFB2DFDB), // Pastel teal
      Color(0xFFFFE082), // Pastel yellow/amber
      Color(0xFFD1C4E9), // Pastel purple
      Color(0xFFFFB5E8), // Light pastel pink
    ];

    final entries = data.entries.toList();
    final total = data.values.fold(0.0, (sum, value) => sum + value);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: theme.colorScheme.surface,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: PieChart(
                PieChartData(
                  sections: entries.asMap().entries.map((entry) {
                    final index = entry.key;
                    final category = entry.value.key;
                    final amount = entry.value.value;
                    final percentage = (amount / total) * 100;
                    return PieChartSectionData(
                      color: colors[index % colors.length],
                      value: amount,
                      title: '${percentage.toStringAsFixed(1)}%',
                      radius: 75,
                      titleStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                  centerSpaceRadius: 35,
                  sectionsSpace: 2.5,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: entries.asMap().entries.map((entry) {
                final index = entry.key;
                final category = entry.value.key;
                final amount = entry.value.value;
                final percentage = (amount / total) * 100;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: colors[index % colors.length],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          category,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '\$${amount.toStringAsFixed(2)}  (${percentage.toStringAsFixed(1)}%)',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyChart(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Container(
      height: 180,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.18)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pie_chart_outline, size: 54, color: theme.hintColor.withOpacity(0.28)),
          const SizedBox(height: 14),
          Text(
            'No Data Available',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.hintColor.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'No $title data found for the selected time period.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.hintColor.withOpacity(0.57),
            ),
          ),
        ],
      ),
    );
  }
}
