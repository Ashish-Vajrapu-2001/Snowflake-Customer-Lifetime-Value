# Customer Lifetime Value (CLV) Analytics
## Source System Metadata Catalog

---

## Document Control

| Attribute | Value |
|-----------|-------|
| Document ID | META-CLV-001 |
| Version | 1.0 |
| Created Date | November 2025 |
| Last Updated | November 2025 |
| Status | Draft / In Review / Approved |
| Data Steward | |
| Technical Owner | VP Data Engineering & Analytics |

---

## 1. Source System Registry

### 1.1 System Overview

| System ID | System Name | Platform | Business Domain | Data Steward | Technical Contact |
|-----------|-------------|----------|-----------------|--------------|-------------------|
| SRC-001 | Azure SQL ERP | Azure SQL Database | Orders, Inventory, Finance | Finance Team | DBA Admin |
| SRC-002 | Azure SQL CRM | Azure SQL Database | Customer Master, Support | CX Team | DBA Admin |
| SRC-003 | Azure SQL Marketing | Azure SQL Database | Campaign Management | Marketing Team | Marketing Ops |

### 1.2 System Connectivity

| System ID | Connection Type | Protocol | Extraction Method | Credentials Store |
|-----------|-----------------|----------|-------------------|-------------------|
| SRC-001 | Azure SQL | TDS/JDBC/ODBC | CDC (SQL Server CDC) | Azure Key Vault |
| SRC-002 | Azure SQL | TDS/JDBC/ODBC | CDC + Batch | Azure Key Vault |
| SRC-003 | Azure SQL | TDS/JDBC/ODBC | Batch Pull | Azure Key Vault |

---

## 2. Entity Catalog

### 2.1 Entity Summary for CLV

| Entity ID | Entity Name | Source System | Schema.Table | Record Count | CLV Relevance |
|-----------|-------------|---------------|--------------|--------------|---------------|
| ENT-001 | Customer | SRC-002 | CRM.Customers | ~10,000 | Identity, Lifespan |
| ENT-002 | Customer Registration | SRC-002 | CRM.CustomerRegistrationSource | ~10,000 | Acquisition Channel |
| ENT-003 | Order Header | SRC-001 | ERP.OE_ORDER_HEADERS_ALL | ~56,000 | Revenue, Frequency |
| ENT-004 | Order Line | SRC-001 | ERP.OE_ORDER_LINES_ALL | ~116,000 | Basket Analysis |
| ENT-005 | Address | SRC-001 | ERP.ADDRESSES | ~14,000 | Geography |
| ENT-006 | City Tier | SRC-001 | ERP.CITY_TIER_MASTER | ~100 | Geographic Tier |
| ENT-007 | Product | SRC-001 | ERP.MTL_SYSTEM_ITEMS_B | ~2,000 | Category Affinity |
| ENT-008 | Category | SRC-001 | ERP.CATEGORIES | ~100 | Product Hierarchy |
| ENT-009 | Brand | SRC-001 | ERP.BRANDS | ~100 | Brand Affinity |
| ENT-010 | Campaign | SRC-003 | MARKETING.MARKETING_CAMPAIGNS | ~50 | Acquisition Cost |
| ENT-011 | Incident | SRC-002 | CRM.INCIDENTS | ~8,000 | Support Analytics |
| ENT-012 | Interaction | SRC-002 | CRM.INTERACTIONS | ~25,000 | Engagement |
| ENT-013 | Survey | SRC-002 | CRM.SURVEYS | ~11,000 | NPS Score |

---

## 3. Tables Metadata

### 3.1 CRM Tables

#### 3.1.1 CRM.Customers (ENT-001)

##### Entity Description
| Attribute | Value |
|-----------|-------|
| **Entity Name** | Customers |
| **Business Name** | Customer Master |
| **Description** | Golden record for customer identity and profile. Single source of truth for customer data across the enterprise. |
| **Source System** | SRC-002 (Azure SQL CRM) |
| **Schema** | CRM |
| **Owner** | Customer Experience Team |
| **Data Steward** | |
| **Update Frequency** | Real-time (CDC) |
| **Retention Period** | 7 years post-last activity |

##### Column Specifications

| Column Name | Data Type | Length | Nullable | Default | PK | FK | Business Definition |
|-------------|-----------|--------|----------|---------|----|----|---------------------|
| CUSTOMER_ID | BIGINT | - | No | Identity | ✓ | - | Unique system-generated customer identifier |
| EMAIL | NVARCHAR | 255 | No | - | - | - | Primary email address (unique, used for login) |
| PHONE | NVARCHAR | 20 | Yes | - | - | - | Primary contact phone with country code |
| FIRST_NAME | NVARCHAR | 100 | No | - | - | - | Customer's given name |
| LAST_NAME | NVARCHAR | 100 | Yes | - | - | - | Customer's family name |
| GENDER | NVARCHAR | 10 | Yes | - | - | - | Customer's gender identity |
| DATE_OF_BIRTH | DATE | - | Yes | - | - | - | Customer's birth date |
| REGISTRATION_DATE | DATETIME2 | - | No | - | - | - | Account creation timestamp |
| CUSTOMER_TYPE | NVARCHAR | 20 | No | 'Regular' | - | - | Customer classification (VIP/Regular/New) |
| STATUS | NVARCHAR | 20 | No | 'Active' | - | - | Account status (Active/Inactive/Churned/Blocked) |
| EMAIL_VERIFIED | BIT | - | No | 0 | - | - | Email verification flag |
| PHONE_VERIFIED | BIT | - | No | 0 | - | - | Phone verification flag |
| MARKETING_OPT_IN | BIT | - | No | 1 | - | - | Marketing consent flag |
| PREFERRED_LANGUAGE | NVARCHAR | 20 | No | 'English' | - | - | Communication language preference |
| CREATED_BY | NVARCHAR | 50 | No | 'SYSTEM' | - | - | Record creator |
| CREATED_DATE | DATETIME2 | - | No | GETDATE() | - | - | Record creation timestamp |
| LAST_UPDATE_DATE | DATETIME2 | - | No | GETDATE() | - | - | Last modification timestamp |
| LAST_MODIFIED_DATE | DATETIME2 | - | No | GETDATE() | - | - | Last modification timestamp (audit trail) |

