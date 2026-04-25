# GoRouter Nested Routing Guide (Production Ready)

## Overview

เอกสารนี้อธิบายการใช้งาน **Nested Routing** ด้วย `go_router` พร้อมแนวทางที่ใช้จริงใน production

---

## 🧱 Use Case

โครงสร้างแอป:

```
/home
  └── /home/detail

/profile
  └── /profile/edit
```

มี layout หลัก (เช่น BottomNavigationBar) และแต่ละ tab มี route ของตัวเอง

---

## 🔑 Key Concepts

### 1. ShellRoute

ใช้เป็น layout หลัก เช่น:

* BottomNavigationBar
* Drawer
* Persistent UI

---

### 2. Nested Routes

กำหนดผ่าน `routes:` ภายใน `GoRoute`

---

### 3. Name vs Path

* `path` → URL
* `name` → ใช้ใน code (แนะนำให้ใช้เสมอ)

---

## 📦 Full Example (Complete Working Code)

```dart id="nested_full_app"
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(const MyApp());
}

/// Route Names (Best Practice)
class AppRoutes {
  static const home = 'home';
  static const homeDetail = 'homeDetail';
  static const profile = 'profile';
  static const profileEdit = 'profileEdit';
}

/// Router Configuration
final GoRouter _router = GoRouter(
  initialLocation: '/home',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return MainScaffold(child: child);
      },
      routes: [
        /// HOME
        GoRoute(
          path: '/home',
          name: AppRoutes.home,
          builder: (context, state) => const HomePage(),
          routes: [
            GoRoute(
              path: 'detail',
              name: AppRoutes.homeDetail,
              builder: (context, state) => const HomeDetailPage(),
            ),
          ],
        ),

        /// PROFILE
        GoRoute(
          path: '/profile',
          name: AppRoutes.profile,
          builder: (context, state) => const ProfilePage(),
          routes: [
            GoRoute(
              path: 'edit',
              name: AppRoutes.profileEdit,
              builder: (context, state) => const EditProfilePage(),
            ),
          ],
        ),
      ],
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
    );
  }
}

/// Main Layout (Shell)
class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/profile')) return 1;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.goNamed(AppRoutes.home);
        break;
      case 1:
        context.goNamed(AppRoutes.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final index = _currentIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => _onTap(context, i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

/// Pages

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            context.pushNamed(AppRoutes.homeDetail);
          },
          child: const Text('Go to Home Detail'),
        ),
      ),
    );
  }
}

class HomeDetailPage extends StatelessWidget {
  const HomeDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Detail')),
      body: const Center(child: Text('Home Detail Page')),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            context.pushNamed(AppRoutes.profileEdit);
          },
          child: const Text('Edit Profile'),
        ),
      ),
    );
  }
}

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: const Center(child: Text('Edit Profile Page')),
    );
  }
}
```

---

## 🧠 How It Works

### Navigation Flow

```dart id="flow_example"
// เปลี่ยน tab (reset stack)
context.goNamed(AppRoutes.profile);

// ไปหน้า detail (stack)
context.pushNamed(AppRoutes.homeDetail);

// ย้อนกลับ
context.pop();
```

---

## 📐 Architecture Insight

| Layer            | Responsibility |
| ---------------- | -------------- |
| ShellRoute       | layout หลัก    |
| GoRoute (parent) | main page      |
| GoRoute (child)  | nested page    |
| name             | navigation API |
| path             | URL structure  |

---

## 🔥 Best Practices

### 1. ใช้ `name` เสมอ

```dart id="bp1"
context.pushNamed(AppRoutes.homeDetail);
```

---

### 2. ห้าม hardcode path ใน UI

```dart id="bp2"
// ❌ Bad
context.go('/home/detail');
```

---

### 3. ใช้ constants รวม route

```dart id="bp3"
class AppRoutes { ... }
```

---

### 4. ใช้ `push` สำหรับ detail, `go` สำหรับ root

* `push` → stack (ย้อนกลับได้)
* `go` → replace (reset flow)

---

## ⚠️ Common Pitfalls

### ❌ ลืมว่า nested path ไม่ต้องมี `/`

```dart id="pit1"
path: 'detail' // ✅ correct
```

---

### ❌ ใช้ go แทน push ใน detail

```dart id="pit2"
// จะทำให้ย้อนกลับไม่ได้
context.goNamed(AppRoutes.homeDetail);
```

---

### ❌ ไม่จัดการ currentIndex

→ tab จะไม่ sync กับ route

---

## 🚀 Scaling Tips

* ใช้ `StatefulShellRoute` ถ้ามีหลาย tab + ต้องจำ state
* แยก router config เป็นไฟล์
* ใช้ code generation สำหรับ type-safe routing

---

## 🧾 Summary

* ใช้ `ShellRoute` สำหรับ layout หลัก
* ใช้ nested `GoRoute` สำหรับ child pages
* ใช้ `name` สำหรับ navigation
* ใช้ `pushNamed` สำหรับ detail
* ใช้ `goNamed` สำหรับเปลี่ยน flow หลัก

---

## 💡 Recommendation

ถ้าแอปคุณมี:

* BottomNavigationBar
* Nested navigation
* หลาย module

👉 ใช้ pattern นี้เป็น baseline ได้เลย (production-ready)

---
