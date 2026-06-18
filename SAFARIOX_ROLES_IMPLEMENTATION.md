# SafariOX - User Roles Implementation Guide

## Table of Contents
1. [Customer/User Profile](#customer-profile)
2. [Vendor Profile](#vendor-profile)
3. [Driver Profile](#driver-profile)
4. [Admin Profile](#admin-profile)

---

# Customer Profile

## Overview
The Customer (regular user) is the end consumer who browses tours, makes bookings, and tracks their trips.

### User Role: `user`

## Features

### 1. Authentication
- **OTP-based login** via phone number
- **Google Sign-In** integration
- **Session management** with SharedPreferences
- **Auto-login** if session exists

### 2. Tour Discovery
- Browse available tours
- Search by destination/category
- Filter by price, duration, rating
- View tour details & reviews
- See live availability

### 3. Booking Management
- Select travel date
- Book tour
- View booking history
- Cancel booking (within deadline)
- Download ticket/receipt

### 4. Payment
- Razorpay integration (UPI, Card, Net Banking)
- Payment status tracking
- Refund handling
- Receipt generation

### 5. Live Tracking
- Track assigned bus in real-time
- View ETA (Estimated Time of Arrival)
- See current location on map
- Receive trip notifications

### 6. Profile Management
- Edit profile (name, photo, email)
- View booking history
- Manage payment methods
- Notification preferences
- Account settings

## Database Schema

```sql
CREATE TABLE public.profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  phone TEXT UNIQUE NOT NULL,
  full_name TEXT,
  email TEXT,
  avatar_url TEXT,
  role TEXT NOT NULL DEFAULT 'user' CHECK (role IN ('user', 'vendor', 'admin', 'driver')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE public.bookings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  tour_id UUID NOT NULL REFERENCES public.tours(id) ON DELETE CASCADE,
  status TEXT NOT NULL DEFAULT 'confirmed' CHECK (status IN ('confirmed', 'cancelled', 'completed')),
  booking_date TIMESTAMP WITH TIME ZONE NOT NULL,
  amount NUMERIC NOT NULL,
  payment_id TEXT,
  payment_status TEXT DEFAULT 'pending' CHECK (payment_status IN ('pending', 'paid', 'failed')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE public.notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  type TEXT NOT NULL DEFAULT 'booking', -- booking, tracking, offer, alert
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

## User Interface

### Profile Page
```
┌─────────────────────────┐
│  [Avatar] Name          │
│  +91 XXXXXXXXXX         │
│  [user badge]           │
├─────────────────────────┤
│ Edit Profile      →     │
│ My Bookings       →     │
│ Saved Places      →     │
│ Payment Methods   →     │
│ Notifications     →     │
│ Help & Support    →     │
│ About SafariOX    →     │
├─────────────────────────┤
│ [Logout Button]         │
└─────────────────────────┘
```

## Implementation Code

### Customer Service
```dart
// lib/services/customer_service.dart
class CustomerService {
  final _supabase = Supabase.instance.client;
  
  String? get _userId => _supabase.auth.currentUser?.id;

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    if (_userId == null) return null;
    return await _supabase
        .from('profiles')
        .select()
        .eq('id', _userId!)
        .single();
  }

  // Update profile
  Future<void> updateProfile({
    required String fullName,
    String? email,
    String? avatarUrl,
  }) async {
    await _supabase
        .from('profiles')
        .update({
          'full_name': fullName,
          'email': email,
          'avatar_url': avatarUrl,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', _userId!);
  }

  // Get user bookings
  Future<List<Map<String, dynamic>>> getMyBookings() async {
    if (_userId == null) return [];
    return await _supabase
        .from('bookings')
        .select('*, tours(title, image_url, location, price)')
        .eq('user_id', _userId!)
        .order('booking_date', ascending: false);
  }

  // Cancel booking
  Future<void> cancelBooking(String bookingId) async {
    await _supabase
        .from('bookings')
        .update({'status': 'cancelled'})
        .eq('id', bookingId)
        .eq('user_id', _userId!);
  }

  // Get notifications
  Future<List<Map<String, dynamic>>> getNotifications() async {
    if (_userId == null) return [];
    return await _supabase
        .from('notifications')
        .select()
        .eq('user_id', _userId!)
        .order('created_at', ascending: false);
  }

  // Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    await _supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('id', notificationId);
  }
}
```

### Customer Riverpod Providers
```dart
// In same file or separate
final customerServiceProvider = Provider((ref) => CustomerService());

final userProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) =>
    ref.read(customerServiceProvider).getUserProfile());

final userBookingsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) =>
    ref.read(customerServiceProvider).getMyBookings());

final notificationsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) =>
    ref.read(customerServiceProvider).getNotifications());
```

## Workflows

### Booking Workflow
```
1. Customer browses tours
2. Selects tour → View Details
3. Clicks "Book Now" → BookingPage
4. Selects date & confirms
5. Razorpay payment screen
6. Payment success → Booking confirmed
7. Booking appears in "My Bookings"
8. Trip starts → Live tracking available
9. Trip ends → Booking marked "completed"
```

### Tracking Workflow
```
1. Customer has confirmed booking
2. Trip departure time approaches
3. Push notification: "Your trip starts in 30 mins"
4. Customer opens TrackingPage
5. Real-time GPS marker updates every 10 seconds
6. ETA countdown updates
7. Arrival → Notification & booking marked completed
```

### RLS Policies
```sql
-- Users see only their own bookings
CREATE POLICY "Users read own bookings" ON public.bookings
FOR SELECT USING (auth.uid() = user_id);

-- Users create own bookings
CREATE POLICY "Users create own bookings" ON public.bookings
FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users read own notifications
CREATE POLICY "Users read own notifications" ON public.notifications
FOR SELECT USING (auth.uid() = user_id);

-- Users update own notifications
CREATE POLICY "Users update own notifications" ON public.notifications
FOR UPDATE USING (auth.uid() = user_id);
```

---

# Vendor Profile

## Overview
Vendors are tour operators or bus companies who create and manage tour packages, buses, and bookings.

### User Role: `vendor`

## Features

### 1. Tour Management
- Create new tours
- Edit tour details (title, description, price, image)
- Delete tours
- Set pricing & availability
- View tour status (pending approval, approved, rejected)

### 2. Bus Management
- Add buses/vehicles
- Update bus details (capacity, type, registration)
- Set bus availability
- Enable/disable buses
- Track bus information

### 3. Trip Assignments
- Assign buses to tours
- Set departure times
- Update available seats
- Create multiple trips for same tour (different dates)
- View trip occupancy

### 4. Booking Management
- View bookings for their tours
- See passenger details
- Track payment status
- Handle cancellations
- Generate reports

### 5. Dashboard
- View statistics (tours, buses, assignments, revenue)
- Monthly earnings
- Trip performance metrics
- Passenger statistics

## Database Schema

```sql
CREATE TABLE public.tours (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  vendor_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  location TEXT NOT NULL,
  price NUMERIC NOT NULL,
  category TEXT NOT NULL, -- Beach, Adventure, Religious, Cultural, Wildlife
  image_url TEXT,
  duration TEXT, -- "2 Days", "4 Days", etc
  rating NUMERIC DEFAULT 0,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE public.buses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  vendor_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  registration_number TEXT UNIQUE NOT NULL,
  capacity INTEGER NOT NULL,
  bus_type TEXT NOT NULL DEFAULT 'AC' CHECK (bus_type IN ('AC', 'Non-AC', 'Sleeper')),
  image_url TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE public.tour_assignments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  vendor_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  tour_id UUID NOT NULL REFERENCES public.tours(id) ON DELETE CASCADE,
  bus_id UUID NOT NULL REFERENCES public.buses(id) ON DELETE CASCADE,
  departure_date DATE NOT NULL,
  departure_time TIME NOT NULL,
  available_seats INTEGER NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

## User Interface

### Vendor Dashboard
```
┌─────────────────────────────────┐
│ Vendor Dashboard                │
├─────────────────────────────────┤
│ [12 Tours] [8 Buses] [24 Trips] │
│ [Revenue: ₹1,24,500]            │
├─────────────────────────────────┤
│ [+ Add Tour]  [+ Add Bus]       │
│ [+ Assign Bus]                  │
├─────────────────────────────────┤
│ My Tours          →              │
│ My Buses          →              │
│ Bus Assignments   →              │
│ Tour Bookings     →              │
│ Earnings Report   →              │
│ Settings          →              │
└─────────────────────────────────┘
```

## Implementation Code

### Vendor Service
```dart
// lib/services/vendor_service.dart
class VendorService {
  final _supabase = Supabase.instance.client;
  String? get _vendorId => _supabase.auth.currentUser?.id;

  // ────── Tours ──────────────
  Future<List<Map<String, dynamic>>> getMyTours() async {
    if (_vendorId == null) return [];
    return await _supabase
        .from('tours')
        .select()
        .eq('vendor_id', _vendorId!)
        .order('created_at', ascending: false);
  }

  Future<void> createTour({
    required String title,
    required String description,
    required String location,
    required double price,
    required String category,
    required String imageUrl,
    required String duration,
  }) async {
    await _supabase.from('tours').insert({
      'vendor_id': _vendorId,
      'title': title,
      'description': description,
      'location': location,
      'price': price,
      'category': category,
      'image_url': imageUrl,
      'duration': duration,
      'status': 'pending', // Admin must approve
    });
  }

  Future<void> updateTour({
    required String tourId,
    required String title,
    required String price,
    required String category,
  }) async {
    await _supabase
        .from('tours')
        .update({
          'title': title,
          'price': double.parse(price),
          'category': category,
          'status': 'pending', // Re-approval needed
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', tourId)
        .eq('vendor_id', _vendorId!);
  }

  Future<void> deleteTour(String tourId) async {
    await _supabase
        .from('tours')
        .delete()
        .eq('id', tourId)
        .eq('vendor_id', _vendorId!);
  }

  // ────── Buses ──────────────
  Future<List<Map<String, dynamic>>> getMyBuses() async {
    if (_vendorId == null) return [];
    return await _supabase
        .from('buses')
        .select()
        .eq('vendor_id', _vendorId!)
        .order('created_at', ascending: false);
  }

  Future<void> addBus({
    required String name,
    required String registrationNumber,
    required int capacity,
    required String busType,
  }) async {
    await _supabase.from('buses').insert({
      'vendor_id': _vendorId,
      'name': name,
      'registration_number': registrationNumber,
      'capacity': capacity,
      'bus_type': busType,
    });
  }

  Future<void> toggleBusStatus(String busId, bool isActive) async {
    await _supabase
        .from('buses')
        .update({'is_active': isActive})
        .eq('id', busId)
        .eq('vendor_id', _vendorId!);
  }

  // ────── Assignments ──────────────
  Future<List<Map<String, dynamic>>> getMyAssignments() async {
    if (_vendorId == null) return [];
    return await _supabase
        .from('tour_assignments')
        .select('*, tours(title), buses(name, registration_number)')
        .eq('vendor_id', _vendorId!)
        .order('departure_date', ascending: true);
  }

  Future<void> assignBus({
    required String tourId,
    required String busId,
    required DateTime departureDate,
    required String departureTime,
    required int availableSeats,
  }) async {
    await _supabase.from('tour_assignments').insert({
      'vendor_id': _vendorId,
      'tour_id': tourId,
      'bus_id': busId,
      'departure_date': departureDate.toIso8601String().split('T')[0],
      'departure_time': departureTime,
      'available_seats': availableSeats,
    });
  }

  // ────── Bookings ──────────────
  Future<List<Map<String, dynamic>>> getMyTourBookings() async {
    if (_vendorId == null) return [];
    return await _supabase
        .from('bookings')
        .select('*, tours!inner(title, vendor_id), profiles(full_name, phone)')
        .eq('tours.vendor_id', _vendorId!)
        .order('booking_date', ascending: false);
  }

  // ────── Dashboard Stats ──────────────
  Future<Map<String, int>> getDashboardStats() async {
    if (_vendorId == null) return {};
    final tours = await _supabase
        .from('tours')
        .select('id')
        .eq('vendor_id', _vendorId!);
    final buses = await _supabase
        .from('buses')
        .select('id')
        .eq('vendor_id', _vendorId!);
    final assignments = await _supabase
        .from('tour_assignments')
        .select('id')
        .eq('vendor_id', _vendorId!);
    return {
      'tours': (tours as List).length,
      'buses': (buses as List).length,
      'assignments': (assignments as List).length,
    };
  }
}
```

## Riverpod Providers
```dart
final vendorServiceProvider = Provider((ref) => VendorService());

final vendorToursProvider = FutureProvider((ref) =>
    ref.read(vendorServiceProvider).getMyTours());

final vendorBusesProvider = FutureProvider((ref) =>
    ref.read(vendorServiceProvider).getMyBuses());

final vendorAssignmentsProvider = FutureProvider((ref) =>
    ref.read(vendorServiceProvider).getMyAssignments());

final vendorBookingsProvider = FutureProvider((ref) =>
    ref.read(vendorServiceProvider).getMyTourBookings());

final vendorStatsProvider = FutureProvider((ref) =>
    ref.read(vendorServiceProvider).getDashboardStats());
```

## RLS Policies
```sql
-- Vendors see their own tours
CREATE POLICY "Vendors manage own tours" ON public.tours
FOR ALL USING (auth.uid() = vendor_id)
WITH CHECK (auth.uid() = vendor_id);

-- Vendors see their own buses
CREATE POLICY "Vendors manage own buses" ON public.buses
FOR ALL USING (auth.uid() = vendor_id)
WITH CHECK (auth.uid() = vendor_id);

-- Vendors manage own assignments
CREATE POLICY "Vendors manage assignments" ON public.tour_assignments
FOR ALL USING (auth.uid() = vendor_id)
WITH CHECK (auth.uid() = vendor_id);
```

---

# Driver Profile

## Overview
Drivers operate the buses and provide real-time location updates for tracking.

### User Role: `driver`

## Features

### 1. Authentication
- Phone-based OTP login
- Profile management
- License verification (optional)

### 2. Trip Management
- View assigned trips
- Accept/reject trips (if optional)
- Start trip
- End trip
- Track trip duration

### 3. Location Sharing
- Send GPS location every 10 seconds
- Upload to Supabase realtime
- Automatic battery optimization
- Offline queuing (queue when offline, sync when online)

### 4. Notifications
- Trip assignment notifications
- Passenger count updates
- Route changes
- Emergency alerts
- Destination reached

### 5. Dashboard
- Today's trips
- Trip history
- Earnings summary (if applicable)
- Rating & reviews from passengers

## Database Schema

```sql
CREATE TABLE public.drivers (
  id UUID PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
  license_number TEXT UNIQUE NOT NULL,
  license_expiry DATE,
  phone_verified BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  rating NUMERIC DEFAULT 5.0,
  total_trips INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE public.tracking_points (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  assignment_id UUID NOT NULL REFERENCES public.tour_assignments(id) ON DELETE CASCADE,
  latitude NUMERIC NOT NULL,
  longitude NUMERIC NOT NULL,
  speed NUMERIC DEFAULT 0,
  heading NUMERIC DEFAULT 0,
  accuracy NUMERIC,
  altitude NUMERIC,
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE public.driver_ratings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  driver_id UUID NOT NULL REFERENCES public.drivers(id) ON DELETE CASCADE,
  booking_id UUID NOT NULL REFERENCES public.bookings(id) ON DELETE CASCADE,
  rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

## User Interface

### Driver Dashboard
```
┌──────────────────────────┐
│ Driver: Rajesh Kumar     │
│ License: DL12AB1234      │
│ Rating: ★★★★★ (4.8)     │
│ Total Trips: 145         │
├──────────────────────────┤
│ Today's Trips:           │
│ 1. [08:00] Goa Tour   →  │
│ 2. [14:30] Beach Trip →  │
│ 3. [19:00] Evening   →   │
├──────────────────────────┤
│ [Start Trip] [End Trip]  │
│ [Share Location]         │
│ [Trip History]      →    │
│ [My Ratings]        →    │
└──────────────────────────┘
```

## Implementation Code

### Driver Service
```dart
// lib/services/driver_service.dart
import 'package:geolocator/geolocator.dart';

class DriverService {
  final _supabase = Supabase.instance.client;
  String? get _driverId => _supabase.auth.currentUser?.id;
  
  Timer? _locationTimer;

  // Get assigned trips for today
  Future<List<Map<String, dynamic>>> getTodaysTrips() async {
    if (_driverId == null) return [];
    
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    return await _supabase
        .from('tour_assignments')
        .select('*, buses(name), tours(title, location)')
        .eq('driver_id', _driverId!)
        .gte('departure_date', startOfDay.toIso8601String())
        .lte('departure_date', endOfDay.toIso8601String())
        .order('departure_date', ascending: true);
  }

  // Start sharing location
  void startLocationTracking(String assignmentId) {
    _locationTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      try {
        final position = await Geolocator.getCurrentPosition();
        
        await _supabase.from('tracking_points').insert({
          'assignment_id': assignmentId,
          'latitude': position.latitude,
          'longitude': position.longitude,
          'speed': position.speed,
          'heading': position.heading,
          'accuracy': position.accuracy,
          'altitude': position.altitude,
          'timestamp': DateTime.now().toIso8601String(),
        });

        print('✅ Location updated: ${position.latitude}, ${position.longitude}');
      } catch (e) {
        print('❌ Location error: $e');
      }
    });
  }

  // Stop sharing location
  void stopLocationTracking() {
    _locationTimer?.cancel();
    _locationTimer = null;
  }

  // Get driver ratings
  Future<List<Map<String, dynamic>>> getMyRatings() async {
    if (_driverId == null) return [];
    return await _supabase
        .from('driver_ratings')
        .select()
        .eq('driver_id', _driverId!)
        .order('created_at', ascending: false);
  }

  // Get driver info
  Future<Map<String, dynamic>?> getDriverInfo() async {
    if (_driverId == null) return null;
    return await _supabase
        .from('drivers')
        .select()
        .eq('id', _driverId!)
        .single();
  }

  // Update driver status
  Future<void> updateDriverStatus(bool isActive) async {
    await _supabase
        .from('drivers')
        .update({'is_active': isActive, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', _driverId!);
  }
}
```

### Location Permissions
```dart
// In your driver tracking page
Future<void> requestLocationPermission() async {
  final permission = await Geolocator.checkPermission();
  
  if (permission == LocationPermission.denied) {
    final result = await Geolocator.requestPermission();
    if (result == LocationPermission.denied) {
      // Permission denied
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission required')),
      );
    }
  }
  
  if (permission == LocationPermission.deniedForever) {
    await Geolocator.openLocationSettings();
  }
}
```

## RLS Policies
```sql
-- Drivers see their assigned trips
CREATE POLICY "Drivers view assigned trips" ON public.tour_assignments
FOR SELECT USING (auth.uid() = driver_id);