##### Valid Values

| Column | Valid Values | Description |
|--------|--------------|-------------|
| GENDER | Male, Female, Other, Prefer not to say | Gender options |
| CUSTOMER_TYPE | VIP, Regular, New | Customer tier classification |
| STATUS | Active, Inactive, Churned, Blocked | Account lifecycle status |

##### CLV Usage

| Column | CLV Component | Usage |
|--------|---------------|-------|
| CUSTOMER_ID | All | Primary key for joining |
| REGISTRATION_DATE | Lifespan | Customer tenure start date |
| STATUS | Lifespan | Determines if customer is active |
| CUSTOMER_TYPE | Segment | Input for segmentation |

##### Sample Data

| CUSTOMER_ID | EMAIL | FIRST_NAME | REGISTRATION_DATE | CUSTOMER_TYPE | STATUS |
|-------------|-------|------------|-------------------|---------------|--------|
| 1001 | aarav.sharma@gmail.com | Aarav | 2023-03-15 10:30:00 | Regular | Active |
| 1002 | priya.patel@yahoo.com | Priya | 2023-01-22 14:45:00 | VIP | Active |
| 1003 | rahul.kumar@outlook.com | Rahul | 2024-06-10 09:15:00 | New | Active |

---

#### 3.1.2 CRM.CustomerRegistrationSource (ENT-002)

##### Entity Description
| Attribute | Value |
|-----------|-------|
| **Entity Name** | CustomerRegistrationSource |
| **Business Name** | Acquisition Attribution |
| **Description** | Captures the acquisition channel and campaign attribution for each customer at the time of registration |
| **Source System** | SRC-002 (Azure SQL CRM) |
| **Schema** | CRM |
| **Owner** | Marketing Team |
| **Update Frequency** | At registration (one-time) |

##### Column Specifications

| Column Name | Data Type | Length | Nullable | Default | PK | FK | Business Definition |
|-------------|-----------|--------|----------|---------|----|----|---------------------|
| REGISTRATION_SOURCE_ID | BIGINT | - | No | Identity | ✓ | - | Unique record identifier |
| CUSTOMER_ID | BIGINT | - | No | - | - | ✓ → CRM.Customers | Link to customer master |
| CHANNEL | NVARCHAR | 50 | No | - | - | - | Acquisition channel |
| CAMPAIGN_ID | INT | - | Yes | - | - | ✓ → MARKETING.MARKETING_CAMPAIGNS | Associated marketing campaign |
| UTM_SOURCE | NVARCHAR | 100 | Yes | - | - | - | UTM source parameter |
| UTM_MEDIUM | NVARCHAR | 100 | Yes | - | - | - | UTM medium parameter |
| UTM_CAMPAIGN | NVARCHAR | 200 | Yes | - | - | - | UTM campaign parameter |
| UTM_CONTENT | NVARCHAR | 200 | Yes | - | - | - | UTM content parameter |
| REFERRER_URL | NVARCHAR | 500 | Yes | - | - | - | HTTP referrer URL |
| LANDING_PAGE | NVARCHAR | 500 | Yes | - | - | - | First page visited |
| DEVICE_TYPE | NVARCHAR | 20 | Yes | - | - | - | Registration device |
| REGISTRATION_DATE | DATETIME2 | - | No | - | - | - | Registration timestamp |
| CREATED_DATE | DATETIME2 | - | No | GETDATE() | - | - | Record creation timestamp |
| LAST_MODIFIED_DATE | DATETIME2 | - | No | GETDATE() | - | - | Last modification timestamp (audit trail) |

##### Valid Values

| Column | Valid Values | Description |
|--------|--------------|-------------|
| CHANNEL | Paid Social, Organic, Affiliate, Direct, Email, Search, Display | Acquisition channel |
| DEVICE_TYPE | Mobile, Desktop, Tablet, App-Android, App-iOS | Device used for registration |

##### CLV Usage

| Column | CLV Component | Usage |
|--------|---------------|-------|
| CHANNEL | Acquisition Channel Dimension | Primary dimension for channel analysis |
| CAMPAIGN_ID | CAC | Links to campaign for cost attribution |

---

#### 3.1.3 CRM.INCIDENTS (ENT-011)

##### Entity Description
| Attribute | Value |
|-----------|-------|
| **Entity Name** | INCIDENTS |
| **Business Name** | Support Incident |
| **Description** | Customer support tickets. Used for support analytics and customer service metrics. |
| **Source System** | SRC-002 (Azure SQL CRM) |
| **Schema** | CRM |
| **Update Frequency** | Real-time (CDC) |

##### Column Specifications

| Column Name | Data Type | Nullable | Default | PK | FK | Business Definition |
|-------------|-----------|----------|---------|----|----|---------------------|
| INCIDENT_ID | BIGINT | No | Identity | ✓ | - | Unique incident ID |
| INCIDENT_NUMBER | NVARCHAR(50) | No | - | - | - | Ticket number |
| CUSTOMER_ID | BIGINT | No | - | - | ✓ → CRM.Customers | Customer |
| ORDER_ID | BIGINT | Yes | - | - | ✓ → ERP.OE_ORDER_HEADERS_ALL | Related order |
| SUBJECT | NVARCHAR(255) | No | - | - | - | Subject |
| DESCRIPTION | NVARCHAR(MAX) | Yes | - | - | - | Description |
| CATEGORY | NVARCHAR(50) | No | - | - | - | Issue category |
| SUB_CATEGORY | NVARCHAR(50) | Yes | - | - | - | Sub-category |
| PRIORITY | NVARCHAR(10) | No | 'Medium' | - | - | Priority |
| STATUS | NVARCHAR(30) | No | 'New' | - | - | Status |
| CHANNEL | NVARCHAR(20) | No | 'Email' | - | - | Contact channel |
| ASSIGNED_TO | NVARCHAR(100) | Yes | - | - | - | Assigned agent |
| FIRST_RESPONSE_DATE | DATETIME2 | Yes | - | - | - | First response |
| RESOLVED_DATE | DATETIME2 | Yes | - | - | - | Resolution date |
| CLOSED_DATE | DATETIME2 | Yes | - | - | - | Closure date |
| LAST_MODIFIED_DATE | DATETIME2 | No | GETDATE() | - | - | Last modification timestamp (audit trail) |

