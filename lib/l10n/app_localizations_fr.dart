// ...existing code...
import 'app_localizations.dart';
// Order Details Screen
  @override
  String get orderDetailsTitle => 'Détails de la commande';
  @override
  String get orderNotFound => 'Commande non trouvée.';
  @override
  String get customer => 'Client';
  @override
  String get address => 'Adresse';
  @override
  String get paymentTerms => 'Conditions de paiement';
  @override
  String get quotationTemplate => 'Modèle de devis';
  @override
  String get orderLines => 'Lignes de commande';
  @override
  String get untaxedAmount => 'Montant HT';
  @override
  String get vat => 'TVA';
  @override
  String get total => 'Total';
  @override
  String get description => 'Description';
  @override
  String get quantity => 'Quantité';
  @override
  String get delivered => 'Livré';
  @override
  String get invoiced => 'Facturé';
  @override
  String get unitPrice => 'Prix unitaire';
  @override
  String get taxExcl => 'Hors taxe';
  @override
  String get tax => 'Taxe';

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  @override
  String get savedSuccessfully => 'Commande enregistrée avec succès.';
  @override
  String get saveFailed => "Échec de l'enregistrement de la commande.";
  @override
  String get enabled => 'Activé';
  @override
  String get disabled => 'Désactivé';
  @override
  String get onlineSignature => 'Signature en ligne';
  @override
  String get onlinePayment => 'Paiement en ligne';
  @override
  String get delivery => 'Livraison';
  @override
  String get tracking => 'Suivi';
  @override
  String get orderDetailsTitle => 'Détails de la commande';
  @override
  String get orderLines => 'Lignes de commande';
  @override
  String get orderNotFound => 'Commande non trouvée.';
  @override
  String get product => 'Produit';
  @override
  String get quotationTemplate => 'Modèle de devis';
  @override
  String get taxExcl => 'Hors taxe';
  @override
  String get taxes => 'Taxes';
  @override
  String get unitPrice => 'Prix unitaire';
  @override
  String get untaxedAmount => 'Montant HT';
  @override
  String get vat => 'TVA';
  @override
  String get salesOrdersTitle => 'Commandes';
  @override
  String get searchOrders => 'Rechercher des commandes';
  @override
  String get noOrdersFound => 'Aucune commande trouvée.';
  @override
  String get orderMissingId => 'Commande sans identifiant';
  @override
  String get invalidOrderData => 'Données de commande invalides';
  @override
  String get orderDate => 'Date de commande';
  @override
  String get salesperson => 'Vendeur';
  @override
  String get invoiceStatus => 'Statut de facture';
  @override
  String get internalReference => 'Référence interne';
  @override
  String get addToOrder => 'Ajouter à la commande';
  @override
  String get updateStock => 'Mettre à jour le stock';
  @override
  String get noProductsToDisplay => 'Aucun produit à afficher.';
  @override
  String get number => 'Numéro';
  @override
  String get validUntil => 'Valide jusqu\'à';
  @override
  String get saveChanges => 'Enregistrer les modifications';
  @override
  String statusLabel(String status) {
    switch (status) {
      case 'draft':
        return 'Brouillon';
      case 'sent':
        return 'Envoyé';
      case 'confirmed':
        return 'Confirmé';
      case 'cancelled':
        return 'Annulé';
      default:
        return status;
    }
  }
  @override
  String get quotationsSentSuccess => 'Devis envoyé au client.';
  @override
  String get quotationConvertedSuccess => 'Devis converti en commande client.';
  @override
  String get cancelQuotationTitle => 'Annuler le devis';
  @override
  String get cancelQuotationConfirm => 'Êtes-vous sûr de vouloir annuler ce devis ?';
  @override
  String get quotationCancelledSuccess => 'Devis annulé avec succès.';
  @override
  String get quotationCancelledFailed => 'Échec de l\'annulation du devis.';
  @override
  String get deleteQuotationTitle => 'Supprimer le devis';
  @override
  String get deleteQuotationConfirm => 'Êtes-vous sûr de vouloir supprimer ce devis ? Cette action est irréversible.';
  @override
  String get quotationDeletedFailed => 'Échec de la suppression du devis.';
  @override
  String get activities => 'Activités';
  @override
  String get delivered => 'Livré';
  @override
  String get invoiced => 'Facturé';
  @override
  String get share => 'Partager';
  @override
  String get send => 'Envoyer';
  @override
  String get quotationsTitle => 'Devis';
  @override
  String get quotationsSearchHint => 'Rechercher des devis...';
  @override
  String get quotationsNoResults => 'Aucun devis trouvé.';
  @override
  String get quotationsDeletedSuccess => 'Devis supprimé avec succès.';
  @override
  String quotationsOrderDate(String date) => 'Date de commande : $date';
  @override
  String quotationsCustomer(String name) => 'Client : $name';
  @override
  String quotationsSalesperson(String name) => 'Vendeur : $name';
  @override
  String quotationsCompany(String name) => 'Société : $name';
  @override
  String quotationsTotal(String total) => 'Total : $total';
  String get mobile => 'Portable';
  String get jobPosition => 'Poste';
  String get campaign => 'Campagne';
  String get source => 'Source';
  String get medium => 'Moyen';
  String get referredBy => 'Référé par';
  String get priority => 'Priorité';
  String get type => 'Type';
  String get function => 'Fonction';
  String get trackingDetails => 'Détails de suivi';
  String get salesTeam => 'Équipe de vente';
  String get daysToAssign => 'Jours pour assigner';
  String get daysToClose => 'Jours pour clôturer';
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'ODOOFF';

  @override
  String get appSubtitle => 'Gestion d\'Entreprise';

  @override
  String get crm => 'CRM';

  @override
  String get sales => 'Ventes';

  @override
  String get invoicing => 'Facturation';

  @override
  String get inventory => 'Inventaire';

  @override
  String get contacts => 'Contacts';

  @override
  String get timesheets => 'Feuilles de temps';

  @override
  String get expenses => 'Dépenses';

  @override
  String get tasks => 'Tâches';

  @override
  String get messaging => 'Messagerie';

  @override
  String get other => 'Autre';

  @override
  String get settings => 'Paramètres';

  @override
  String get save => 'ENREGISTRER';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get edit => 'Modifier';

  @override
  String get add => 'Ajouter';

  @override
  String get search => 'Rechercher';

  @override
  String get refresh => 'Actualiser';

  @override
  String get back => 'Retour';

  @override
  String get next => 'Suivant';

  @override
  String get previous => 'Précédent';

  @override
  String get confirm => 'Confirmer';

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Non';

  @override
  String get signIn => 'Se connecter';

  @override
  String get signUp => 'S\'inscrire';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Mot de passe';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get fullName => 'Nom complet';

  @override
  String get company => 'Entreprise';

  @override
  String get rememberMe => 'Se souvenir de moi';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get welcomeBack => 'Bienvenue sur ODOOFF ! Connectez-vous pour continuer';

  @override
  String get welcomeMessage => 'Créez votre compte pour commencer';

  @override
  String get invalidCredentials => 'E-mail ou mot de passe invalide';

  @override
  String get registrationFailed => 'Échec de l\'inscription. Veuillez réessayer.';

  @override
  String get resetPassword => 'Réinitialiser le mot de passe';

  @override
  String get checkYourEmail => 'Vérifiez votre e-mail';

  @override
  String get backToSignIn => 'Retour à la connexion';

  @override
  String get customerRelationshipManagement => 'Gestion de la Relation Client';

  @override
  String get totalCustomers => 'Total Clients';

  @override
  String get activeOpportunities => 'Opportunités Actives';

  @override
  String get revenuePipeline => 'Pipeline de Revenus';

  @override
  String get conversionRate => 'Taux de Conversion';

  @override
  String get quickActions => 'Actions Rapides';

  @override
  String get customers => 'Clients';

  @override
  String get opportunities => 'Opportunités';

  @override
  String get manageCustomerRelationships => 'Gérer les relations clients';

  @override
  String get trackSalesOpportunities => 'Suivre les opportunités de vente';

  @override
  String get addCustomer => 'Ajouter un Client';

  @override
  String get editCustomer => 'Modifier le Client';

  @override
  String get customerName => 'Nom du Client';

  @override
  String get phone => 'Téléphone';

  @override
  String get address => 'Adresse';

  @override
  String get city => 'Ville';

  @override
  String get state => 'État/Province';

  @override
  String get country => 'Pays';

  @override
  String get zipCode => 'Code Postal';

  @override
  String get website => 'Site Web';

  @override
  String get industry => 'Secteur';

  @override
  String get customerType => 'Type de Client';

  @override
  String get status => 'Statut';

  @override
  String get active => 'Actif';

  @override
  String get inactive => 'Inactif';

  @override
  String get prospect => 'Prospect';

  @override
  String get individual => 'Particulier';

  @override
  String get basicInformation => 'Informations de Base';

  @override
  String get addressInformation => 'Informations d\'Adresse';

  @override
  String get additionalInformation => 'Informations Supplémentaires';

  @override
  String get activeCustomer => 'Client Actif';

  @override
  String get customerIsCurrentlyActive => 'Le client est actuellement actif';

  @override
  String get addOpportunity => 'Ajouter une Opportunité';

  @override
  String get editOpportunity => 'Modifier l\'Opportunité';

  @override
  String get opportunityDetails => 'Détails de l\'Opportunité';

  @override
  String get title => 'Titre';

  @override
  String get customer => 'Client';

  @override
  String get expectedRevenue => 'Revenus Attendus';

  @override
  String get probability => 'Probabilité';

  @override
  String get stage => 'Étape';

  @override
  String get salesPerson => 'Commercial';

  @override
  String get expectedCloseDate => 'Date de Clôture Prévue';

  @override
  String get description => 'Description';

  @override
  String get moreDetails => 'Plus de Détails';

  @override
  String get salesManagement => 'Gestion des Ventes';

  @override
  String get monthlySales => 'Ventes Mensuelles';

  @override
  String get activeOrders => 'Commandes Actives';

  @override
  String get pendingQuotes => 'Devis en Attente';

  @override
  String get products => 'Produits';

  @override
  String get quotations => 'Devis';

  @override
  String get orders => 'Commandes';

  @override
  String get createAndManageQuotations => 'Créer et gérer les devis';

  @override
  String get trackSalesOrders => 'Suivre les commandes de vente';

  @override
  String get manageProductCatalog => 'Gérer le catalogue de produits';

  @override
  String get addProduct => 'Ajouter un Produit';

  @override
  String get editProduct => 'Modifier le Produit';

  @override
  String get productName => 'Nom du Produit';

  @override
  String get sku => 'Référence';

  @override
  String get category => 'Catégorie';

  @override
  String get cost => 'Coût';

  @override
  String get salePrice => 'Prix de Vente';

  @override
  String get listPrice => 'Prix Catalogue';

  @override
  String get productType => 'Type de Produit';

  @override
  String get unitOfMeasure => 'Unité de Mesure';

  @override
  String get canBeSold => 'Peut être Vendu';

  @override
  String get canBePurchased => 'Peut être Acheté';

  @override
  String get pricing => 'Tarification';

  @override
  String get barcode => 'Code-barres';

  @override
  String get weight => 'Poids';

  @override
  String get productInformation => 'Informations Produit';

  @override
  String get onHand => 'En Stock';

  @override
  String get forecasted => 'Prévisionnel';

  @override
  String get incomingQty => 'Entrant';

  @override
  String get outgoingQty => 'Sortant';

  @override
  String get invoicingPolicy => 'Politique de Facturation';

  @override
  String get invoiceManagement => 'Gestion des Factures';

  @override
  String get totalInvoiced => 'Total Facturé';

  @override
  String get outstanding => 'En Attente';

  @override
  String get overdue => 'En Retard';

  @override
  String get paidThisMonth => 'Payé ce Mois';

  @override
  String get invoices => 'Factures';

  @override
  String get payments => 'Paiements';

  @override
  String get purchaseOrders => 'Bons de Commande';

  @override
  String get createAndManageInvoices => 'Créer et gérer les factures';

  @override
  String get trackPaymentStatus => 'Suivre le statut des paiements';

  @override
  String get managePurchaseOrders => 'Gérer les bons de commande';

  @override
  String get addInvoice => 'Ajouter une Facture';

  @override
  String get editInvoice => 'Modifier la Facture';

  @override
  String get invoiceNumber => 'Numéro de Facture';

  @override
  String get invoiceDate => 'Date de Facture';

  @override
  String get dueDate => 'Date d\'Échéance';

  @override
  String get paymentTerms => 'Conditions de Paiement';

  @override
  String get reference => 'Référence';

  @override
  String get invoiceLines => 'Lignes de Facture';

  @override
  String get addLine => 'Ajouter une Ligne';

  @override
  String get subtotal => 'Sous-total';

  @override
  String get tax => 'Taxe';

  @override
  String get total => 'Total';

  @override
  String get draft => 'Brouillon';

  @override
  String get posted => 'Validé';

  @override
  String get paid => 'Payé';

  @override
  String get cancelled => 'Annulé';

  @override
  String get inventoryLogisticsManagement => 'Gestion Inventaire et Logistique';

  @override
  String get totalProducts => 'Total Produits';

  @override
  String get lowStock => 'Stock Faible';

  @override
  String get pendingTransfers => 'Transferts en Attente';

  @override
  String get locations => 'Emplacements';

  @override
  String get viewAndManageStockLevels => 'Voir et gérer les niveaux de stock';

  @override
  String get manageWarehouseLocations => 'Gérer les emplacements d\'entrepôt';

  @override
  String get stockTransfersBetweenLocations => 'Transferts de stock entre emplacements';

  @override
  String get incomingStockReceipts => 'Réceptions de stock entrant';

  @override
  String get outgoingDeliveries => 'Livraisons sortantes';

  @override
  String get transfers => 'Transferts';

  @override
  String get receipts => 'Réceptions';

  @override
  String get deliveries => 'Livraisons';

  @override
  String get completeAddressBook => 'Carnet d\'adresses complet';

  @override
  String get workingTimeTracking => 'Suivi du temps de travail';

  @override
  String get addExpensesWithAttachments => 'Ajouter des dépenses avec pièces jointes';

  @override
  String get actionPlanManagement => 'Gestion du plan d\'action';

  @override
  String get odooMessages => 'Messages Odoo';

  @override
  String get additionalFeatures => 'Fonctionnalités Supplémentaires';

  @override
  String get name => 'Nom';

  @override
  String get date => 'Date';

  @override
  String get amount => 'Montant';

  @override
  String get quantity => 'Quantité';

  @override
  String get price => 'Prix';

  @override
  String get notes => 'Notes';

  @override
  String get created => 'Créé';

  @override
  String get updated => 'Mis à jour';

  @override
  String get noDataFound => 'Aucune donnée trouvée';

  @override
  String get loading => 'Chargement...';

  @override
  String get error => 'Erreur';

  @override
  String get success => 'Succès';

  @override
  String get failed => 'Échec';

  @override
  String get retry => 'Réessayer';

  @override
  String get pleaseEnterEmail => 'Veuillez saisir votre e-mail';

  @override
  String get pleaseEnterValidEmail => 'Veuillez saisir un e-mail valide';

  @override
  String get pleaseEnterPassword => 'Veuillez saisir votre mot de passe';

  @override
  String get pleaseEnterName => 'Veuillez saisir votre nom';

  @override
  String get pleaseSelectCustomer => 'Veuillez sélectionner un client';

  @override
  String get required => 'Requis';

  @override
  String get invalidNumber => 'Numéro invalide';

  @override
  String get profile => 'Profil';

  @override
  String get accountInformation => 'Informations du Compte';

  @override
  String get memberSince => 'Membre depuis';

  @override
  String get lastLogin => 'Dernière Connexion';

  @override
  String get helpSupport => 'Aide et Support';

  @override
  String get about => 'À propos';

  @override
  String get areYouSureSignOut => 'Êtes-vous sûr de vouloir vous déconnecter ?';

  @override
  String get language => 'Langue';

  @override
  String get english => 'English';

  @override
  String get french => 'Français';

  @override
  String get selectLanguage => 'Sélectionner la Langue';

  @override
  String get overview => 'Aperçu';
}