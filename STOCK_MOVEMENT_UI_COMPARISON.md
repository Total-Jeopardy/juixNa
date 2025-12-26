# Stock Movement Screen: Current vs Design

## ✅ What We Have (Implemented)

1. **Header**
   - ✅ Back button (left arrow)
   - ✅ Title "Stock Movement" (centered, bold green)
   - ✅ Theme toggle (moon/sun icon, right)

2. **Status Section**
   - ✅ Online status indicator: "ONLINE • LAST SYNC: [time]" with Wi-Fi icon

3. **Movement Toggle**
   - ✅ Stock-In / Stock-Out segmented control
   - ✅ Proper highlighting for selected option

4. **Form Fields**
   - ✅ Date picker (with calendar icon)
   - ✅ Product picker (with dropdown icon)
   - ✅ Quantity field (with +/- buttons, "Units" label, available stock display)
   - ✅ Unit Cost field (locked, with "MANAGER/ADMIN ONLY" caption)
   - ✅ Location picker (with dropdown icon)
   - ✅ Unit Cost + Location inline row
   - ✅ Reason field (required, with asterisk)
   - ✅ Reference field (optional)
   - ✅ Notes/Reason text area (with character counter 0/250)

5. **Additional Elements**
   - ✅ View Recent Movements link (with history and filter icons)
   - ✅ Footer buttons (Cancel, Save Movement)
   - ✅ Error states and validation
   - ✅ Loading indicators

---

## ❌ What We're Missing (From Design)

### 1. **Batch # Field** ⚠️ CRITICAL MISSING
   - **Design shows:** A "Batch #" field that appears after Product selection
   - **Features:**
     - Label: "Batch #" with "Required" indicator (in red when required)
     - Red border when there's an error
     - Error messages:
       - "Batch selection is required."
       - "This product is batch-tracked."
     - Red exclamation icon on the right
   - **Current status:** Not implemented at all
   - **Note:** According to API spec, batch tracking is optional for v1, but the design shows it as a field

### 2. **Field Order** ⚠️ MINOR MISMATCH
   - **Design order:**
     1. Date
     2. Product
     3. **Batch #** (missing)
     4. Quantity (appears after Product is selected)
     5. Unit Cost + Location (inline)
     6. Reason
     7. Reference
     8. Notes
   
   - **Current order:**
     1. Date
     2. Product
     3. Quantity (conditional - only shows when Product AND Location both selected)
     4. Unit Cost + Location (inline)
     5. Reason
     6. Reference
     7. Notes

### 3. **Quantity Field Display Logic** ⚠️ DIFFERENT BEHAVIOR
   - **Design shows:** Quantity appears right after Product (and Batch #) selection
   - **Current behavior:** Quantity only appears when BOTH Product AND Location are selected
   - **Impact:** Users must select location before seeing quantity field, which differs from design

---

## 🔧 Recommended Changes

### Priority 1: Add Batch # Field
1. Add `batchNumber` to `StockMovementState`
2. Add batch picker/input field after Product field
3. Show batch field conditionally based on product's batch-tracking requirement
4. Implement validation and error states (red border, error messages)
5. Update ViewModel to handle batch selection

### Priority 2: Adjust Field Order & Display Logic
1. Move Quantity field to appear right after Product (and Batch # if shown)
2. Change Quantity display logic: Show when Product is selected (not requiring Location)
3. Keep Location selection separate (in inline row with Unit Cost)

### Priority 3: Styling Refinements
1. Ensure all error states match design (red borders, error icons)
2. Verify spacing matches design exactly
3. Check font sizes and weights match design

---

## 📋 Implementation Notes

- **Batch Tracking:** According to API spec v1, batches are optional. However, the design shows batch as a required field for batch-tracked products. We should:
  - Check if product has `requires_batch` or similar flag
  - Show batch field conditionally
  - Make it required only for batch-tracked products

- **Quantity Validation:** Current logic requires location to be selected before showing quantity. Design suggests quantity should be available as soon as product is selected. We may need to:
  - Show quantity field after product selection
  - Load available stock for all locations (or default location)
  - Or show quantity with location selector inline

---

## 🎯 Next Steps

1. **Decide on Batch # field:**
   - If implementing: Add to state, ViewModel, and UI
   - If deferring: Note in design review that it's planned for v2

2. **Adjust Quantity field logic:**
   - Show quantity field after Product selection
   - Handle available stock calculation (may need to show per-location or aggregate)

3. **Final UI polish:**
   - Match exact spacing from design
   - Verify all error states match design
   - Test form flow matches design expectations