##### Valid Values

| Column | Valid Values |
|--------|--------------|
| CATEGORY | Delivery, Return, Product, Payment, Refund, Account, Other |
| PRIORITY | Low, Medium, High, Urgent |
| STATUS | New, Assigned, In Progress, Pending Customer, Resolved, Closed, Reopened |
| CHANNEL | Email, Phone, Chat, Social Media, App, Web |

##### CLV Usage

| Column | CLV Component | Usage |
|--------|---------------|-------|
| Incident frequency | Support Metric | Track support volume per customer |

---

#### 3.1.4 CRM.INTERACTIONS (ENT-012)

##### Entity Description
| Attribute | Value |
|-----------|-------|
| **Entity Name** | INTERACTIONS |
| **Business Name** | Customer Interaction |
| **Description** | Individual customer touchpoints across channels. Captures engagement for CLV scoring. |
| **Source System** | SRC-002 (Azure SQL CRM) |
| **Schema** | CRM |
| **Update Frequency** | Real-time (CDC) |

##### Column Specifications

| Column Name | Data Type | Nullable | Default | PK | FK | Business Definition |
|-------------|-----------|----------|---------|----|----|---------------------|
| INTERACTION_ID | BIGINT | No | Identity | ✓ | - | Unique interaction ID |
| INCIDENT_ID | BIGINT | Yes | - | - | ✓ → CRM.INCIDENTS | Parent incident |
| CUSTOMER_ID | BIGINT | No | - | - | ✓ → CRM.Customers | Customer |
| CHANNEL | NVARCHAR(20) | No | - | - | - | Communication channel |
| DIRECTION | NVARCHAR(10) | No | - | - | - | Inbound/Outbound |
| INTERACTION_TYPE | NVARCHAR(50) | No | - | - | - | Interaction type |
| SUBJECT | NVARCHAR(255) | Yes | - | - | - | Subject |
| CONTENT_SUMMARY | NVARCHAR(MAX) | Yes | - | - | - | Summary |
| SENTIMENT | NVARCHAR(20) | Yes | - | - | - | Detected sentiment |
| AGENT_ID | NVARCHAR(50) | Yes | - | - | - | Agent ID |
| DURATION_SECONDS | INT | Yes | - | - | - | Duration |
| INTERACTION_DATE | DATETIME2 | No | - | - | - | Interaction date |
| LAST_MODIFIED_DATE | DATETIME2 | No | GETDATE() | - | - | Last modification timestamp (audit trail) |

##### Valid Values

| Column | Valid Values |
|--------|--------------|
| CHANNEL | Email, Phone, Chat, Social Media, SMS, App Push, WhatsApp |
| DIRECTION | Inbound, Outbound |
| INTERACTION_TYPE | Query, Complaint, Feedback, Request, Follow-up, Resolution, Notification |
| SENTIMENT | Positive, Neutral, Negative, Mixed |

##### CLV Usage

| Column | CLV Component | Usage |
|--------|---------------|-------|
| SENTIMENT | Customer Experience | Track interaction sentiment |

---

#### 3.1.5 CRM.SURVEYS (ENT-013)

##### Entity Description
| Attribute | Value |
|-----------|-------|
| **Entity Name** | SURVEYS |
| **Business Name** | Customer Survey |
| **Description** | Customer feedback surveys (NPS, CSAT). Used for customer satisfaction tracking and reporting. |
| **Source System** | SRC-002 (Azure SQL CRM) |
| **Schema** | CRM |
| **Update Frequency** | Real-time |

##### Column Specifications

| Column Name | Data Type | Nullable | Default | PK | FK | Business Definition |
|-------------|-----------|----------|---------|----|----|---------------------|
| SURVEY_ID | BIGINT | No | Identity | ✓ | - | Unique survey ID |
| CUSTOMER_ID | BIGINT | No | - | - | ✓ → CRM.Customers | Customer |
| ORDER_ID | BIGINT | Yes | - | - | ✓ → ERP.OE_ORDER_HEADERS_ALL | Related order |
| INCIDENT_ID | BIGINT | Yes | - | - | ✓ → CRM.INCIDENTS | Related incident |
| SURVEY_TYPE | NVARCHAR(20) | No | - | - | - | Survey type |
| NPS_SCORE | TINYINT | Yes | - | - | - | NPS (0-10) |
| CSAT_SCORE | TINYINT | Yes | - | - | - | CSAT (1-5) |
| NPS_CATEGORY | NVARCHAR(20) | Yes | - | - | - | NPS category |
| FEEDBACK_TEXT | NVARCHAR(MAX) | Yes | - | - | - | Feedback text |
| FEEDBACK_CATEGORY | NVARCHAR(50) | Yes | - | - | - | Feedback category |
| RESPONSE_DATE | DATETIME2 | No | - | - | - | Response date |
| SURVEY_SENT_DATE | DATETIME2 | No | - | - | - | Sent date |
| LAST_MODIFIED_DATE | DATETIME2 | No | GETDATE() | - | - | Last modification timestamp (audit trail) |

##### Valid Values

| Column | Valid Values |
|--------|--------------|
| SURVEY_TYPE | NPS, CSAT, CES, Post-Delivery, Post-Support |
| NPS_CATEGORY | Promoter (9-10), Passive (7-8), Detractor (0-6) |

##### CLV Usage

| Column | CLV Component | Usage |
|--------|---------------|-------|
| NPS_SCORE | Customer Satisfaction | Track loyalty metric |
| NPS_CATEGORY | Segmentation | Promoter/Passive/Detractor |

---

### 3.2 ERP Tables

#### 3.2.1 ERP.OE_ORDER_HEADERS_ALL (ENT-003)

