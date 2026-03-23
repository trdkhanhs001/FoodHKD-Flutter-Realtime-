# Backend Update - Notes Field Support

## ✅ Changes Made

### 1. Entity - `OnlineOrder.java`
Added field to store customer notes/remarks:

```java
// Customer notes/remarks
@jakarta.persistence.Column(name = "notes", length = 500)
private String notes;

public String getNotes() {
    return notes;
}

public void setNotes(String notes) {
    this.notes = notes;
}
```

**Location:** `src/main/java/com/example/FoodHKD/model/OnlineOrder.java`

---

### 2. Database Migration
Execute this SQL to add the column:

```sql
ALTER TABLE dbo.online_orders
ADD notes NVARCHAR(255) NULL;
```

✅ **Already done by you!**

---

### 3. Controller Updates

#### `OnlineOrderController.java` (`/api/orders` endpoint)
- ✅ Accepts `notes` in request body
- ✅ Saves `notes` when creating order
- ✅ Returns `notes` in response

**Code:**
```java
String notes = (String) request.getOrDefault("notes", "");
order.setNotes(notes);
```

#### `OnlineOrderRest.java` (`/api/online-orders` endpoint)
- ✅ Returns `notes` in convertOrderToMap method

**Both converters now include:**
```java
map.put("notes", order.getNotes() != null ? order.getNotes() : "");
```

**Location:** 
- `src/main/java/com/example/FoodHKD/rest/client/OnlineOrderController.java`
- `src/main/java/com/example/FoodHKD/rest/client/OnlineOrderRest.java`

---

### 4. Repository - `OnlineOrderRepository.java`
✅ **No changes needed!**

Since we use `JpaRepository` (not custom `@Query`), Spring automatically selects all entity fields including the new `notes` field.

**Location:** `src/main/java/com/example/FoodHKD/repository/OnlineOrderRepository.java`

---

## 📊 Data Flow

### Creating Order with Notes

**Frontend Request:**
```json
POST /api/orders
{
  "customerId": 1,
  "customerName": "John Doe",
  "phone": "0123456789",
  "items": [...],
  "couponCode": "SALE20",
  "notes": "Vui lòng cắt nhỏ thành từng miếng"
}
```

**Backend Processing:**
1. Extract `notes` from request body
2. Create `OnlineOrder` entity
3. Call `order.setNotes(notes)`
4. Save to database
5. Return response with all fields including `notes`

**Backend Response:**
```json
{
  "success": true,
  "message": "Đơn hàng được tạo thành công",
  "orderId": 5,
  "order": {
    "orderId": 5,
    "customerId": 1,
    "customerName": "John Doe",
    "phone": "0123456789",
    "notes": "Vui lòng cắt nhỏ thành từng miếng",
    "total": 280000,
    "status": "Pending",
    ...
  }
}
```

---

## 🧪 Testing

### Test with Postman

**1. Create Order with Notes**
```
POST http://localhost:8080/api/orders
Authorization: Bearer <token>

{
  "customerId": 1,
  "customerName": "Test User",
  "phone": "0123456789",
  "items": [
    {
      "foodId": 1,
      "foodName": "Pizza",
      "quantity": 1,
      "priceAtOrderTime": 100000
    }
  ],
  "notes": "No onions please!"
}
```

**Expected Response:**
- Status: 201 Created
- Response includes `"notes": "No onions please!"`

---

**2. Get Order with Notes**
```
GET http://localhost:8080/api/orders/5
Authorization: Bearer <token>
```

**Expected Response:**
- Status: 200 OK
- Response includes `"notes": "No onions please!"`

---

**3. Get All Orders (Admin)**
```
GET http://localhost:8080/api/online-orders
Authorization: Bearer <token>
```

**Expected Response:**
- Status: 200 OK
- All orders include their respective `notes` field

---

## 🔍 Verification

### Check if `notes` is being persisted:

```sql
-- View an order with notes
SELECT orderId, customerName, total, notes, status, createdAt 
FROM dbo.online_orders 
WHERE orderId = 5;
```

**Sample Output:**
```
orderId | customerName | total  | notes                    | status  | createdAt
--------|--------------|--------|--------------------------|---------|------------------
5       | John Doe     | 100000 | No onions please!       | Pending | 2025-12-04 15:45:30
```

---

## 📝 Summary

| Component | Status | Details |
|-----------|--------|---------|
| Entity | ✅ Done | Field added with getter/setter |
| Database | ✅ Done | Column created (NVARCHAR(255)) |
| Controller - Create | ✅ Done | Receives and saves notes |
| Controller - Read | ✅ Done | Returns notes in response |
| Repository | ✅ OK | No changes needed - JpaRepository handles it |
| API Documentation | ✅ Updated | Examples include notes field |

---

## 🚀 Next Steps for Frontend

1. **When creating order**, include `notes` field in request body
2. **Parse response** - Extract `notes` from response order object
3. **Display notes** in admin dashboard for order management

---

## 📞 Troubleshooting

### Issue: Notes field is null/empty in response

**Check:**
1. Database column exists: `SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'online_orders' AND COLUMN_NAME = 'notes'`
2. Entity has the field: Check `OnlineOrder.java` for `@Column` annotation
3. Controller saves it: Verify `order.setNotes(notes)` is called
4. Converter includes it: Verify `map.put("notes", ...)` in convertOrderToMap()

---

**Last Updated:** 2025-12-04  
**Version:** 1.0
