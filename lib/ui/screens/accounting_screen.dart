import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/accounting/accounting_cubit.dart';
import '../../bloc/accounting/accounting_state.dart';
import '../../core/bloc_utils/bloc_status.dart';
import '../../core/date_time_util.dart';
import '../../core/extensions/object_extension.dart';
import '../../models/accounting_entry.dart';
import '../widgets/error_message.dart';
import '../widgets/loading.dart';
import '../widgets/no_data.dart';

class AccountingScreen extends StatefulWidget {
  const AccountingScreen({super.key});

  @override
  State<AccountingScreen> createState() => _AccountingScreenState();
}

class _AccountingScreenState extends State<AccountingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<AccountingCubit>().loadAccountingData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("စာရင်းကိုင်နှင့် ဂျာနယ်"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.analytics_outlined),
              text: "ဘဏ္ဍာရေး အနှစ်ချုပ်",
            ),
            Tab(
              icon: Icon(Icons.receipt_long_outlined),
              text: "ဒက်ဘစ်/ခရက်ဒစ် ဂျာနယ်",
            ),
          ],
        ),
      ),
      body: BlocBuilder<AccountingCubit, AccountingState>(
        builder: (context, state) {
          if (state.status == BlocStatus.initial ||
              state.status == BlocStatus.loading) {
            return const Loading();
          }

          if (state.status == BlocStatus.failure) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: ErrorMessage(
                message: state.message ?? "❌ Error loading accounting data",
                onRetry: () {
                  context.read<AccountingCubit>().loadAccountingData();
                },
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: Financial Summary / P&L / Balances
              _buildSummaryTab(context, state.summary),

              // Tab 2: Double-Entry Journal Ledger
              _buildJournalLedgerTab(context, state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryTab(BuildContext context, FinancialSummary? summary) {
    if (summary == null) {
      return const NoData(message: "No Financial Data Available");
    }

    return RefreshIndicator.adaptive(
      onRefresh: () async {
        await context.read<AccountingCubit>().loadAccountingData();
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.04,
          vertical: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trial Balance Health Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: summary.isBalanced
                    ? Colors.green.withAlpha(30)
                    : Colors.red.withAlpha(30),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: summary.isBalanced ? Colors.green : Colors.red,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    summary.isBalanced
                        ? Icons.check_circle_outline
                        : Icons.error_outline,
                    color: summary.isBalanced ? Colors.green : Colors.red,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      summary.isBalanced
                          ? "ဒက်ဘစ်နှင့် ခရက်ဒစ် စာရင်းကိုက်ညီပါသည် (Balanced Double-Entry)"
                          : "ဒက်ဘစ်နှင့် ခရက်ဒစ် စာရင်းမညီပါ (Unbalanced)",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: summary.isBalanced ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // P&L Overview Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: const Text(
                            "အမြတ်နှင့် အရှုံး အနှစ်ချုပ် (Profit & Loss)",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    _statRow(
                      "ရရှိသော အတိုးဝင်ငွေ (Interest Income)",
                      summary.totalInterestIncome.toCurrency,
                      Colors.green,
                    ),
                    _statRow(
                      "ပေးရသော အတိုးစရိတ် (Interest Expense)",
                      summary.totalInterestExpense.toCurrency,
                      Colors.orange,
                    ),
                    _statRow(
                      "ကြွေးဆုံး ဆုံးရှုံးမှု (Bad Debt Loss)",
                      summary.totalBadDebtLoss.toCurrency,
                      Colors.red,
                    ),
                    _statRow(
                      "ကြွေးလျှော်ပေးမှု (Debt Forgiveness)",
                      summary.totalDebtForgiven.toCurrency,
                      Colors.purple,
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: const Text(
                            "အသားတင် အမြတ်/အရှုံး (Net P&L):",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Text(
                          summary.netProfitLoss.toCurrency,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: summary.netProfitLoss >= 0
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Account Balances List
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.list_alt_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: const Text(
                            "စာရင်းခေါင်းစဉ်အလိုက် လက်ကျန်များ (Chart of Accounts)",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    if (summary.accounts.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: Text("စာရင်းမရှိသေးပါ"),
                      ),
                    ...summary.accounts.map((acc) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    acc.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    "Code: ${acc.code} | Type: ${acc.type}",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              acc.balance.toCurrency,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJournalLedgerTab(BuildContext context, AccountingState state) {
    return Column(
      children: [
        // Filter Chips Bar
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.03,
            vertical: 8,
          ),
          child: Row(
            children: [
              FilterChip(
                label: const Text("အားလုံး (All)"),
                selected: state.selectedFilter == null,
                onSelected: (selected) {
                  context.read<AccountingCubit>().filterEntries(null);
                },
              ),
              const SizedBox(width: 6),
              ...JournalEntryType.values.map((type) {
                final isSelected = state.selectedFilter == type;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    avatar: Icon(type.icon, size: 16, color: type.color),
                    label: Text(type.displayMM),
                    selected: isSelected,
                    onSelected: (selected) {
                      context.read<AccountingCubit>().filterEntries(
                        selected ? type : null,
                      );
                    },
                  ),
                );
              }),
            ],
          ),
        ),

        // Journal Entries List
        Expanded(
          child: RefreshIndicator.adaptive(
            onRefresh: () async {
              await context.read<AccountingCubit>().filterEntries(
                state.selectedFilter,
              );
            },
            child: state.entries.isEmpty
                ? const NoData(message: "ဂျာနယ်စာရင်းမှတ်တမ်း မရှိသေးပါ")
                : ListView.separated(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.03,
                      vertical: 8,
                    ),
                    itemCount: state.entries.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final entry = state.entries[index];
                      return _buildJournalEntryCard(context, entry);
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildJournalEntryCard(BuildContext context, JournalEntry entry) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Date, Entry Type, Reference No
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: entry.entryType.color.withAlpha(35),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            entry.entryType.icon,
                            size: 14,
                            color: entry.entryType.color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            entry.entryType.displayMM,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: entry.entryType.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (entry.referenceNo != null)
                      Text(
                        entry.referenceNo!,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
                Text(
                  DateTimeUtil.formatDate(entry.entryDate),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Description
            Text(
              entry.description,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),

            if (entry.transaction?.contact?.name != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  "သက်ဆိုင်သူ: ${entry.transaction!.contact!.name}",
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ),

            const Divider(height: 14),

            // Double Entry Debit/Credit Line Items
            ...entry.items.map((item) {
              final isDebit = item.debit > 0;
              final amount = isDebit ? item.debit : item.credit;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    // Debit / Credit indicator
                    Container(
                      width: 55,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isDebit
                            ? Colors.blue.withAlpha(25)
                            : Colors.orange.withAlpha(25),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isDebit ? "Debit (Dr)" : "Credit (Cr)",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isDebit
                              ? Colors.blue[800]
                              : Colors.deepOrange[800],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.accountName,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    Text(
                      amount.toCurrency,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDebit
                            ? Colors.blue[900]
                            : Colors.deepOrange[900],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _statRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