##### Entity Description
| Attribute | Value |
|-----------|-------|
| **Entity Name** | OE_ORDER_HEADERS_ALL |
| **Business Name** | Order Header |
| **Description** | Master record for customer orders containing header-level information including totals, payment, shipping, and order lifecycle status. Central transaction entity for CLV revenue calculations. |
| **Source System** | SRC-001 (Azure SQL ERP) |
| **Schema** | ERP |
| **Owner** | Order Management Team |
| **Update Frequency** | Real-time (CDC) |
| **Retention Period** | 7 years |

##### Column Specifications

| Column Name | Data Type | Nullable | Default | PK | FK | Business Definition |
|-------------|-----------|----------|---------|----|----|---------------------|
| ORDER_ID | BIGINT | No | Identity | ✓ | - | Unique order identifier |
| ORDER_NUMBER | NVARCHAR(50) | No | - | - | - | Business order reference |
| CUSTOMER_ID | BIGINT | No | - | - | ✓ → CRM.Customers | Customer reference |
| ORDER_DATE | DATETIME2 | No | - | - | - | Order placement date |
| ORDER_STATUS | NVARCHAR(30) | No | 'Booked' | - | - | Order lifecycle status |
| PAYMENT_METHOD | NVARCHAR(30) | No | - | - | - | Payment instrument |
| PAYMENT_STATUS | NVARCHAR(20) | No | 'Pending' | - | - | Payment state |
| SUBTOTAL_AMOUNT | DECIMAL(15,2) | No | - | - | - | Pre-discount total |
| DISCOUNT_AMOUNT | DECIMAL(15,2) | No | 0 | - | - | Discount applied |
| TAX_AMOUNT | DECIMAL(15,2) | No | 0 | - | - | Tax amount |
| SHIPPING_AMOUNT | DECIMAL(15,2) | No | 0 | - | - | Shipping charges |
| TOTAL_AMOUNT | DECIMAL(15,2) | No | - | - | - | Final order total |
| CURRENCY_CODE | NVARCHAR(3) | No | 'INR' | - | - | ISO currency code |
| SHIPPING_ADDRESS_ID | BIGINT | No | - | - | ✓ → ERP.ADDRESSES | Delivery address |
| BILLING_ADDRESS_ID | BIGINT | Yes | - | - | ✓ → ERP.ADDRESSES | Billing address |
| PROMISED_DATE | DATE | Yes | - | - | - | Promised delivery |
| SHIPPED_DATE | DATETIME2 | Yes | - | - | - | Shipment date |
| DELIVERED_DATE | DATETIME2 | Yes | - | - | - | Delivery date |
| CANCELLATION_REASON | NVARCHAR(200) | Yes | - | - | - | Cancel reason |
| ORDER_SOURCE | NVARCHAR(20) | No | 'Web' | - | - | Order channel |
| ORG_ID | INT | No | 101 | - | - | Organization ID |
| CREATED_BY | NVARCHAR(50) | No | 'ECOM_API' | - | - | Creator |
| CREATED_DATE | DATETIME2 | No | GETDATE() | - | - | Creation timestamp |
| LAST_UPDATE_DATE | DATETIME2 | No | GETDATE() | - | - | Update timestamp |
| LAST_MODIFIED_DATE | DATETIME2 | No | GETDATE() | - | - | Last modification timestamp (audit trail) |

##### Valid Values

| Column | Valid Values |
|--------|--------------|
| ORDER_STATUS | Draft, Booked, Processing, Shipped, Delivered, Cancelled, Returned, Refunded |
| PAYMENT_METHOD | UPI, Credit Card, Debit Card, Net Banking, COD, Wallet, EMI |
| PAYMENT_STATUS | Pending, Authorized, Captured, Failed, Refunded |
| ORDER_SOURCE | Web, Mobile-App, M-Site, Call-Center |

##### CLV Usage

| Column | CLV Component | Usage |
|--------|---------------|-------|
| TOTAL_AMOUNT | Monetary, AOV | Primary revenue metric |
| ORDER_DATE | Frequency, Recency | Purchase timing |
| ORDER_STATUS | Revenue Validation | Only 'Delivered' counts |

##### Sample Data

| ORDER_ID | ORDER_NUMBER | CUSTOMER_ID | ORDER_DATE | ORDER_STATUS | TOTAL_AMOUNT |
|----------|--------------|-------------|------------|--------------|--------------|
| 5001 | ORD-2024-0001 | 1001 | 2024-01-15 | Delivered | 4599.00 |
| 5002 | ORD-2024-0002 | 1002 | 2024-01-16 | Delivered | 12500.00 |

---

#### 3.2.2 ERP.OE_ORDER_LINES_ALL (ENT-004)

##### Entity Description
| Attribute | Value |
|-----------|-------|
| **Entity Name** | OE_ORDER_LINES_ALL |
| **Business Name** | Order Line Item |
| **Description** | Individual line items within an order with product details, quantities, and pricing. Essential for basket analysis. |
| **Source System** | SRC-001 (Azure SQL ERP) |
| **Schema** | ERP |
| **Update Frequency** | Real-time (CDC) |
| **Retention Period** | 7 years |

##### Column Specifications

