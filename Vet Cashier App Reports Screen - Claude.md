Let's continue with implementing the reports screen. I'll provide the complete file for `lib/screens/reports/reports_screen.dart`:

```
<div><p>dart</p><div><p><code id="code-lang-dart">import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../services/reports_service.dart';
import '../../models/product_model.dart';

class ReportsScreen extends StatefulWidget {
  final String storeId;
  
  const ReportsScreen({Key? key, required this.storeId}) : super(key: key);

  @override
  _ReportsScreenState createState() =&gt; _ReportsScreenState();
}

class _ReportsScreenState extends State&lt;ReportsScreen&gt; with SingleTickerProviderStateMixin {
  late ReportsService _reportsService;
  
  late TabController _tabController;
  String _selectedPeriod = 'today';
  bool _isLoading = false;
  Map&lt;String, dynamic&gt; _salesData = {};
  Map&lt;String, dynamic&gt; _inventoryData = {};
  Map&lt;String, dynamic&gt; _financialData = {};
  List&lt;Map&lt;String, dynamic&gt;&gt; _topSellingProducts = [];
  
  // Date range for custom period
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _reportsService = ReportsService(storeId: widget.storeId);
    _loadReports();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future&lt;void&gt; _loadReports() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Determine date range based on selected period
      DateTime start, end;
      switch (_selectedPeriod) {
        case 'today':
          start = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
          end = DateTime.now();
          break;
        case 'yesterday':
          final yesterday = DateTime.now().subtract(const Duration(days: 1));
          start = DateTime(yesterday.year, yesterday.month, yesterday.day);
          end = DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59);
          break;
        case 'this_week':
          final now = DateTime.now();
          start = now.subtract(Duration(days: now.weekday - 1));
          start = DateTime(start.year, start.month, start.day);
          end = DateTime.now();
          break;
        case 'last_week':
          final now = DateTime.now();
          start = now.subtract(Duration(days: now.weekday + 6));
          start = DateTime(start.year, start.month, start.day);
          end = start.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
          break;
        case 'this_month':
          start = DateTime(DateTime.now().year, DateTime.now().month, 1);
          end = DateTime.now();
          break;
        case 'last_month':
          final lastMonth = DateTime.now().month == 1
              ? DateTime(DateTime.now().year - 1, 12, 1)
              : DateTime(DateTime.now().year, DateTime.now().month - 1, 1);
          start = lastMonth;
          end = DateTime(lastMonth.year, lastMonth.month + 1, 0, 23, 59, 59);
          break;
        case 'custom':
          start = _startDate;
          end = _endDate;
          break;
        default:
          start = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
          end = DateTime.now();
      }
      
      // Load reports for the selected period
      _salesData = await _reportsService.getSalesSummary(widget.storeId, start, end);
      _inventoryData = await _reportsService.getInventorySummary(widget.storeId);
      _financialData = await _reportsService.getFinancialReport(widget.storeId, start, end);
      _topSellingProducts = await _reportsService.getTopSellingProducts(
        widget.storeId, start, end, limit: 5,
      );
    } catch (e) {
      print('Error loading reports: $e');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading reports: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Sales'),
            Tab(text: 'Inventory'),
            Tab(text: 'Financial'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Period selection
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Text('Period:'),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField&lt;String&gt;(
                    value: _selectedPeriod,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'today', child: Text('Today')),
                      DropdownMenuItem(value: 'yesterday', child: Text('Yesterday')),
                      DropdownMenuItem(value: 'this_week', child: Text('This Week')),
                      DropdownMenuItem(value: 'last_week', child: Text('Last Week')),
                      DropdownMenuItem(value: 'this_month', child: Text('This Month')),
                      DropdownMenuItem(value: 'last_month', child: Text('Last Month')),
                      DropdownMenuItem(value: 'custom', child: Text('Custom')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedPeriod = value!;
                        if (value == 'custom') {
                          _showDateRangePicker();
                        } else {
                          _loadReports();
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Date range display for custom period
          if (_selectedPeriod == 'custom')
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'From: ${DateFormat('MMM d, yyyy').format(_startDate)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'To: ${DateFormat('MMM d, yyyy').format(_endDate)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18),
                    onPressed: _showDateRangePicker,
                  ),
                ],
              ),
            ),
          
          // Report content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildSalesReport(),
                      _buildInventoryReport(),
                      _buildFinancialReport(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSalesReport() {
    double totalSales = _salesData['totalSales'] ?? 0;
    double totalProfit = _salesData['totalProfit'] ?? 0;
    int totalItems = _salesData['totalItems'] ?? 0;
    int invoiceCount = _salesData['invoiceCount'] ?? 0;
    double averageSaleValue = _salesData['averageSaleValue'] ?? 0;
    double profitMargin = _salesData['profitMargin'] ?? 0;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary cards
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Sales',
                  '\$${totalSales.toStringAsFixed(2)}',
                  Icons.attach_money,
                  Colors.green,
                ),
              ),
              Expanded(
                child: _buildSummaryCard(
                  'Invoices',
                  invoiceCount.toString(),
                  Icons.receipt,
                  Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Items Sold',
                  totalItems.toString(),
                  Icons.shopping_cart,
                  Colors.orange,
                ),
              ),
              Expanded(
                child: _buildSummaryCard(
                  'Avg. Sale',
                  '\$${averageSaleValue.toStringAsFixed(2)}',
                  Icons.show_chart,
                  Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Profit',
                  '\$${totalProfit.toStringAsFixed(2)}',
                  Icons.trending_up,
                  Colors.teal,
                ),
              ),
              Expanded(
                child: _buildSummaryCard(
                  'Profit Margin',
                  '${profitMargin.toStringAsFixed(2)}%',
                  Icons.pie_chart,
                  Colors.indigo,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Top selling products
          const Text(
            'Top Selling Products',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _topSellingProducts.isEmpty
              ? const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No sales data for this period'),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _topSellingProducts.length,
                  itemBuilder: (context, index) {
                    final product = _topSellingProducts[index];
                    return Card(
                      child: ListTile(
                        title: Text(product['productName'] ?? ''),
                        subtitle: Text('Quantity sold: ${product['quantitySold']}'),
                        trailing: Text(
                          '\$${(product['revenue'] ?? 0.0).toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                ),
          
          // TODO: Add sales charts here
        ],
      ),
    );
  }
  
  Widget _buildInventoryReport() {
    double totalInventoryValue = _inventoryData['totalInventoryValue'] ?? 0;
    int totalItems = _inventoryData['totalItems'] ?? 0;
    int productCount = _inventoryData['productCount'] ?? 0;
    int lowStockCount = _inventoryData['lowStockCount'] ?? 0;
    List&lt;ProductModel&gt; lowStockProducts = _inventoryData['lowStockProducts'] ?? [];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary cards
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Inventory Value',
                  '\$${totalInventoryValue.toStringAsFixed(2)}',
                  Icons.inventory,
                  Colors.blue,
                ),
              ),
              Expanded(
                child: _buildSummaryCard(
                  'Total Products',
                  productCount.toString(),
                  Icons.category,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Items',
                  totalItems.toString(),
                  Icons.inventory_2,
                  Colors.orange,
                ),
              ),
              Expanded(
                child: _buildSummaryCard(
                  'Low Stock Items',
                  lowStockCount.toString(),
                  Icons.warning,
                  lowStockCount &gt; 0 ? Colors.red : Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Low stock alerts
          const Text(
            'Low Stock Alerts',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          lowStockProducts.isEmpty
              ? const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No low stock items'),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: lowStockProducts.length,
                  itemBuilder: (context, index) {
                    final product = lowStockProducts[index];
                    return Card(
                      child: ListTile(
                        title: Text(product.name),
                        subtitle: Text('Current stock: ${product.quantity}'),
                        trailing: Text(
                          'Alert threshold: ${product.alertThreshold}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  },
                ),
          
          // TODO: Add inventory charts here
        ],
      ),
    );
  }
  
  Widget _buildFinancialReport() {
    double totalSales = _financialData['totalSales'] ?? 0;
    double totalPurchases = _financialData['totalPurchases'] ?? 0;
    double grossProfit = _financialData['grossProfit'] ?? 0;
    double netProfit = _financialData['netProfit'] ?? 0;
    double accountsReceivable = _financialData['accountsReceivable'] ?? 0;
    double accountsPayable = _financialData['accountsPayable'] ?? 0;
    double profitMargin = _financialData['profitMargin'] ?? 0;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary cards
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Revenue',
                  '\$${totalSales.toStringAsFixed(2)}',
                  Icons.trending_up,
                  Colors.green,
                ),
              ),
              Expanded(
                child: _buildSummaryCard(
                  'Purchases',
                  '\$${totalPurchases.toStringAsFixed(2)}',
                  Icons.trending_down,
                  Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Gross Profit',
                  '\$${grossProfit.toStringAsFixed(2)}',
                  Icons.show_chart,
                  Colors.blue,
                ),
              ),
              Expanded(
                child: _buildSummaryCard(
                  'Net Profit',
                  '\$${netProfit.toStringAsFixed(2)}',
                  Icons.monetization_on,
                  netProfit &gt;= 0 ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Accounts Receivable',
                  '\$${accountsReceivable.toStringAsFixed(2)}',
                  Icons.account_balance_wallet,
                  Colors.orange,
                ),
              ),
              Expanded(
                child: _buildSummaryCard(
                  'Accounts Payable',
                  '\$${accountsPayable.toStringAsFixed(2)}',
                  Icons.account_balance,
                  Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSummaryCard(
            'Profit Margin',
            '${profitMargin.toStringAsFixed(2)}%',
            Icons.pie_chart,
            Colors.teal,
            fullWidth: true,
          ),
          const SizedBox(height: 24),
          
          // Financial statement
          const Text(
            'Financial Statement',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildStatementRow('Revenue', totalSales),
                  _buildStatementRow('Cost of Goods Sold', -totalPurchases),
                  _buildDivider(),
                  _buildStatementRow('Gross Profit', grossProfit, isBold: true),
                  _buildStatementRow('Operating Expenses', 0), // Not tracked in this app
                  _buildDivider(),
                  _buildStatementRow('Net Profit', netProfit, isBold: true),
                  const SizedBox(height: 16),
                  _buildStatementRow('Accounts Receivable', accountsReceivable),
                  _buildStatementRow('Accounts Payable', -accountsPayable),
                  _buildDivider(),
                  _buildStatementRow('Net Position', accountsReceivable - accountsPayable, isBold: true),
                ],
              ),
            ),
          ),
          
          // TODO: Add financial charts here
        ],
      ),
    );
  }
  
  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    bool fullWidth = false,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Container(
        width: fullWidth ? double.infinity : null,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatementRow(String label, double value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value &gt;= 0 
                ? '\$${value.toStringAsFixed(2)}' 
                : '-\$${value.abs().toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: value &gt;= 0 ? Colors.black : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Divider(height: 1, color: Colors.grey[400]),
    );
  }
  
  Future&lt;void&gt; _showDateRangePicker() async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: _startDate,
        end: _endDate,
      ),
    );
    
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _loadReports();
      });
    }
  }
}</code></p></div></div>
```

Let me know when you've added this file, and then I'll provide the updated `main.dart` file to include the reports screen route.