-- Only drivers can insert tracking points for their trips
CREATE POLICY "Drivers insert own tracking" ON public.tracking_points
FOR INSERT WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.tour_assignments
    WHERE id = assignment_id AND driver_id = auth.uid()
  )
);

-- Drivers view their ratings
CREATE POLICY "Drivers view own ratings" ON public.driver_ratings
FOR SELECT USING (auth.uid() = driver_id);
```

---

# Admin Profile

## Overview
Admins manage the entire platform including users, tours, vendors, buses, and payments.

### User Role: `admin`

## Features

### 1. User Management
- View all users
- Assign roles (user → vendor → admin)
- Block/unblock users
- View user activity
- Manage user complaints

### 2. Tour Management
- Approve/reject vendor tours
- Edit tour details
- Remove inappropriate tours
- View tour statistics
- Monitor tour ratings

### 3. Vendor Management
- View all vendors
- Approve vendor registration
- Suspend/activate vendors
- View vendor performance
- Handle vendor disputes

### 4. Bus Management
- View all buses
- Verify bus documents
- Deactivate unsafe buses
- Monitor bus maintenance
- Track bus utilization

### 5. Booking Management
- View all bookings
- Handle refunds
- Cancel bookings
- View payment details
- Generate booking reports

### 6. Analytics & Reports
- Platform statistics (users, tours, revenue)
- Monthly/yearly reports
- Top tours
- Top vendors
- User growth trends
- Revenue trends

### 7. Settings
- Commission rates
- Platform fees
- Payout settings
- Email notifications
- API integrations

## Database Schema

```sql
-- Extend profiles for admin
ALTER TABLE public.profiles ADD COLUMN permissions JSONB;

