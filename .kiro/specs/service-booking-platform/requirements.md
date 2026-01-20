# Requirements Document

## Introduction

The Service Booking Platform is a comprehensive Flutter application that enables service providers and clients to connect through a multi-role marketplace. The system supports three distinct user roles (admin, client, employee) with role-based authentication, real-time messaging, service booking management, and dynamic content management through Firebase and Cloudinary integration.

## Glossary

- **Service_Booking_Platform**: The Flutter application system that manages service marketplace operations
- **Firebase_Auth**: Google's authentication service for user sign-in and management
- **Firestore**: Cloud-based NoSQL database for storing application data
- **Cloudinary**: Cloud-based image and video management service
- **Google_Sign_In**: OAuth authentication method using Google accounts
- **Role_Based_Navigation**: Navigation system that routes users based on their assigned role
- **Admin_User**: System administrator with full CRUD permissions for products, bookings, and employee management
- **Client_User**: End user who browses services, creates bookings, and communicates with service providers
- **Employee_User**: Service provider who receives job assignments and updates booking status
- **Booking_Status**: Current state of a service booking (pending, assigned, active, completed)
- **Real_Time_Messaging**: Live chat functionality between users within booking context
- **Dynamic_Content**: All application content sourced from Firestore rather than hardcoded values

## Requirements

### Requirement 1

**User Story:** As a new user, I want to sign in with Google authentication, so that I can access the platform securely without creating separate credentials.

#### Acceptance Criteria

1. WHEN a user opens the application, THE Service_Booking_Platform SHALL display a login screen with Google sign-in option
2. WHEN a user selects Google sign-in, THE Service_Booking_Platform SHALL initiate OAuth flow through Google_Sign_In service
3. WHEN Google authentication succeeds, THE Service_Booking_Platform SHALL create or retrieve user document from Firestore
4. IF user document does not exist, THEN THE Service_Booking_Platform SHALL display role selection screen for client registration
5. WHEN user document exists, THE Service_Booking_Platform SHALL read user role and navigate to appropriate dashboard

### Requirement 2

**User Story:** As a system administrator, I want to manage products and services dynamically, so that I can maintain current offerings without app updates.

#### Acceptance Criteria

1. WHEN an Admin_User accesses the admin dashboard, THE Service_Booking_Platform SHALL display product management interface
2. WHEN an Admin_User creates a new product, THE Service_Booking_Platform SHALL upload images to Cloudinary and store secure_url in Firestore
3. WHEN an Admin_User saves product information, THE Service_Booking_Platform SHALL store title, description, price, category, and imageUrl in Firestore products collection
4. WHEN an Admin_User views product list, THE Service_Booking_Platform SHALL retrieve all products from Firestore dynamically
5. WHEN an Admin_User assigns bookings to employees, THE Service_Booking_Platform SHALL update booking document with employeeId

### Requirement 3

**User Story:** As a client, I want to browse available services and create bookings, so that I can request services from qualified providers.

#### Acceptance Criteria

1. WHEN a Client_User accesses the client dashboard, THE Service_Booking_Platform SHALL display services retrieved from Firestore products collection
2. WHEN a Client_User selects a service, THE Service_Booking_Platform SHALL display detailed service information and booking option
3. WHEN a Client_User creates a booking, THE Service_Booking_Platform SHALL store booking with clientId, productId, and status set to pending
4. WHEN a Client_User views their bookings, THE Service_Booking_Platform SHALL display current booking status and assigned employee information
5. WHEN a booking is assigned to an employee, THE Service_Booking_Platform SHALL enable messaging between client and employee

### Requirement 4

**User Story:** As an employee, I want to manage my assigned jobs and update their status, so that I can track my work progress and communicate with clients.

#### Acceptance Criteria

1. WHEN an Employee_User accesses the employee dashboard, THE Service_Booking_Platform SHALL display bookings where employeeId matches user uid
2. WHEN an Employee_User views assigned booking, THE Service_Booking_Platform SHALL display client information, service details, and current status
3. WHEN an Employee_User updates booking status, THE Service_Booking_Platform SHALL change Booking_Status from pending to active to completed
4. WHEN an Employee_User marks job as completed, THE Service_Booking_Platform SHALL update booking status and notify client
5. WHEN an Employee_User accesses messaging, THE Service_Booking_Platform SHALL enable Real_Time_Messaging with assigned clients

### Requirement 5

**User Story:** As any authenticated user, I want to communicate through real-time messaging, so that I can coordinate service delivery effectively.

#### Acceptance Criteria

1. WHEN users are connected through a booking, THE Service_Booking_Platform SHALL enable Real_Time_Messaging functionality
2. WHEN a user sends a message, THE Service_Booking_Platform SHALL store message with senderId, receiverId, bookingId, content, and timestamp
3. WHEN a user opens chat interface, THE Service_Booking_Platform SHALL display messages filtered by bookingId or participant IDs
4. WHEN a new message is received, THE Service_Booking_Platform SHALL update chat interface in real-time through Firestore streams
5. WHERE messaging is available, THE Service_Booking_Platform SHALL support communication between client-employee and employee-admin pairs

### Requirement 6

**User Story:** As a system user, I want all content to be dynamically loaded from the database, so that the application reflects current data without requiring updates.

#### Acceptance Criteria

1. THE Service_Booking_Platform SHALL retrieve all service categories from Firestore rather than hardcoded lists
2. THE Service_Booking_Platform SHALL load all product information from Firestore products collection
3. THE Service_Booking_Platform SHALL display employee lists sourced from Firestore users collection with role filter
4. THE Service_Booking_Platform SHALL show pricing information retrieved from Firestore product documents
5. THE Service_Booking_Platform SHALL update all UI components automatically when Firestore data changes through stream listeners

### Requirement 7

**User Story:** As a user on any platform, I want the application to work seamlessly across web and mobile devices, so that I can access services from any device.

#### Acceptance Criteria

1. THE Service_Booking_Platform SHALL support Flutter web deployment with Google_Sign_In functionality
2. THE Service_Booking_Platform SHALL maintain responsive design across Android, iOS, and web platforms
3. WHEN deployed on web, THE Service_Booking_Platform SHALL configure OAuth consent screen with appropriate authorized domains
4. THE Service_Booking_Platform SHALL ensure Cloudinary image uploads function correctly across all platforms
5. THE Service_Booking_Platform SHALL maintain consistent user experience and functionality across all supported platforms