| Column Name | Data Type | Nullable | Default | PK | FK | Business Definition |
|-------------|-----------|----------|---------|----|----|---------------------|
| LINE_ID | BIGINT | No | Identity | ✓ | - | Unique line identifier |
| ORDER_ID | BIGINT | No | - | - | ✓ → ERP.OE_ORDER_HEADERS_ALL | Parent order |
| LINE_NUMBER | INT | No | - | - | - | Line sequence |
| PRODUCT_ID | BIGINT | No | - | - | ✓ → ERP.MTL_SYSTEM_ITEMS_B | Product reference |
| SKU | NVARCHAR(50) | No | - | - | - | Stock Keeping Unit |
| PRODUCT_NAME | NVARCHAR(255) | No | - | - | - | Product name |
| QUANTITY | INT | No | 1 | - | - | Units ordered |
| UNIT_PRICE | DECIMAL(15,2) | No | - | - | - | Price per unit |
| DISCOUNT_PERCENT | DECIMAL(5,2) | No | 0 | - | - | Discount % |
| DISCOUNT_AMOUNT | DECIMAL(15,2) | No | 0 | - | - | Discount value |
| TAX_AMOUNT | DECIMAL(15,2) | No | 0 | - | - | Tax amount |
| LINE_AMOUNT | DECIMAL(15,2) | No | - | - | - | Line total |
| LINE_STATUS | NVARCHAR(30) | No | 'Booked' | - | - | Line status |
| WAREHOUSE_ID | INT | Yes | - | - | - | Warehouse |
| PROMISED_DATE | DATE | Yes | - | - | - | Promised date |
| SHIPPED_DATE | DATETIME2 | Yes | - | - | - | Ship date |
| DELIVERED_DATE | DATETIME2 | Yes | - | - | - | Delivery date |
| RETURN_REASON | NVARCHAR(200) | Yes | - | - | - | Return reason |
| CREATED_DATE | DATETIME2 | No | GETDATE() | - | - | Created |
| LAST_UPDATE_DATE | DATETIME2 | No | GETDATE() | - | - | Updated |
| LAST_MODIFIED_DATE | DATETIME2 | No | GETDATE() | - | - | Last modification timestamp (audit trail) |

##### Valid Values

| Column | Valid Values |
|--------|--------------|
| LINE_STATUS | Booked, Processing, Shipped, Delivered, Cancelled, Returned |

##### CLV Usage

| Column | CLV Component | Usage |
|--------|---------------|-------|
| PRODUCT_ID | Category Affinity | Product-level analysis |
| LINE_AMOUNT | Product Revenue | Revenue by product |
| QUANTITY | Basket Size | Units per transaction |

---

#### 3.2.3 ERP.ADDRESSES (ENT-005)

##### Entity Description
| Attribute | Value |
|-----------|-------|
| **Entity Name** | ADDRESSES |
| **Business Name** | Customer Address |
| **Description** | Customer shipping and billing addresses for order fulfillment and geographic CLV segmentation. |
| **Source System** | SRC-001 (Azure SQL ERP) |
| **Schema** | ERP |
| **Update Frequency** | Event-driven |

##### Column Specifications

| Column Name | Data Type | Nullable | Default | PK | FK | Business Definition |
|-------------|-----------|----------|---------|----|----|---------------------|
| ADDRESS_ID | BIGINT | No | Identity | ✓ | - | Unique address ID |
| CUSTOMER_ID | BIGINT | No | - | - | ✓ → CRM.Customers | Customer owner |
| ADDRESS_TYPE | NVARCHAR(20) | No | 'Shipping' | - | - | Address purpose |
| ADDRESS_NAME | NVARCHAR(100) | Yes | - | - | - | Friendly name |
| STREET_LINE_1 | NVARCHAR(255) | No | - | - | - | Street address |
| STREET_LINE_2 | NVARCHAR(255) | Yes | - | - | - | Address line 2 |
| LANDMARK | NVARCHAR(255) | Yes | - | - | - | Nearby landmark |
| CITY | NVARCHAR(100) | No | - | - | - | City |
| STATE | NVARCHAR(100) | No | - | - | - | State |
| PINCODE | NVARCHAR(10) | No | - | - | - | Postal code |
| COUNTRY | NVARCHAR(50) | No | 'India' | - | - | Country |
| PHONE | NVARCHAR(20) | Yes | - | - | - | Contact phone |
| IS_DEFAULT | BIT | No | 0 | - | - | Default flag |
| IS_ACTIVE | BIT | No | 1 | - | - | Active flag |
| LAST_MODIFIED_DATE | DATETIME2 | No | GETDATE() | - | - | Last modification timestamp (audit trail) |

##### Valid Values

| Column | Valid Values |
|--------|--------------|
| ADDRESS_TYPE | Shipping, Billing, Both |

##### CLV Usage

| Column | CLV Component | Usage |
|--------|---------------|-------|
| CITY, STATE | Geographic Dimension | Joins to ERP.CITY_TIER_MASTER |

---

#### 3.2.4 ERP.CITY_TIER_MASTER (ENT-006)

##### Entity Description
| Attribute | Value |
|-----------|-------|
| **Entity Name** | CITY_TIER_MASTER |
| **Business Name** | City Tier Classification |
| **Description** | Reference table classifying cities into tiers (1/2/3) for geographic CLV segmentation. |
| **Source System** | SRC-001 (Azure SQL ERP) |
| **Schema** | ERP |
| **Update Frequency** | Quarterly |

##### Column Specifications

| Column Name | Data Type | Nullable | Default | PK | FK | Business Definition |
|-------------|-----------|----------|---------|----|----|---------------------|
| CITY | NVARCHAR(100) | No | - | ✓ | - | City (composite PK) |
| STATE | NVARCHAR(100) | No | - | ✓ | - | State (composite PK) |
| TIER | TINYINT | No | - | - | - | City tier (1,2,3) |
| REGION | NVARCHAR(50) | No | - | - | - | Geographic region |
| IS_METRO | BIT | No | 0 | - | - | Metro flag |
| CREATED_DATE | DATETIME2 | No | GETDATE() | - | - | Created |
| LAST_MODIFIED_DATE | DATETIME2 | No | GETDATE() | - | - | Last modification timestamp (audit trail) |

##### Valid Values

| Column | Valid Values |
|--------|--------------|
| TIER | 1 (Metro), 2 (Large), 3 (Small) |
| REGION | North, South, East, West, Central |

##### CLV Usage

| Column | CLV Component | Usage |
|--------|---------------|-------|
| TIER | CLV Segmentation | Tier-based analysis |

---

#### 3.2.5 ERP.MTL_SYSTEM_ITEMS_B (ENT-007)

##### Entity Description
| Attribute | Value |
|-----------|-------|
| **Entity Name** | MTL_SYSTEM_ITEMS_B |
| **Business Name** | Product Master |
| **Description** | Master catalog of products with pricing and categorization. Core entity for product affinity in CLV. |
| **Source System** | SRC-001 (Azure SQL ERP) |
| **Schema** | ERP |
| **Update Frequency** | Daily batch |