CREATE TABLE public.transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id UUID NOT NULL REFERENCES public.bookings(id) ON DELETE CASCADE,
  amount NUMERIC NOT NULL,
  transaction_type TEXT NOT NULL, -- payment, refund, commission
  payment_method TEXT NOT NULL, -- razorpay, bank_transfer
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'failed')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE public.admin_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  admin_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  action TEXT NOT NULL,
  resource TEXT NOT NULL, -- tour, vendor, booking, user
  resource_id UUID,
  changes JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE public.reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reported_by UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  resource_type TEXT NOT NULL, -- tour, vendor, driver, user
  resource_id UUID NOT NULL,
  reason TEXT NOT NULL,
  description TEXT,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'investigating', 'resolved', 'dismissed')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

## User Interface

### Admin Dashboard
```
┌────────────────────────────────────┐
│ Admin Dashboard                    │
├────────────────────────────────────┤
│ [2,456 Users] [234 Vendors]        │
│ [1,200 Tours] [5,234 Bookings]     │
│ [Revenue: ₹12,45,600] [↑ 23.4%]   │
├────────────────────────────────────┤
│ Analytics & Reports                │
│ [📊 Revenue] [👥 Users] [🏆 Tours] │
│ [🚐 Buses] [💳 Payments]           │
├────────────────────────────────────┤
│ Management                         │
│ Users           →                  │
│ Vendors         →                  │
│ Tours (Pending) [23 new]   →       │
│ Buses           →                  │
│ Bookings        →                  │
│ Transactions    →                  │
│ Reports         →                  │
│ Settings        →                  │
└────────────────────────────────────┘
```

