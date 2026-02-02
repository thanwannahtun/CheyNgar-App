# CheyNgar (အချေးအငှား)

**Lending & Borrowing**

---

## 📝 Project Memo  
### အချေးအငှား (Lender & Borrower Management)

---

## 1. Core Concept

- **Dual-Identity**:  
  A single app with two distinct modules (Lender side & Borrower side).

- **Stand-alone Logic**:  
  Data is managed locally/independently; the two sides do not communicate (Digital Ledger approach).

- **Primary Goal**:  
  Accurate debt tracing and interest calculation to prevent "memory-based" disputes.

---

## 2. Database Architecture (SQL Design)

- **Contacts Table**:  
  Centralized list of people (Name, Phone).

- **Transactions Table**:  
  Master record for loans. Includes direction (LEND/BORROW), principal, interest_rate, and status.

- **Repayments Table**:  
  Tracks partial payments linked to a `transaction_id`.

---

## 3. The "Waterfall" Repayment Logic

To protect the lender's yield and follow Myanmar informal credit norms:

1. **Calculate Accrued Interest**:  
   From the last payment date to today.

2. **Deduction Priority**:
   - **Priority 1**: Pay off the Interest first.
   - **Priority 2**: If money remains, deduct from the Principal.

**Impact**:  
This ensures the interest for the next period is calculated on the highest possible remaining principal.

---

## 4. Interest Calculation Formula

- **Daily Accrual (30-day month basis)**:

```
Interest = Principal × (Interest_Rate / 100) × (Days_Elapsed(Passed) / 30)
```

---

## 5. Data Flow Structures (JSON)

- **Lender Object**:  
  Focuses on `Total_Receivable` and repayment history.

- **Borrower Object**:  
  Focuses on `Total_Outstanding`, `Days_Elapsed`, and `Lender_Details`.

---

## 6. Future Considerations (Scale & Trust)

- **Currency/Gold Pegging**:  
  Protection against inflation (MMK / USD / Gold).

- **Export Functions**:  
  Generate clean summary images / PDFs for Viber / Messenger sharing.

- **Reminders**:  
  Automated alerts for due dates and interest collection days.

---