##### Column Specifications

| Column Name | Data Type | Nullable | Default | PK | FK | Business Definition |
|-------------|-----------|----------|---------|----|----|---------------------|
| INVENTORY_ITEM_ID | BIGINT | No | Identity | ✓ | - | Unique product ID |
| SKU | NVARCHAR(50) | No | - | - | - | Stock Keeping Unit |
| ITEM_NAME | NVARCHAR(255) | No | - | - | - | Product name |
| DESCRIPTION | NVARCHAR(MAX) | Yes | - | - | - | Description |
| CATEGORY_ID | INT | No | - | - | ✓ → ERP.CATEGORIES | Category |
| BRAND_ID | INT | No | - | - | ✓ → ERP.BRANDS | Brand |
| UNIT_OF_MEASURE | NVARCHAR(10) | No | 'EA' | - | - | UOM |
| LIST_PRICE | DECIMAL(15,2) | No | - | - | - | List price |
| COST | DECIMAL(15,2) | No | - | - | - | Product cost |
| MRP | DECIMAL(15,2) | No | - | - | - | MRP |
| STATUS | NVARCHAR(20) | No | 'Active' | - | - | Status |
| LAST_MODIFIED_DATE | DATETIME2 | No | GETDATE() | - | - | Last modification timestamp (audit trail) |

##### Valid Values

| Column | Valid Values |
|--------|--------------|
| STATUS | Active, Inactive, Discontinued |

##### CLV Usage

| Column | CLV Component | Usage |
|--------|---------------|-------|
| CATEGORY_ID | Category Affinity | Product preferences |
| BRAND_ID | Brand Affinity | Brand preferences |

---

#### 3.2.6 ERP.CATEGORIES (ENT-008)

##### Entity Description
| Attribute | Value |
|-----------|-------|
| **Entity Name** | CATEGORIES |
| **Business Name** | Product Category |
| **Description** | Hierarchical product category structure (3 levels) for category affinity analysis. |
| **Source System** | SRC-001 (Azure SQL ERP) |
| **Schema** | ERP |

##### Column Specifications

| Column Name | Data Type | Nullable | Default | PK | FK | Business Definition |
|-------------|-----------|----------|---------|----|----|---------------------|
| CATEGORY_ID | INT | No | Identity | ✓ | - | Unique category ID |
| CATEGORY_NAME | NVARCHAR(100) | No | - | - | - | Category name |
| CATEGORY_CODE | NVARCHAR(50) | No | - | - | - | Category code |
| PARENT_CATEGORY_ID | INT | Yes | - | - | ✓ → ERP.CATEGORIES | Parent category |
| LEVEL | TINYINT | No | - | - | - | Hierarchy level |
| DISPLAY_ORDER | INT | No | 0 | - | - | Sort order |
| IS_ACTIVE | BIT | No | 1 | - | - | Active flag |
| LAST_MODIFIED_DATE | DATETIME2 | No | GETDATE() | - | - | Last modification timestamp (audit trail) |

##### Valid Values

| Column | Valid Values |
|--------|--------------|
| LEVEL | 1 (Root), 2 (Sub), 3 (Leaf) |

---

#### 3.2.7 ERP.BRANDS (ENT-009)

##### Entity Description
| Attribute | Value |
|-----------|-------|
| **Entity Name** | BRANDS |
| **Business Name** | Brand Master |
| **Description** | Master list of brands with tier classification for brand affinity and premium/value segmentation. |
| **Source System** | SRC-001 (Azure SQL ERP) |
| **Schema** | ERP |

##### Column Specifications

| Column Name | Data Type | Nullable | Default | PK | FK | Business Definition |
|-------------|-----------|----------|---------|----|----|---------------------|
| BRAND_ID | INT | No | Identity | ✓ | - | Unique brand ID |
| BRAND_NAME | NVARCHAR(100) | No | - | - | - | Brand name |
| BRAND_CODE | NVARCHAR(50) | No | - | - | - | Brand code |
| BRAND_TIER | NVARCHAR(20) | No | - | - | - | Brand tier |
| ORIGIN_COUNTRY | NVARCHAR(50) | Yes | - | - | - | Origin country |
| IS_ACTIVE | BIT | No | 1 | - | - | Active flag |
| LAST_MODIFIED_DATE | DATETIME2 | No | GETDATE() | - | - | Last modification timestamp (audit trail) |

##### Valid Values

| Column | Valid Values |
|--------|--------------|
| BRAND_TIER | Premium, Mid-Range, Value, Luxury |

##### CLV Usage

| Column | CLV Component | Usage |
|--------|---------------|-------|
| BRAND_TIER | Customer Segmentation | Premium vs value customers |

---

### 3.3 Marketing Tables

#### 3.3.1 MARKETING.MARKETING_CAMPAIGNS (ENT-010)

##### Entity Description
| Attribute | Value |
|-----------|-------|
| **Entity Name** | MARKETING_CAMPAIGNS |
| **Business Name** | Marketing Campaign |
| **Description** | Campaign master with spend and acquisition metrics. Essential for CAC calculation in CLV. |
| **Source System** | SRC-003 (Azure SQL Marketing) |
| **Schema** | MARKETING |
| **Update Frequency** | Daily batch |

##### Column Specifications

| Column Name | Data Type | Nullable | Default | PK | FK | Business Definition |
|-------------|-----------|----------|---------|----|----|---------------------|
| CAMPAIGN_ID | INT | No | Identity | ✓ | - | Unique campaign ID |
| CAMPAIGN_NAME | NVARCHAR(200) | No | - | - | - | Campaign name |
| CAMPAIGN_CODE | NVARCHAR(50) | No | - | - | - | Campaign code |
| CHANNEL | NVARCHAR(50) | No | - | - | - | Marketing channel |
| SUB_CHANNEL | NVARCHAR(50) | Yes | - | - | - | Sub-channel |
| START_DATE | DATE | No | - | - | - | Start date |
| END_DATE | DATE | Yes | - | - | - | End date |
| TOTAL_SPEND | DECIMAL(15,2) | No | 0 | - | - | Total spend |
| CUSTOMERS_ACQUIRED | INT | No | 0 | - | - | Customers acquired |
| STATUS | NVARCHAR(20) | No | 'Active' | - | - | Status |
| LAST_MODIFIED_DATE | DATETIME2 | No | GETDATE() | - | - | Last modification timestamp (audit trail) |