## Implementation Code

### Admin Service
```dart
// lib/services/admin_service.dart
class AdminService {
  final _supabase = Supabase.instance.client;

  // ────── Users ──────────────
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    return await _supabase
        .from('profiles')
        .select()
        .neq('id', _supabase.auth.currentUser!.id) // Exclude self
        .order('created_at', ascending: false);
  }

  Future<void> updateUserRole(String userId, String role) async {
    await _supabase
        .from('profiles')
        .update({'role': role})
        .eq('id', userId);
    
    await _logAdminAction(
      action: 'update_user_role',
      resource: 'user',
      resourceId: userId,
      changes: {'role': role},
    );
  }

  // ────── Tours ──────────────
  Future<List<Map<String, dynamic>>> getAllTours() async {
    return await _supabase
        .from('tours')
        .select('*, profiles(full_name)')
        .order('created_at', ascending: false);
  }

  Future<void> updateTourStatus(String tourId, String status) async {
    await _supabase
        .from('tours')
        .update({'status': status})
        .eq('id', tourId);
    
    await _logAdminAction(
      action: 'update_tour_status',
      resource: 'tour',
      resourceId: tourId,
      changes: {'status': status},
    );
  }

  Future<void> deleteTour(String tourId) async {
    await _supabase.from('tours').delete().eq('id', tourId);
    
    await _logAdminAction(
      action: 'delete_tour',
      resource: 'tour',
      resourceId: tourId,
    );
  }

  // ────── Vendors ──────────────
  Future<List<Map<String, dynamic>>> getAllVendors() async {
    return await _supabase
        .from('profiles')
        .select()
        .eq('role', 'vendor')
        .order('created_at', ascending: false);
  }

  Future<void> suspendVendor(String vendorId) async {
    await _supabase
        .from('profiles')
        .update({'is_active': false})
        .eq('id', vendorId);
    
    await _logAdminAction(
      action: 'suspend_vendor',
      resource: 'vendor',
      resourceId: vendorId,
    );
  }

  // ────── Bookings ──────────────
  Future<List<Map<String, dynamic>>> getAllBookings() async {
    return await _supabase
        .from('bookings')
        .select('*, tours(title), profiles(full_name, phone)')
        .order('created_at', ascending: false);
  }

  Future<void> refundBooking(String bookingId, double amount) async {
    // Update booking status
    await _supabase
        .from('bookings')
        .update({'status': 'refunded'})
        .eq('id', bookingId);
    
    // Insert transaction
    await _supabase.from('transactions').insert({
      'booking_id': bookingId,
      'amount': amount,
      'transaction_type': 'refund',
      'payment_method': 'razorpay',
      'status': 'completed',
    });
    
    await _logAdminAction(
      action: 'refund_booking',
      resource: 'booking',
      resourceId: bookingId,
      changes: {'amount': amount},
    );
  }

  // ────── Analytics ──────────────
  Future<Map<String, dynamic>> getDashboardStats() async {
    final users = await _supabase.from('profiles').select('id');
    final vendors = await _supabase
        .from('profiles')
        .select('id')
        .eq('role', 'vendor');
    final tours = await _supabase.from('tours').select('id');
    final bookings = await _supabase.from('bookings').select('id');

    return {
      'total_users': (users as List).length,
      'total_vendors': (vendors as List).length,
      'total_tours': (tours as List).length,
      'total_bookings': (bookings as List).length,
    };
  }

  // ────── Admin Logging ──────────────
  Future<void> _logAdminAction({
    required String action,
    required String resource,
    String? resourceId,
    Map<String, dynamic>? changes,
  }) async {
    final adminId = _supabase.auth.currentUser!.id;
    
    await _supabase.from('admin_logs').insert({
      'admin_id': adminId,
      'action': action,
      'resource': resource,
      'resource_id': resourceId,
      'changes': changes,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // ────── Reports ──────────────
  Future<List<Map<String, dynamic>>> getPendingReports() async {
    return await _supabase
        .from('reports')
        .select()
        .eq('status', 'pending')
        .order('created_at', ascending: true);
  }

  Future<void> updateReportStatus(String reportId, String status) async {
    await _supabase
        .from('reports')
        .update({'status': status})
        .eq('id', reportId);
  }
}
```

