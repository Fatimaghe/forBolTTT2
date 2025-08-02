// Removed duplicate top-level declarations for order details screen keys
// Removed duplicate top-level declarations for order details screen keys

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;
import 'package:flutter/foundation.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

abstract class AppLocalizations {
  // Order save result
  String get savedSuccessfully;
  String get saveFailed;
  // --- Added for order details screen ---
  String get enabled;
  String get disabled;
  String get onlineSignature;
  String get onlinePayment;
  String get delivery;
  String get tracking;
  // App Title
  String get appTitle;
  String get appSubtitle;

  // Navigation (missing keys)
  String get invoicing;
  String get inventory;
  String get contacts;
  String get timesheets;

  // Sales Orders List Screen (missing keys)
  String get salesOrdersTitle;

  // Sales/Quotations Table and Actions (missing keys)
  String get activities;

  // CRM/Opportunity Fields (missing keys)
  String get referredBy;

  // Quotations (missing key)
  String get quotations;

  // Product/Order Details (missing keys)
  String get product;
  String get taxes;
  String get searchOrders;
  String get noOrdersFound;
  String get orderMissingId;
  String get invalidOrderData;
  String get orderDate;
  String get salesperson;
  String get invoiceStatus;
  String get internalReference;
  String get addToOrder;
  String get updateStock;
  String get noProductsToDisplay;

  // Edit Quotation Form
  String get number;
  String get validUntil;
  String get saveChanges;

  // Order Details Screen
  String get orderDetailsTitle;
  String get orderNotFound;
  String get customer;
  String get address;
  String get paymentTerms;
  String get quotationTemplate;
  String get orderLines;
  String get untaxedAmount;
  String get vat;
  String get total;
  String get description;
  String get quantity;
  String get unitPrice;
  String get taxExcl;
  String get tax;

  // Status label helper
  String statusLabel(String status);
  // Quotation detail dialogs and actions
  String get quotationsSentSuccess;
  String get quotationConvertedSuccess;
  String get cancelQuotationTitle;
  String get cancelQuotationConfirm;
  String get quotationCancelledSuccess;
  String get quotationCancelledFailed;
  String get deleteQuotationTitle;
  String get deleteQuotationConfirm;
  String get quotationDeletedFailed;
  // Quotations screen
  String get quotationsTitle;
  String get quotationsSearchHint;
  String get quotationsNoResults;
  String get quotationsDeletedSuccess;
  String quotationsOrderDate(String date);
  String quotationsCustomer(String name);
  String quotationsSalesperson(String name);
  String quotationsCompany(String name);
  String quotationsTotal(String total);