##### Valid Values

| Column | Valid Values |
|--------|--------------|
| CHANNEL | Paid Social, Organic, Affiliate, Direct, Email, Search, Display |
| STATUS | Active, Completed, Paused, Cancelled |

##### CLV Usage

| Column | CLV Component | Usage |
|--------|---------------|-------|
| TOTAL_SPEND / CUSTOMERS_ACQUIRED | CAC | Customer Acquisition Cost |

---

## 4. Data Relationships

### 4.1 Entity Relationship Diagram (Textual)

```
                                MARKETING.MARKETING_CAMPAIGNS
                                              │
                                              │ CAMPAIGN_ID
                                              ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              CRM SCHEMA (Customer Domain)                        │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│    CRM.Customers (Golden Master)                                                │
│         │                                                                        │
│         ├──────────► CRM.CustomerRegistrationSource (1:1)                       │
│         │                                                                        │
│         ├──────────► CRM.INCIDENTS (1:N)                                        │
│         │                   │                                                    │
│         │                   └──────► CRM.INTERACTIONS (1:N)                     │
│         │                                                                        │
│         └──────────► CRM.SURVEYS (1:N)                                          │
│                                                                                  │
└───────────────────────────────────┬─────────────────────────────────────────────┘
                                    │
                                    │ CUSTOMER_ID
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              ERP SCHEMA (Transaction Domain)                     │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│  ERP.ADDRESSES ◄──────── ERP.OE_ORDER_HEADERS_ALL ──────────► CRM.Customers     │
│         │                          │                                             │
│         │                          │ ORDER_ID                                    │
│         ▼                          ▼                                             │
│  ERP.CITY_TIER_MASTER       ERP.OE_ORDER_LINES_ALL                              │
│                                    │                                             │
│                                    │ PRODUCT_ID                                  │
│                                    ▼                                             │
│                          ERP.MTL_SYSTEM_ITEMS_B                                 │
│                                    │                                             │
│                       ┌────────────┴────────────┐                               │
│                       ▼                         ▼                               │
│               ERP.CATEGORIES              ERP.BRANDS                            │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### 4.2 Relationship Cardinality

| Parent Entity | Child Entity | Relationship | Cardinality | Join Key |
|---------------|--------------|--------------|-------------|----------|
| CRM.Customers | CRM.CustomerRegistrationSource | Has | 1:1 | CUSTOMER_ID |
| CRM.Customers | ERP.ADDRESSES | Has | 1:N | CUSTOMER_ID |
| CRM.Customers | ERP.OE_ORDER_HEADERS_ALL | Places | 1:N | CUSTOMER_ID |
| CRM.Customers | CRM.INCIDENTS | Raises | 1:N | CUSTOMER_ID |
| CRM.Customers | CRM.SURVEYS | Responds | 1:N | CUSTOMER_ID |
| ERP.OE_ORDER_HEADERS_ALL | ERP.OE_ORDER_LINES_ALL | Contains | 1:N | ORDER_ID |
| ERP.OE_ORDER_HEADERS_ALL | CRM.INCIDENTS | Related To | 1:N | ORDER_ID |
| ERP.OE_ORDER_HEADERS_ALL | CRM.SURVEYS | Triggers | 1:N | ORDER_ID |
| CRM.INCIDENTS | CRM.INTERACTIONS | Has | 1:N | INCIDENT_ID |
| ERP.MTL_SYSTEM_ITEMS_B | ERP.OE_ORDER_LINES_ALL | In | 1:N | INVENTORY_ITEM_ID |
| ERP.CATEGORIES | ERP.MTL_SYSTEM_ITEMS_B | Contains | 1:N | CATEGORY_ID |
| ERP.BRANDS | ERP.MTL_SYSTEM_ITEMS_B | Makes | 1:N | BRAND_ID |
| MARKETING.MARKETING_CAMPAIGNS | CRM.CustomerRegistrationSource | Attributes | 1:N | CAMPAIGN_ID |
| ERP.CITY_TIER_MASTER | ERP.ADDRESSES | Classifies | 1:N | CITY, STATE |

---

## 5. Cross-System Integration Keys

### 5.1 Key Mapping

| Business Entity | Natural Key (Business) | Surrogate Key (Technical) | Master System | Usage |
|-----------------|------------------------|---------------------------|---------------|-------|
| Customer | EMAIL, PHONE | CUSTOMER_ID | CRM | All systems |
| Order | ORDER_NUMBER | ORDER_ID | ERP | ERP, CRM, Analytics |
| Product | SKU | INVENTORY_ITEM_ID | ERP | ERP, Analytics |
| Campaign | CAMPAIGN_CODE | CAMPAIGN_ID | Marketing | Marketing, CRM |
| City | CITY + STATE | Composite PK | ERP | ERP, Analytics |

### 5.2 Key Usage in CLV Queries

```sql
-- Customer joins
CRM.Customers.CUSTOMER_ID = ERP.OE_ORDER_HEADERS_ALL.CUSTOMER_ID
CRM.Customers.CUSTOMER_ID = CRM.CustomerRegistrationSource.CUSTOMER_ID
CRM.Customers.CUSTOMER_ID = CRM.SURVEYS.CUSTOMER_ID

-- Order context joins
ERP.OE_ORDER_HEADERS_ALL.ORDER_ID = CRM.INCIDENTS.ORDER_ID
ERP.OE_ORDER_HEADERS_ALL.ORDER_ID = CRM.SURVEYS.ORDER_ID

-- Geographic joins
ERP.ADDRESSES.CITY = ERP.CITY_TIER_MASTER.CITY 
AND ERP.ADDRESSES.STATE = ERP.CITY_TIER_MASTER.STATE