## Riverpod Providers
```dart
final adminServiceProvider = Provider((ref) => AdminService());

final adminUsersProvider = FutureProvider((ref) =>
    ref.read(adminServiceProvider).getAllUsers());

final adminToursProvider = FutureProvider((ref) =>
    ref.read(adminServiceProvider).getAllTours());

final adminVendorsProvider = FutureProvider((ref) =>
    ref.read(adminServiceProvider).getAllVendors());

final adminBookingsProvider = FutureProvider((ref) =>
    ref.read(adminServiceProvider).getAllBookings());

final adminStatsProvider = FutureProvider((ref) =>
    ref.read(adminServiceProvider).getDashboardStats());

final pendingReportsProvider = FutureProvider((ref) =>
    ref.read(adminServiceProvider).getPendingReports());
```

## RLS Policies
```sql
-- Only admins can view all users
CREATE POLICY "Admins view all users" ON public.profiles
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role = 'admin'
  )
);

-- Only admins can update user roles
CREATE POLICY "Admins update roles" ON public.profiles
FOR UPDATE USING (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role = 'admin'
  )
);

-- Only admins can view all tours
CREATE POLICY "Admins view all tours" ON public.tours
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role = 'admin'
  )
);

-- Only admins can view admin logs
CREATE POLICY "Admins view logs" ON public.admin_logs
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role = 'admin'
  )
);

-- Only admins can view reports
CREATE POLICY "Admins view reports" ON public.reports
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role = 'admin'
  )
);
```

---

## Role-Based Navigation

```dart
// lib/widgets/role_gate.dart
class RoleGate extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roleAsync = ref.watch(userRoleProvider);

    return roleAsync.when(
      data: (role) => switch (role) {
        'admin'  => const AdminNav(),
        'vendor' => const VendorNav(),
        'driver' => const DriverNav(),
        _        => const BottomNav(), // user
      },
      loading: () => const SplashScreen(),
      error: (_, __) => const BottomNav(),
    );
  }
}
```

---

## Summary

| Role | Primary Function | Key Features | Database Tables |
|------|------------------|--------------|-----------------|
| **Customer** | Browse & book tours | Search, Booking, Payment, Tracking | profiles, tours, bookings, notifications |
| **Vendor** | Create tours & manage buses | Tour management, Bus management, Assignments | tours, buses, tour_assignments |
| **Driver** | Share location & operate bus | Trip tracking, Location sharing, Ratings | drivers, tracking_points, driver_ratings |
| **Admin** | Manage entire platform | User management, Approvals, Analytics | All tables + admin_logs, transactions, reports |

---

This guide provides complete implementation details for all four user roles in SafariOX. Each role has distinct features, database tables, services, and UI components. Follow this structure to build a complete, scalable platform! 🚀
