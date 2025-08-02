// ...existing code...
import 'app_localizations.dart';
// Order Details Screen
  @override
  String get orderDetailsTitle => 'Order Details';
  @override
  String get orderNotFound => 'Order not found.';
  @override
  String get customer => 'Customer';
  @override
  String get address => 'Address';
  @override
  String get paymentTerms => 'Payment Terms';
  @override
  String get quotationTemplate => 'Quotation Template';
  @override
  String get orderLines => 'Order Lines';
  @override
  String get untaxedAmount => 'Untaxed Amount';
  @override
  String get vat => 'VAT';
  @override
  String get total => 'Total';
  @override
  String get description => 'Description';
  @override
  String get quantity => 'Quantity';
  @override
  String get delivered => 'Delivered';
  @override
  String get invoiced => 'Invoiced';
  @override
  String get unitPrice => 'Unit Price';
  @override
  String get taxExcl => 'Tax excl.';
  @override
  String get tax => 'Tax';

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  @override
  String get savedSuccessfully => 'Order saved successfully.';
  @override
  String get saveFailed => 'Failed to save order.';
  @override
  String get enabled => 'Enabled';
  @override
  String get disabled => 'Disabled';
  @override
  String get onlineSignature => 'Online Signature';
  @override
  String get onlinePayment => 'Online Payment';
  @override
  String get delivery => 'Delivery';
  @override
  String get tracking => 'Tracking';
  @override
  String get orderDetailsTitle => 'Order Details';
  @override
  String get orderLines => 'Order Lines';
  @override
  String get orderNotFound => 'Order not found.';
  @override
  String get product => 'Product';
  @override
  String get quotationTemplate => 'Quotation Template';
  @override
  String get taxExcl => 'Tax excl.';
  @override
  String get taxes => 'Taxes';
  @override
  String get unitPrice => 'Unit Price';
  @override
  String get untaxedAmount => 'Untaxed Amount';
  @override
  String get vat => 'VAT';
  @override
  String get salesOrdersTitle => 'Sales Orders';
  @override
  String get searchOrders => 'Search Orders';
  @override
  String get noOrdersFound => 'No orders found.';
  @override
  String get orderMissingId => 'Order missing ID';
  @override
  String get invalidOrderData => 'Invalid order data';
  @override
  String get orderDate => 'Order Date';
  @override
  String get salesperson => 'Salesperson';
  @override
  String get invoiceStatus => 'Invoice Status';
  @override
  String get internalReference => 'Internal Reference';
  @override
  String get addToOrder => 'Add to Order';
  @override
  String get updateStock => 'Update Stock';
  @override
  String get noProductsToDisplay => 'No products to display.';
  @override
  String get number => 'Number';
  @override
  String get validUntil => 'Valid Until';
  @override
  String get saveChanges => 'Save Changes';
  @override
  String statusLabel(String status) {
    switch (status) {
      case 'draft':
        return 'Draft';
      case 'sent':
        return 'Sent';
      case 'confirmed':
        return 'Confirmed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }
  @override
  String get quotationsSentSuccess => 'Quotation sent to customer.';
  @override
  String get quotationConvertedSuccess => 'Quotation converted to sales order.';
  @override
  String get cancelQuotationTitle => 'Cancel Quotation';
  @override
  String get cancelQuotationConfirm => 'Are you sure you want to cancel this quotation?';
  @override
  String get quotationCancelledSuccess => 'Quotation cancelled successfully.';
  @override
  String get quotationCancelledFailed => 'Failed to cancel quotation.';
  @override
  String get deleteQuotationTitle => 'Delete Quotation';
  @override
  String get deleteQuotationConfirm => 'Are you sure you want to delete this quotation? This action cannot be undone.';
  @override
  String get quotationDeletedFailed => 'Failed to delete quotation.';
  @override
  String get activities => 'Activities';
  @override
  String get delivered => 'Delivered';
  @override
  String get invoiced => 'Invoiced';
  @override
  String get share => 'Share';
  @override
  String get send => 'Send';
  @override
  String get quotationsTitle => 'Quotations';
  @override
  String get quotationsSearchHint => 'Search quotations...';
  @override
  String get quotationsNoResults => 'No quotations found.';
  @override
  String get quotationsDeletedSuccess => 'Quotation deleted successfully.';
  @override
  String quotationsOrderDate(String date) => 'Order Date: $date';
  @override
  String quotationsCustomer(String name) => 'Customer: $name';
  @override
  String quotationsSalesperson(String name) => 'Salesperson: $name';
  @override
  String quotationsCompany(String name) => 'Company: $name';
  @override
  String quotationsTotal(String total) => 'Total: $total';
  String get mobile => 'Mobile';
  String get jobPosition => 'Job Position';
  String get campaign => 'Campaign';
  String get source => 'Source';
  String get medium => 'Medium';
  String get referredBy => 'Referred By';
  String get priority => 'Priority';
  String get type => 'Type';
  String get function => 'Function';
  String get trackingDetails => 'Tracking Details';
  String get salesTeam => 'Sales Team';
  String get daysToAssign => 'Days to Assign';
  String get daysToClose => 'Days to Close';
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ODOOFF';

  @override
  String get appSubtitle => 'Business Management';

  @override
  String get crm => 'CRM';

  @override
  String get sales => 'Sales';

  @override
  String get invoicing => 'Invoicing';

  @override
  String get inventory => 'Inventory';

  @override
  String get contacts => 'Contacts';

  @override
  String get timesheets => 'Timesheets';

  @override
  String get expenses => 'Expenses';

  @override
  String get tasks => 'Tasks';

  @override
  String get messaging => 'Messaging';

  @override
  String get other => 'Other';

  @override
  String get settings => 'Settings';

  @override
  String get save => 'SAVE';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get search => 'Search';

  @override
  String get refresh => 'Refresh';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get previous => 'Previous';

  @override
  String get confirm => 'Confirm';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get signIn => 'Sign In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get signOut => 'Sign Out';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get fullName => 'Full Name';

  @override
  String get company => 'Company';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get createAccount => 'Create Account';

  @override
  String get welcomeBack => 'Welcome back to ODOOFF! Sign in to continue';

  @override
  String get welcomeMessage => 'Create your account to get started';

  @override
  String get invalidCredentials => 'Invalid email or password';

  @override
  String get registrationFailed => 'Registration failed. Please try again.';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get checkYourEmail => 'Check Your Email';

  @override
  String get backToSignIn => 'Back to Sign In';

  @override
  String get customerRelationshipManagement => 'Customer Relationship Management';

  @override
  String get totalCustomers => 'Total Customers';

  @override
  String get activeOpportunities => 'Active Opportunities';

  @override
  String get revenuePipeline => 'Revenue Pipeline';

  @override
  String get conversionRate => 'Conversion Rate';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get customers => 'Customers';

  @override
  String get opportunities => 'Opportunities';

  @override
  String get manageCustomerRelationships => 'Manage customer relationships';

  @override
  String get trackSalesOpportunities => 'Track sales opportunities';

  @override
  String get addCustomer => 'Add Customer';

  @override
  String get editCustomer => 'Edit Customer';

  @override
  String get customerName => 'Customer Name';

  @override
  String get phone => 'Phone';

  @override
  String get address => 'Address';

  @override
  String get city => 'City';

  @override
  String get state => 'State';

  @override
  String get country => 'Country';

  @override
  String get zipCode => 'ZIP Code';

  @override
  String get website => 'Website';

  @override
  String get industry => 'Industry';

  @override
  String get customerType => 'Customer Type';

  @override
  String get status => 'Status';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get prospect => 'Prospect';

  @override
  String get individual => 'Individual';

  @override
  String get basicInformation => 'Basic Information';

  @override
  String get addressInformation => 'Address Information';

  @override
  String get additionalInformation => 'Additional Information';

  @override
  String get activeCustomer => 'Active Customer';

  @override
  String get customerIsCurrentlyActive => 'Customer is currently active';

  @override
  String get addOpportunity => 'Add Opportunity';

  @override
  String get editOpportunity => 'Edit Opportunity';

  @override
  String get opportunityDetails => 'Opportunity Details';

  @override
  String get title => 'Title';

  @override
  String get customer => 'Customer';

  @override
  String get expectedRevenue => 'Expected Revenue';

  @override
  String get probability => 'Probability';

  @override
  String get stage => 'Stage';

  @override
  String get salesPerson => 'Sales Person';

  @override
  String get expectedCloseDate => 'Expected Close Date';

  @override
  String get description => 'Description';

  @override
  String get moreDetails => 'More Details';

  @override
  String get salesManagement => 'Sales Management';

  @override
  String get monthlySales => 'Monthly Sales';

  @override
  String get activeOrders => 'Active Orders';

  @override
  String get pendingQuotes => 'Pending Quotes';

  @override
  String get products => 'Products';

  @override
  String get quotations => 'Quotations';

  @override
  String get orders => 'Orders';

  @override
  String get createAndManageQuotations => 'Create and manage quotations';

  @override
  String get trackSalesOrders => 'Track sales orders';

  @override
  String get manageProductCatalog => 'Manage product catalog';

  @override
  String get addProduct => 'Add Product';

  @override
  String get editProduct => 'Edit Product';

  @override
  String get productName => 'Product Name';

  @override
  String get sku => 'SKU';

  @override
  String get category => 'Category';

  @override
  String get cost => 'Cost';

  @override
  String get salePrice => 'Sale Price';

  @override
  String get listPrice => 'List Price';

  @override
  String get productType => 'Product Type';

  @override
  String get unitOfMeasure => 'Unit of Measure';

  @override
  String get canBeSold => 'Can be Sold';

  @override
  String get canBePurchased => 'Can be Purchased';

  @override
  String get pricing => 'Pricing';

  @override
  String get barcode => 'Barcode';

  @override
  String get weight => 'Weight';

  @override
  String get productInformation => 'Product Information';

  @override
  String get onHand => 'On Hand';

  @override
  String get forecasted => 'Forecasted';

  @override
  String get incomingQty => 'In';

  @override
  String get outgoingQty => 'Out';

  @override
  String get invoicingPolicy => 'Invoicing Policy';

  @override
  String get invoiceManagement => 'Invoice Management';

  @override
  String get totalInvoiced => 'Total Invoiced';

  @override
  String get outstanding => 'Outstanding';

  @override
  String get overdue => 'Overdue';

  @override
  String get paidThisMonth => 'Paid This Month';

  @override
  String get invoices => 'Invoices';

  @override
  String get payments => 'Payments';

  @override
  String get purchaseOrders => 'Purchase Orders';

  @override
  String get createAndManageInvoices => 'Create and manage invoices';

  @override
  String get trackPaymentStatus => 'Track payment status';

  @override
  String get managePurchaseOrders => 'Manage purchase orders';

  @override
  String get addInvoice => 'Add Invoice';

  @override
  String get editInvoice => 'Edit Invoice';

  @override
  String get invoiceNumber => 'Invoice Number';

  @override
  String get invoiceDate => 'Invoice Date';

  @override
  String get dueDate => 'Due Date';

  @override
  String get paymentTerms => 'Payment Terms';

  @override
  String get reference => 'Reference';

  @override
  String get invoiceLines => 'Invoice Lines';

  @override
  String get addLine => 'Add Line';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get tax => 'Tax';

  @override
  String get total => 'Total';

  @override
  String get draft => 'Draft';

  @override
  String get posted => 'Posted';

  @override
  String get paid => 'Paid';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get inventoryLogisticsManagement => 'Inventory & Logistics Management';

  @override
  String get totalProducts => 'Total Products';

  @override
  String get lowStock => 'Low Stock';

  @override
  String get pendingTransfers => 'Pending Transfers';

  @override
  String get locations => 'Locations';

  @override
  String get viewAndManageStockLevels => 'View and manage stock levels';

  @override
  String get manageWarehouseLocations => 'Manage warehouse locations';

  @override
  String get stockTransfersBetweenLocations => 'Stock transfers between locations';

  @override
  String get incomingStockReceipts => 'Incoming stock receipts';

  @override
  String get outgoingDeliveries => 'Outgoing deliveries';

  @override
  String get transfers => 'Transfers';

  @override
  String get receipts => 'Receipts';

  @override
  String get deliveries => 'Deliveries';

  @override
  String get completeAddressBook => 'Complete address book';

  @override
  String get workingTimeTracking => 'Working time tracking';

  @override
  String get addExpensesWithAttachments => 'Add expenses with attachments';

  @override
  String get actionPlanManagement => 'Action plan management';

  @override
  String get odooMessages => 'Odoo messages';

  @override
  String get additionalFeatures => 'Additional Features';

  @override
  String get name => 'Name';

  @override
  String get date => 'Date';

  @override
  String get amount => 'Amount';

  @override
  String get quantity => 'Quantity';

  @override
  String get price => 'Price';

  @override
  String get notes => 'Notes';

  @override
  String get created => 'Created';

  @override
  String get updated => 'Updated';

  @override
  String get noDataFound => 'No data found';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get failed => 'Failed';

  @override
  String get retry => 'Retry';

  @override
  String get pleaseEnterEmail => 'Please enter your email';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email';

  @override
  String get pleaseEnterPassword => 'Please enter your password';

  @override
  String get pleaseEnterName => 'Please enter your name';

  @override
  String get pleaseSelectCustomer => 'Please select a customer';

  @override
  String get required => 'Required';

  @override
  String get invalidNumber => 'Invalid number';

  @override
  String get profile => 'Profile';

  @override
  String get accountInformation => 'Account Information';

  @override
  String get memberSince => 'Member Since';

  @override
  String get lastLogin => 'Last Login';

  @override
  String get helpSupport => 'Help & Support';

  @override
  String get about => 'About';

  @override
  String get areYouSureSignOut => 'Are you sure you want to sign out?';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get french => 'Français';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get overview => 'Overview';
}