import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ml_based_personal_finance_optimizer/frontend/user_module/views/transitionPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/transaction_controllers/transaction_controller.dart';
import '../models/transaction_model.dart';
import 'package:intl/intl.dart';

import 'settings_view/user_profile_view.dart';

class HomePage extends StatefulWidget {

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TransactionController controller = Get.put(TransactionController());
  String? currentUserId;


  @override
  void initState() {
    super.initState();
    _loadUserIdAndFetch();
    // Don't call fetchTransactions here because currentUserId is still null
    // controller.fetchTransactions(currentUserId!); // This line causes the error
  }

  Future<void> _loadUserIdAndFetch() async {
    print("HomePage: Loading userId from SharedPreferences");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currentUserId = prefs.getString("userId");

    print("HomePage: Loaded userId: $currentUserId");

    setState(() {});  // Update UI with userId

    if (currentUserId != null && currentUserId!.isNotEmpty) {
      print("HomePage: Fetching transactions for userId: $currentUserId");
      controller.fetchTransactions(currentUserId!);
    } else {
      print("HomePage: WARNING - User ID not found in shared preferences.");

      // If userId is not available, try to load it again after a short delay
      // This handles race conditions with authentication
      await Future.delayed(Duration(milliseconds: 800), () async {
        prefs = await SharedPreferences.getInstance();
        currentUserId = prefs.getString("userId");

        print("HomePage: Retry loading userId: $currentUserId");

        setState(() {});  // Update UI with userId

        if (currentUserId != null && currentUserId!.isNotEmpty) {
          print("HomePage: Now fetching transactions after retry for userId: $currentUserId");
          controller.fetchTransactions(currentUserId!);
        } else {
          print("HomePage: CRITICAL - Still no userId after retry");
          Get.snackbar(
            'Warning',
            'Could not identify your account. Some features may not work correctly.',
            backgroundColor: Colors.orange.withOpacity(0.7),
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 5),
          );
        }
      });
    }
  }


  Future<String?> getUserId() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("userId");
  }

  // Show filter dialog
  void _showFilterDialog() {
    Get.dialog(
      StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.filter_list, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text('Filter Transactions'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Filter
                const Text(
                  'Date Range',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                ...controller.dateFilterOptions
                    .map((option) => RadioListTile<String>(
                          title: Text(option['label']!),
                          value: option['value']!,
                          groupValue: controller.selectedDateFilter.value,
                          onChanged: (value) {
                            setDialogState(() {
                              controller.selectedDateFilter.value = value ?? '';
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                        )),

                const SizedBox(height: 16),

                // Type Filter
                const Text(
                  'Transaction Type',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                ...controller.typeFilterOptions
                    .map((option) => RadioListTile<String>(
                          title: Text(option['label']!),
                          value: option['value']!,
                          groupValue: controller.selectedTypeFilter.value,
                          onChanged: (value) {
                            setDialogState(() {
                              controller.selectedTypeFilter.value = value ?? '';
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                        )),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back();
                  controller.clearFilters();
                },
                child: const Text('Clear All'),
              ),
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  controller.applyFilters();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Apply Filters'),
              ),
            ],
          );
        },
      ),
    );
  }

  // Build filter summary widget
  Widget _buildFilterSummary(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.blue.withOpacity(0.1)
            : Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.filter_list,
            color: Colors.blue,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filters Applied',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Obx(() => Text(
                      controller.getFilterDescription(),
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                        fontSize: 12,
                      ),
                    )),
              ],
            ),
          ),
          TextButton(
            onPressed: controller.clearFilters,
            child: Text(
              'Clear',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, List<TransactionModel>> _groupTransactionsByDate(
      List<TransactionModel> txs) {
    final Map<String, List<TransactionModel>> grouped = {};
    for (var tx in txs) {
      final dateKey = DateFormat('yyyy-MM-dd').format(tx.transactionDate);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(tx);
    }
    return grouped;
  }

  String _getDateLabel(String dateKey) {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final yesterday = DateFormat('yyyy-MM-dd')
        .format(DateTime.now().subtract(const Duration(days: 1)));
    if (dateKey == today) return 'Today';
    if (dateKey == yesterday) return 'Yesterday';
    return DateFormat('MMM dd, yyyy').format(DateTime.parse(dateKey));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
      isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8FAFC),
      appBar: _buildModernAppBar(context),
      body: Obx(() {
        final txs = controller.transactions;
        final totalSpend =
        txs.where((e) => e.isExpense).fold(0.0, (sum, e) => sum + e.amount);
        final totalIncome = txs
            .where((e) => !e.isExpense)
            .fold(0.0, (sum, e) => sum + e.amount);
        final balance = totalIncome - totalSpend;

        return Obx(() {
          final txsToShow = controller.displayTransactions;

          if (txsToShow.isEmpty) {
            // When empty, keep the old structure for better UX
            return Column(
              children: [
                _buildBalanceCard(context, totalSpend, totalIncome, balance),
                controller.hasActiveFilters
                    ? _buildFilterSummary(context)
                    : const SizedBox.shrink(),
                _buildQuickActions(context),
                Expanded(
                  child: _buildEmptyState(context, controller.hasActiveFilters),
                ),
              ],
            );
          }

          final grouped = _groupTransactionsByDate(txsToShow);
          final sortedKeys = grouped.keys.toList()
            ..sort((a, b) => b.compareTo(a));

          // Create a custom scroll view that includes everything
          return CustomScrollView(
            slivers: [
              // Balance card as a sliver
              SliverToBoxAdapter(
                child: _buildBalanceCard(context, totalSpend, totalIncome, balance),
              ),

              // Filter summary as a sliver
              SliverToBoxAdapter(
                child: controller.hasActiveFilters
                    ? _buildFilterSummary(context)
                    : const SizedBox.shrink(),
              ),

              // Quick actions as a sliver
              SliverToBoxAdapter(
                child: _buildQuickActions(context),
              ),

              // Add some spacing
              const SliverToBoxAdapter(
                child: SizedBox(height: 8),
              ),

              // Transaction list as a sliver list
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final dateKey = sortedKeys[index];
                    final txList = grouped[dateKey]!;
                    final dailyIncome = txList
                        .where((tx) => !tx.isExpense)
                        .fold(0.0, (sum, tx) => sum + tx.amount);
                    final dailyExpenses = txList
                        .where((tx) => tx.isExpense)
                        .fold(0.0, (sum, tx) => sum + tx.amount);

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withOpacity(0.03)
                            : Colors.grey.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white.withOpacity(0.08)
                              : Colors.grey.withOpacity(0.15),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDateHeader(
                              context, dateKey, dailyIncome, dailyExpenses,
                              containerized: true),
                          const SizedBox(height: 8),
                          ...txList.map((tx) => _ModernTransactionCard(
                            tx: tx,
                            onDelete: () => _showDeleteDialog(context, tx),
                          )),
                        ],
                      ),
                    );
                  },
                  childCount: sortedKeys.length,
                ),
              ),

              // Bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 100), // Extra space for FAB and bottom nav
              ),
            ],
          );
        });
      }),
      floatingActionButton: _buildModernFAB(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildModernBottomNav(context),
    );
  }

  PreferredSizeWidget _buildModernAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            color: isDark
                ? const Color(0xFF1A1A1A).withOpacity(0.3)
                : Colors.white.withOpacity(0.3),
            child: AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              toolbarHeight: 80,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FinanceTracker',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    DateFormat('MMMM yyyy').format(DateTime.now()),
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              actions: [
                Obx(() => Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 16),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.filter_list,
                              color: isDark ? Colors.white : Colors.black54,
                            ),
                            onPressed: () => _showFilterDialog(),
                          ),
                        ),
                        if (controller.hasActiveFilters)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                '${controller.activeFiltersCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    )),
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.notifications_outlined,
                      color: isDark ? Colors.white : Colors.black54,
                    ),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceItem(BuildContext context, String label, String amount,
      IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18), // Slightly bigger icon
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: isDark
                        ? Colors.white.withOpacity(0.8)
                        : Colors.black.withOpacity(0.6),
                    fontSize: 13, // Slightly bigger label font
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  amount,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 18, // Bigger amount font (was 16)
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // New compact balance card
  Widget _buildBalanceCard(BuildContext context, double totalSpend,
      double totalIncome, double balance) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            // Changed background color - more subtle and modern
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      const Color(0xFF2D3748),
                      const Color(0xFF4A5568),
                    ]
                  : [
                      const Color(0xFFEDF2F7),
                      const Color(0xFFE2E8F0),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            // Added semi-transparent border
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.15)
                  : Colors.black.withOpacity(0.08),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'Total Balance',
                style: TextStyle(
                  color: isDark
                      ? Colors.white.withOpacity(0.9)
                      : Colors.black.withOpacity(0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '₹${balance.toStringAsFixed(0)}',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildBalanceItem(
                      context,
                      'Income',
                      '₹${totalIncome.toStringAsFixed(0)}',
                      Icons.trending_up,
                      Colors.green,
                      isDark,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: isDark
                        ? Colors.white.withOpacity(0.3)
                        : Colors.black.withOpacity(0.2),
                  ),
                  Expanded(
                    child: _buildBalanceItem(
                      context,
                      'Expenses',
                      '₹${totalSpend.toStringAsFixed(0)}',
                      Icons.trending_down,
                      Colors.red,
                      isDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: Center(
            child: Container(
              height: 70,
              width: 70,
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    Theme.of(context).colorScheme.onBackground.withOpacity(0.9),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(8),
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(12),
                ),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.15)
                      : Colors.black.withOpacity(0.08),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.currency_rupee_rounded,
                color: Theme.of(context).colorScheme.onPrimary,
                size: 25,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactBalanceItem(BuildContext context, String label,
      String amount, IconData icon, Color color) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 14),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  amount,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              context,
              'Add Income',
              Icons.add,
              Colors.green,
              () => _navigateToAddTransaction(context, false),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              context,
              'Add Expense',
              Icons.remove,
              Colors.red,
              () => _navigateToAddTransaction(context, true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon,
      Color color, VoidCallback onTap) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  isDark ? Colors.transparent : Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: color, size: 14),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, [bool isFiltered = false]) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isFiltered ? Icons.filter_list_off : Icons.receipt_long_outlined,
            size: 64,
            color: isDark ? Colors.white30 : Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            isFiltered ? 'No matching transactions' : 'No transactions yet',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isFiltered
                ? 'Try adjusting your filters or clear them to see all transactions'
                : 'Add your first transaction to get started',
            style: TextStyle(
              color: isDark ? Colors.white38 : Colors.black38,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          if (isFiltered) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: controller.clearFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Clear Filters'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTransactionsList(BuildContext context,
      Map<String, List<TransactionModel>> grouped, List<String> sortedKeys) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedKeys.length,
      itemBuilder: (context, idx) {
        final dateKey = sortedKeys[idx];
        final txList = grouped[dateKey]!;
        final dailyIncome = txList
            .where((tx) => !tx.isExpense)
            .fold(0.0, (sum, tx) => sum + tx.amount);
        final dailyExpenses = txList
            .where((tx) => tx.isExpense)
            .fold(0.0, (sum, tx) => sum + tx.amount);

        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withOpacity(0.03)
                : Colors.grey.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.grey.withOpacity(0.15),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateHeader(context, dateKey, dailyIncome, dailyExpenses,
                  containerized: true),
              const SizedBox(height: 8),
              ...txList.map((tx) => _ModernTransactionCard(
                    tx: tx,
                    onDelete: () => _showDeleteDialog(context, tx),
                  )),
            ],
          ),
        );
      },
    );
  }

  // Update _buildDateHeader to optionally remove its own container styling
  Widget _buildDateHeader(
      BuildContext context, String dateKey, double income, double expenses,
      {bool containerized = false}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (containerized) {
      // Just return the row, no container
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _getDateLabel(dateKey),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          Row(
            children: [
              if (income > 0) ...[
                Text(
                  '+₹${income.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              if (expenses > 0)
                Text(
                  '-₹${expenses.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ],
      );
    }

    // Original container style for non-containerized usage
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _getDateLabel(dateKey),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          Row(
            children: [
              if (income > 0) ...[
                Text(
                  '+₹${income.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              if (expenses > 0)
                Text(
                  '-₹${expenses.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, TransactionModel tx) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Delete Transaction'),
          content: Text(
              'Are you sure you want to delete this ${tx.isExpense ? 'expense' : 'income'} of ₹${tx.amount.toStringAsFixed(2)}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                controller.deleteTransaction(tx.transactionId!);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildModernFAB(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667eea).withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _navigateToAddTransaction(context, true),
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }

  Widget _buildModernBottomNav(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          height: 90, // Increased height to prevent overflow
          decoration: BoxDecoration(
            color: isDark
                ? theme.colorScheme.surface.withOpacity(0.7)
                : Colors.white.withOpacity(0.8),
            border: Border(
              top: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.3),
                width: 0.5,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.3)
                    : Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: BottomAppBar(
            elevation: 0,
            color: Colors.transparent,
            shape: const CircularNotchedRectangle(),
            notchMargin: 12,
            height: 90, // Match container height
            padding: EdgeInsets.zero, // Remove default padding
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _ModernBottomNavItem(
                    icon: Icons.dashboard_outlined,
                    activeIcon: Icons.dashboard_rounded,
                    label: 'Dashboard',
                    isActive: true,
                    theme: theme,
                    onTap: () {},
                  ),
                  _ModernBottomNavItem(
                    icon: Icons.analytics_outlined,
                    activeIcon: Icons.analytics_rounded,
                    label: 'Analytics',
                    isActive: false,
                    theme: theme,
                    onTap: () {},
                  ),
                  const SizedBox(width: 48), // Space for FAB
                  _ModernBottomNavItem(
                    icon: Icons.account_balance_wallet_outlined,
                    activeIcon: Icons.account_balance_wallet_rounded,
                    label: 'Accounts',
                    isActive: false,
                    theme: theme,
                    onTap: () {},
                  ),
                  _ModernBottomNavItem(
                    icon: Icons.settings_outlined,
                    activeIcon: Icons.settings_rounded,
                    label: 'Settings',
                    isActive: false,
                    theme: theme,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToAddTransaction(BuildContext context, bool isExpense) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransactionPage(
          currentUserId: currentUserId!,
          controller: controller,
          initialIsExpense: isExpense,
        ),
      ),
    );
  }
}

// Keep the existing _ModernTransactionCard and _ModernBottomNavItem classes as they are
class _ModernTransactionCard extends StatelessWidget {
  final TransactionModel tx;
  final VoidCallback onDelete;

  const _ModernTransactionCard({
    required this.tx,
    required this.onDelete,
  });

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_car;
      case 'shopping':
        return Icons.shopping_bag;
      case 'entertainment':
        return Icons.movie;
      case 'health':
        return Icons.local_hospital;
      case 'education':
        return Icons.school;
      case 'salary':
        return Icons.account_balance_wallet;
      case 'gift':
        return Icons.card_giftcard;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isDark
                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                : Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getCategoryIcon(tx.category),
            color: tx.isExpense
                ? Colors.red.withOpacity(0.7)
                : Colors.green.withOpacity(0.1),
            size: 24,
          ),
        ),
        title: Text(
          tx.category,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Text(
          tx.description ?? 'No description',
          style: TextStyle(
            color: isDark ? Colors.white60 : Colors.black54,
            fontSize: 14,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${tx.isExpense ? '-' : '+'}₹${tx.amount.toStringAsFixed(2)}',
              style: TextStyle(
                color: tx.isExpense ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('hh:mm a').format(tx.transactionDate),
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ),
          ],
        ),
        onLongPress: onDelete,
      ),
    );
  }
}

class _ModernBottomNavItem extends StatelessWidget {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final bool isActive;
  final ThemeData theme;
  final VoidCallback onTap;

  const _ModernBottomNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    required this.isActive,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Using your app theme colors
    final activeColor = theme.colorScheme.primary;
    final inactiveColor = theme.colorScheme.onSurface.withOpacity(0.6);
    final backgroundColor = isActive
        ? theme.colorScheme.primaryContainer.withOpacity(0.3)
        : Colors.transparent;
    final borderColor = isActive
        ? theme.colorScheme.primary.withOpacity(0.4)
        : Colors.transparent;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          margin: const EdgeInsets.symmetric(
              horizontal: 2), // Small margin to prevent overflow
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isActive ? (activeIcon ?? icon) : icon,
                color: isActive ? activeColor : inactiveColor,
                size: 22, // Slightly smaller to prevent overflow
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10, // Smaller font size to prevent overflow
                  color: isActive ? activeColor : inactiveColor,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis, // Prevent text overflow
              ),
            ],
          ),
        ),
      ),
    );
  }
}
