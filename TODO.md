# Flutter App Audit and Fix Plan

## Current Status
- ✅ Basic app structure with providers, models, services
- ✅ Authentication with role support
- ✅ Basic dashboards for admin, client, employee
- ✅ Booking system foundation
- ❌ Many features incomplete or broken
- ❌ Role-based functionality not working properly
- ❌ Real-time messaging missing
- ❌ Employee assignment to bookings broken
- ❌ Admin management features incomplete
- ❌ Payment integration missing
- ❌ Notifications missing
- ❌ Search and filtering not working

## Priority Fixes (High Impact)

### 0. Critical Compilation Errors (COMPLETED)
- [x] Fix MpesaService method mismatch (initiateStkPush -> initiateSTKPush)
- [x] Replace notification_service.dart with stub (missing firebase packages)
- [x] Replace FontWeight.black with FontWeight.w900
- [x] Create custom_avatar_widget.dart
- [x] Add semanticLabel to Icon in employee_profile_screen.dart
- [x] Fix payment_provider.dart null handling

### 1. Role-Based Routing and Access Control
- [ ] Fix routing to properly redirect based on roles
- [ ] Add route guards to prevent unauthorized access
- [ ] Ensure admin can only access admin screens
- [ ] Ensure employees can only access employee screens

### 2. Employee Assignment and Job Management
- [ ] Fix booking provider to properly assign employees
- [ ] Update employee dashboard to show assigned jobs
- [ ] Add status update functionality for employees
- [ ] Fix booking status transitions

### 3. Admin Management Features
- [ ] Complete manage employees screen with approval/rejection
- [ ] Complete manage services screen with CRUD operations
- [ ] Add booking management for admin
- [ ] Add analytics dashboard

### 4. Real-Time Messaging
- [ ] Implement proper chat between clients and employees
- [ ] Add message providers and services
- [ ] Fix chat screen with real data
- [ ] Add typing indicators and read receipts

### 5. Search and Filtering
- [ ] Fix product search functionality
- [ ] Add category filtering
- [ ] Implement proper search queries

### 6. Payment Integration
- [ ] Add M-Pesa STK push integration
- [ ] Create payment provider
- [ ] Add payment status tracking

### 7. Notifications
- [ ] Add Firebase Cloud Messaging
- [ ] Implement push notifications for bookings and messages
- [ ] Add in-app notifications

### 8. UI/UX Fixes
- [ ] Fix layout overflows
- [ ] Add proper loading states
- [ ] Improve animations and transitions
- [ ] Add error handling UI

## Implementation Steps

### Step 1: Fix Core Routing and Role Access
- Update app_router.dart to enforce role-based access
- Add middleware for route protection
- Test role-based navigation

### Step 2: Complete Employee Job Management
- Fix booking_provider.dart for employee assignments
- Update employee_dashboard_screen.dart to show real jobs
- Add job status update functionality

### Step 3: Complete Admin Features
- Enhance manage_employees_screen.dart with full CRUD
- Complete manage_services_screen.dart
- Add admin booking management

### Step 4: Implement Real-Time Chat
- Create message_provider.dart with real-time streams
- Update chat_screen.dart with proper messaging
- Add conversation management

### Step 5: Add Search and Filtering
- Fix product_provider.dart search functionality
- Add category filtering in browse screen
- Implement advanced search

### Step 6: Payment Integration
- Create mpesa_service.dart
- Add payment_provider.dart
- Integrate with booking flow

### Step 7: Notifications
- Add FCM configuration
- Create notification_service.dart
- Implement push notifications

### Step 8: UI Polish and Error Handling
- Fix all overflow issues
- Add proper loading indicators
- Improve error messages
- Add offline support

## Testing Checklist
- [ ] Admin can login and access admin dashboard
- [ ] Admin can manage employees (approve/reject)
- [ ] Admin can manage services (add/edit/delete)
- [ ] Employee can login and see assigned jobs
- [ ] Employee can update job status
- [ ] Client can book services
- [ ] Client can chat with assigned employee
- [ ] Search and filtering works
- [ ] Payments process correctly
- [ ] Notifications are received
- [ ] No UI overflows or crashes