-- Acquisition cost joins
CRM.CustomerRegistrationSource.CAMPAIGN_ID = MARKETING.MARKETING_CAMPAIGNS.CAMPAIGN_ID
```

---

## 6. Data Quality Rules

### 6.1 Completeness Rules

| Rule ID | Entity | Column | Rule | Threshold |
|---------|--------|--------|------|-----------|
| DQ-C-001 | CRM.Customers | EMAIL | Not Null | 100% |
| DQ-C-002 | CRM.Customers | REGISTRATION_DATE | Not Null | 100% |
| DQ-C-003 | ERP.OE_ORDER_HEADERS_ALL | CUSTOMER_ID | Not Null | 100% |
| DQ-C-004 | ERP.OE_ORDER_HEADERS_ALL | TOTAL_AMOUNT | Not Null | 100% |
| DQ-C-005 | CRM.CustomerRegistrationSource | CHANNEL | Not Null | 100% |

### 6.2 Validity Rules

| Rule ID | Entity | Column | Rule | Valid Range |
|---------|--------|--------|------|-------------|
| DQ-V-001 | ERP.OE_ORDER_HEADERS_ALL | TOTAL_AMOUNT | Range Check | > 0 |
| DQ-V-002 | CRM.SURVEYS | NPS_SCORE | Range Check | 0-10 |
| DQ-V-003 | CRM.SURVEYS | CSAT_SCORE | Range Check | 1-5 |
| DQ-V-004 | CRM.Customers | EMAIL | Format Check | Valid email regex |
| DQ-V-005 | ERP.OE_ORDER_HEADERS_ALL | ORDER_DATE | Date Check | ≤ CURRENT_DATE |

### 6.3 Referential Integrity Rules

| Rule ID | Child Entity | Parent Entity | FK Column | Action on Violation |
|---------|--------------|---------------|-----------|---------------------|
| DQ-R-001 | ERP.OE_ORDER_HEADERS_ALL | CRM.Customers | CUSTOMER_ID | Reject |
| DQ-R-002 | ERP.OE_ORDER_LINES_ALL | ERP.OE_ORDER_HEADERS_ALL | ORDER_ID | Reject |
| DQ-R-003 | CRM.INCIDENTS | CRM.Customers | CUSTOMER_ID | Reject |
| DQ-R-004 | CRM.CustomerRegistrationSource | CRM.Customers | CUSTOMER_ID | Reject |

---

## 7. Data Lineage for CLV

### 7.1 CLV Metric Lineage

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           CLV CALCULATION LINEAGE                                │
└─────────────────────────────────────────────────────────────────────────────────┘

SOURCE LAYER                    TRANSFORMATION                      METRIC
─────────────────              ──────────────────                   ──────

ERP.OE_ORDER_HEADERS_ALL       ┌─────────────────┐
  └─ TOTAL_AMOUNT ────────────►│ SUM / COUNT     │────────────────► AOV
  └─ ORDER_STATUS              │ (Delivered only)│
                               └─────────────────┘

ERP.OE_ORDER_HEADERS_ALL       ┌─────────────────┐
  └─ ORDER_ID ────────────────►│ COUNT / MONTHS  │────────────────► Purchase Frequency
  └─ ORDER_DATE                │                 │
  └─ CUSTOMER_ID               └─────────────────┘

CRM.Customers                  ┌─────────────────┐
  └─ REGISTRATION_DATE ───────►│ Date Diff       │────────────────► Customer Lifespan
  └─ STATUS                    │ (Active tenure) │
ERP.OE_ORDER_HEADERS_ALL       │                 │
  └─ MAX(ORDER_DATE) ─────────►└─────────────────┘

MARKETING.MARKETING_CAMPAIGNS  ┌─────────────────┐
  └─ TOTAL_SPEND ─────────────►│ SPEND / COUNT   │────────────────► CAC
  └─ CUSTOMERS_ACQUIRED ──────►└─────────────────┘

                               ┌─────────────────────────────────────────────────┐
AOV ──────────────────────────►│                                                 │
Purchase Frequency ───────────►│  CLV = (AOV × Freq × Lifespan) - CAC           │────► CLV
Customer Lifespan ────────────►│                                                 │
CAC ──────────────────────────►└─────────────────────────────────────────────────┘
```

### 7.2 Dimension Derivation Lineage

| Derived Dimension | Source Tables | Derivation Logic |
|-------------------|---------------|------------------|
| RFM Segment | ERP.OE_ORDER_HEADERS_ALL | Threshold-based on Recency, Frequency, Monetary |
| Loyalty Tier | ERP.OE_ORDER_HEADERS_ALL | Cumulative spend thresholds |
| City Tier | ERP.ADDRESSES + ERP.CITY_TIER_MASTER | Lookup join on CITY, STATE |
| Acquisition Channel | CRM.CustomerRegistrationSource | Direct from CHANNEL column |
| NPS Category | CRM.SURVEYS | 0-6=Detractor, 7-8=Passive, 9-10=Promoter |

---

## 8. Glossary

| Term | Definition |
|------|------------|
| CLV | Customer Lifetime Value - total revenue from a customer over their relationship |
| AOV | Average Order Value - mean order amount |
| CAC | Customer Acquisition Cost - cost to acquire one customer |
| RFM | Recency, Frequency, Monetary - segmentation framework |
| NPS | Net Promoter Score - loyalty metric (0-10) |
| CSAT | Customer Satisfaction Score - satisfaction metric (1-5) |
| CDC | Change Data Capture - real-time data extraction |
| SCD | Slowly Changing Dimension - history tracking technique |
| Golden Record | Single source of truth for an entity |
| Natural Key | Business-meaningful identifier (e.g., EMAIL) |
| Surrogate Key | System-generated identifier (e.g., CUSTOMER_ID) |

---

## 9. Sign-Off

| Role | Name | Date | Signature |
|------|------|------|-----------|
| Data Steward | | | |
| Data Architect | | | |
| Business Analyst | | | |
| Technical Lead | | | |

---

## Appendix: Change Log

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | Nov 2025 | | Initial draft |
| | | | |