  // Sales dashboard and products
  String get monthlySales;
  String get activeOrders;
  String get pendingQuotes;
  String get products;
  String get orders;
  String get createAndManageQuotations;
  String get trackSalesOrders;
  String get manageProductCatalog;
  // Sales/Quotations Table and Actions
  String get delivered;
  String get invoiced;
  String get share;
  // Additional CRM/Opportunity Fields
  String get mobile;
  String get jobPosition;
  String get campaign;
  String get source;
  String get medium;
  String get priority;
  String get type;
  String get function;
  String get trackingDetails;
  String get salesTeam;
  String get daysToAssign;
  String get daysToClose;
  final String localeName;
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr')
  ];


  // Navigation
  String get crm;
  String get sales;
  String get expenses;
  String get tasks;
  String get messaging;
  String get other;
  String get settings;

  // Common Actions
  String get save;
  String get cancel;
  String get delete;
  String get edit;
  String get add;
  String get search;
  String get refresh;
  String get back;
  String get next;
  String get previous;
  String get confirm;
  String get yes;
  String get no;
  String get send;

  // Authentication
  String get signIn;
  String get signUp;
  String get signOut;
  String get email;
  String get password;
  String get confirmPassword;
  String get fullName;
  String get company;
  String get rememberMe;
  String get forgotPassword;
  String get createAccount;
  String get welcomeBack;
  String get welcomeMessage;
  String get invalidCredentials;
  String get registrationFailed;
  String get resetPassword;
  String get checkYourEmail;
  String get backToSignIn;

  // CRM
  String get customerRelationshipManagement;
  String get totalCustomers;
  String get activeOpportunities;
  String get revenuePipeline;
  String get conversionRate;
  String get quickActions;
  String get customers;
  String get opportunities;
  String get manageCustomerRelationships;
  String get trackSalesOpportunities;

  // Customer Management
  String get addCustomer;
  String get editCustomer;
  String get customerName;
  String get phone;
  // String get address; // duplicate removed
  String get city;
  String get state;
  String get country;
  String get zipCode;
  String get website;
  String get industry;
  String get customerType;
  String get status;
  String get active;
  String get inactive;
  String get prospect;
  String get individual;
  String get basicInformation;
  String get addressInformation;
  String get additionalInformation;
  String get activeCustomer;
  String get customerIsCurrentlyActive;

  // Opportunity Management
  String get addOpportunity;
  String get editOpportunity;
  String get opportunityDetails;
  String get title;
  // String get customer; // duplicate removed
  String get expectedRevenue;
  String get probability;
  String get stage;
  String get salesPerson;
  String get expectedCloseDate;
  // String get description; // duplicate removed
  String get moreDetails;

  // Sales
  String get salesManagement;

  // Product Management
  String get addProduct;
  String get editProduct;
  String get productName;
  String get sku;
  String get category;
  String get cost;
  String get salePrice;
  String get listPrice;
  String get productType;
  String get unitOfMeasure;
  String get canBeSold;
  String get canBePurchased;
  String get pricing;
  String get barcode;
  String get weight;
  String get productInformation;
  String get onHand;
  String get forecasted;
  String get incomingQty;
  String get outgoingQty;
  String get invoicingPolicy;

  // Invoicing
  String get invoiceManagement;
  String get totalInvoiced;
  String get outstanding;
  String get overdue;
  String get paidThisMonth;
  String get invoices;
  String get payments;
  String get purchaseOrders;
  String get createAndManageInvoices;
  String get trackPaymentStatus;
  String get managePurchaseOrders;

  // Invoice Management
  String get addInvoice;
  String get editInvoice;
  String get invoiceNumber;
  String get invoiceDate;
  String get dueDate;
  // String get paymentTerms; // duplicate removed
  String get reference;
  String get invoiceLines;
  String get addLine;
  String get subtotal;
  // String get tax; // duplicate removed
  // String get total; // duplicate removed
  String get draft;
  String get posted;
  String get paid;
  String get cancelled;

  // Inventory
  String get inventoryLogisticsManagement;
  String get totalProducts;
  String get lowStock;
  String get pendingTransfers;
  String get locations;
  String get viewAndManageStockLevels;
  String get manageWarehouseLocations;
  String get stockTransfersBetweenLocations;
  String get incomingStockReceipts;
  String get outgoingDeliveries;
  String get transfers;
  String get receipts;
  String get deliveries;

  // Contacts
  String get completeAddressBook;
  String get workingTimeTracking;
  String get addExpensesWithAttachments;
  String get actionPlanManagement;
  String get odooMessages;
  String get additionalFeatures;

  // Common Fields
  String get name;
  String get date;
  String get amount;
  // String get quantity; // duplicate removed
  String get price;
  String get notes;
  String get created;
  String get updated;

  // Status Messages
  String get noDataFound;
  String get loading;
  String get error;
  String get success;
  String get failed;
  String get retry;

  // Validation Messages
  String get pleaseEnterEmail;
  String get pleaseEnterValidEmail;
  String get pleaseEnterPassword;
  String get pleaseEnterName;
  String get pleaseSelectCustomer;
  String get required;
  String get invalidNumber;

  // Profile
  String get profile;
  String get accountInformation;
  String get memberSince;
  String get lastLogin;
  String get helpSupport;
  String get about;
  String get areYouSureSignOut;

  // Language
  String get language;
  String get english;
  String get french;
  String get selectLanguage;

  // Overview
  String get overview;

}

// Delegate class for AppLocalizations
class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'fr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    final String lang = locale.languageCode;
    if (lang == 'fr') {
      return SynchronousFuture<AppLocalizations>(AppLocalizationsFr());
    }
    // Default to English
    return SynchronousFuture<AppLocalizations>(AppLocalizationsEn());
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}