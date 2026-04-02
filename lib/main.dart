import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MdSneakersApp());
}

class MdSneakersApp extends StatelessWidget {
  const MdSneakersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MD Sneakers',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F6F8),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF22C55E),
        ),
      ),
      home: const AppShell(),
    );
  }
}

class Product {
  final String id;
  final String name;
  final String brand;
  final double price;
  final String image;
  final String category;
  final List<dynamic> sizes;
  final String description;

  Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    required this.image,
    required this.category,
    required this.sizes,
    required this.description,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      brand: json['brand'] ?? '',
      price: (json['price'] as num).toDouble(),
      image: json['image'] ?? '',
      category: json['category'] ?? '',
      sizes: json['sizes'] ?? [],
      description: json['description'] ?? '',
    );
  }
}

class ApiService {
  static const String baseUrl = 'http://localhost:3000';

  static Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('Ошибка загрузки товаров');
    }
  }
}

enum AppStage {
  onboarding1,
  onboarding2,
  onboarding3,
  auth,
  main,
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  AppStage stage = AppStage.onboarding1;
  int currentTab = 0;

  String registeredName = 'Пользователь';
  String registeredEmail = 'user@gmail.com';

  final List<Product> favorites = [];
  final List<CartItem> cart = [];

  void nextOnboarding() {
    setState(() {
      if (stage == AppStage.onboarding1) {
        stage = AppStage.onboarding2;
      } else if (stage == AppStage.onboarding2) {
        stage = AppStage.onboarding3;
      } else if (stage == AppStage.onboarding3) {
        stage = AppStage.auth;
      }
    });
  }

  void skipOnboarding() {
    setState(() {
      stage = AppStage.auth;
    });
  }

  void registerUser(String name, String email) {
    setState(() {
      registeredName = name.trim().isEmpty ? 'Пользователь' : name.trim();
      registeredEmail = email.trim();
      stage = AppStage.main;
    });
  }

  void toggleFavorite(Product product) {
    setState(() {
      final exists = favorites.any((p) => p.id == product.id);
      if (exists) {
        favorites.removeWhere((p) => p.id == product.id);
      } else {
        favorites.add(product);
      }
    });
  }

  bool isFavorite(Product product) {
    return favorites.any((p) => p.id == product.id);
  }

  void addToCart(Product product) {
    setState(() {
      final index = cart.indexWhere((item) => item.product.id == product.id);
      if (index == -1) {
        final size = product.sizes.isNotEmpty ? product.sizes.first.toString() : '9';
        cart.add(CartItem(product: product, quantity: 1, selectedSize: size));
      } else {
        cart[index] = cart[index].copyWith(quantity: cart[index].quantity + 1);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} добавлен в корзину'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void increaseQty(CartItem item) {
    setState(() {
      final index = cart.indexWhere((e) => e.product.id == item.product.id);
      if (index != -1) {
        cart[index] = cart[index].copyWith(quantity: cart[index].quantity + 1);
      }
    });
  }

  void decreaseQty(CartItem item) {
    setState(() {
      final index = cart.indexWhere((e) => e.product.id == item.product.id);
      if (index != -1) {
        if (cart[index].quantity <= 1) {
          cart.removeAt(index);
        } else {
          cart[index] = cart[index].copyWith(quantity: cart[index].quantity - 1);
        }
      }
    });
  }

  void removeFromCart(CartItem item) {
    setState(() {
      cart.removeWhere((e) => e.product.id == item.product.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget child;

    switch (stage) {
      case AppStage.onboarding1:
        child = OnboardingScreen(
          image: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=900',
          title: 'Добро пожаловать в\nMD',
          subtitle:
              'Откройте для себя лучшую коллекцию\nпремиальных кроссовок от ведущих\nмировых брендов',
          pageIndex: 0,
          buttonText: 'Далее',
          onNext: nextOnboarding,
          onSkip: skipOnboarding,
        );
        break;
      case AppStage.onboarding2:
        child = OnboardingScreen(
          image: 'https://images.unsplash.com/photo-1525966222134-fcfa99b8ae77?w=900',
          title: 'Быстрая доставка',
          subtitle:
              'Получите свои любимые кроссовки с\nдоставкой до двери за 2-3 дня',
          pageIndex: 1,
          buttonText: 'Далее',
          onNext: nextOnboarding,
          onSkip: skipOnboarding,
          imageBg: const Color(0xFFC7F700),
        );
        break;
      case AppStage.onboarding3:
        child = OnboardingScreen(
          image: 'https://images.unsplash.com/photo-1543508282-6319a3e2621f?w=900',
          title: 'Легкий шопинг',
          subtitle:
              'Простой и безопасный процесс\nоформления заказа для удобных покупок',
          pageIndex: 2,
          buttonText: 'Начать',
          onNext: nextOnboarding,
          onSkip: skipOnboarding,
        );
        break;
      case AppStage.auth:
        child = AuthScreen(
          onRegister: registerUser,
        );
        break;
      case AppStage.main:
        child = MainNavigationScreen(
          currentTab: currentTab,
          onTabChange: (index) {
            setState(() => currentTab = index);
          },
          favorites: favorites,
          cart: cart,
          isFavorite: isFavorite,
          onToggleFavorite: toggleFavorite,
          onAddToCart: addToCart,
          onIncreaseQty: increaseQty,
          onDecreaseQty: decreaseQty,
          onRemoveFromCart: removeFromCart,
          userName: registeredName,
          userEmail: registeredEmail,
        );
        break;
    }

    return Scaffold(
      body: Container(
        color: const Color(0xFFEDEFF2),
        child: Center(
          child: Container(
            width: 390,
            height: MediaQuery.of(context).size.height,
            color: Colors.white,
            child: child,
          ),
        ),
      ),
    );
  }
}

class OnboardingScreen extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;
  final int pageIndex;
  final String buttonText;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final Color imageBg;

  const OnboardingScreen({
    super.key,
    required this.image,
    required this.title,
    required this.subtitle,
    required this.pageIndex,
    required this.buttonText,
    required this.onNext,
    required this.onSkip,
    this.imageBg = const Color(0xFFFFF4F4),
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: onSkip,
                child: const Text(
                  'Пропустить',
                  style: TextStyle(
                    color: Color(0xFF8E98A8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              height: 290,
              decoration: BoxDecoration(
                color: imageBg,
                borderRadius: BorderRadius.circular(24),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.network(
                image,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 44),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 23,
                height: 1.2,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                height: 1.6,
                color: Color(0xFF7C8798),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == pageIndex ? 26 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == pageIndex
                        ? const Color(0xFF22C55E)
                        : const Color(0xFFD9E0E8),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onNext,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF22C55E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      buttonText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class AuthScreen extends StatefulWidget {
  final void Function(String name, String email) onRegister;

  const AuthScreen({
    super.key,
    required this.onRegister,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscure = true;
  String? errorText;

  bool _isAllowedEmail(String email) {
    final value = email.toLowerCase().trim();
    return value.endsWith('@gmail.com') ||
        value.endsWith('@mail.ru') ||
        value.endsWith('@icloud.com');
  }

  void submit() {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (name.isEmpty) {
      setState(() {
        errorText = 'Введите имя';
      });
      return;
    }

    if (!_isAllowedEmail(email)) {
      setState(() {
        errorText = 'Email должен оканчиваться на @gmail.com, @mail.ru или @icloud.com';
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        errorText = 'Пароль должен содержать минимум 6 символов';
      });
      return;
    }

    setState(() {
      errorText = null;
    });

    widget.onRegister(name, email);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 26),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E),
                borderRadius: BorderRadius.circular(18),
              ),
              alignment: Alignment.center,
              child: const Text(
                'MD',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Регистрация',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Создайте аккаунт, чтобы продолжить покупки',
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF7C8798),
              ),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8FA),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  icon: Icon(Icons.person_outline, color: Color(0xFF9CA3AF)),
                  hintText: 'Имя',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8FA),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  icon: Icon(Icons.mail_outline, color: Color(0xFF9CA3AF)),
                  hintText: 'Email',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8FA),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: passwordController,
                obscureText: obscure,
                decoration: InputDecoration(
                  icon: const Icon(Icons.lock_outline, color: Color(0xFF9CA3AF)),
                  hintText: 'Пароль',
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => obscure = !obscure),
                    icon: Icon(
                      obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Доступны только @gmail.com, @mail.ru, @icloud.com. Пароль минимум 6 символов.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF7C8798),
              ),
            ),
            if (errorText != null) ...[
              const SizedBox(height: 12),
              Text(
                errorText!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(height: 26),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: submit,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF22C55E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Зарегистрироваться',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  final int currentTab;
  final ValueChanged<int> onTabChange;
  final List<Product> favorites;
  final List<CartItem> cart;
  final bool Function(Product) isFavorite;
  final void Function(Product) onToggleFavorite;
  final void Function(Product) onAddToCart;
  final void Function(CartItem) onIncreaseQty;
  final void Function(CartItem) onDecreaseQty;
  final void Function(CartItem) onRemoveFromCart;
  final String userName;
  final String userEmail;

  const MainNavigationScreen({
    super.key,
    required this.currentTab,
    required this.onTabChange,
    required this.favorites,
    required this.cart,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onAddToCart,
    required this.onIncreaseQty,
    required this.onDecreaseQty,
    required this.onRemoveFromCart,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late Future<List<Product>> futureProducts;
  String selectedCategory = 'Все';

  @override
  void initState() {
    super.initState();
    futureProducts = ApiService.fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: futureProducts,
      builder: (context, snapshot) {
        final allProducts = snapshot.data ?? [];

        final filtered = allProducts.where((product) {
          return selectedCategory == 'Все' ||
              product.brand.toLowerCase() == selectedCategory.toLowerCase() ||
              product.category.toLowerCase() == selectedCategory.toLowerCase();
        }).toList();

        final screens = [
          HomeInfoScreen(
            userName: widget.userName,
          ),
          CatalogLikeScreen(
            products: filtered,
            totalCount: filtered.length,
            selectedCategory: selectedCategory,
            onCategoryChanged: (v) => setState(() => selectedCategory = v),
            isFavorite: widget.isFavorite,
            onToggleFavorite: widget.onToggleFavorite,
            onAddToCart: widget.onAddToCart,
          ),
          CartLikeScreen(
            cart: widget.cart,
            onIncreaseQty: widget.onIncreaseQty,
            onDecreaseQty: widget.onDecreaseQty,
            onRemoveFromCart: widget.onRemoveFromCart,
          ),
          ProfileLikeScreen(
            name: widget.userName,
            email: widget.userEmail,
            favoritesCount: widget.favorites.length,
            ordersCount: widget.cart.length + 1,
          ),
        ];

        return Scaffold(
          backgroundColor: const Color(0xFFF5F6F8),
          body: snapshot.connectionState == ConnectionState.waiting
              ? const Center(child: CircularProgressIndicator())
              : snapshot.hasError
                  ? Center(child: Text('Ошибка: ${snapshot.error}'))
                  : screens[widget.currentTab],
          bottomNavigationBar: Container(
            height: 88,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xFFE8EDF3)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(0, Icons.home_outlined, Icons.home, 'Главная'),
                _navItem(1, Icons.grid_view_outlined, Icons.grid_view_rounded, 'Каталог'),
                _navItem(2, Icons.shopping_cart_outlined, Icons.shopping_cart, 'Корзина'),
                _navItem(3, Icons.person_outline, Icons.person, 'Профиль'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _navItem(int index, IconData icon, IconData selectedIcon, String label) {
    final active = widget.currentTab == index;
    return InkWell(
      onTap: () => widget.onTabChange(index),
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        width: 78,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              active ? selectedIcon : icon,
              color: active ? const Color(0xFF22C55E) : const Color(0xFF94A3B8),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? const Color(0xFF22C55E) : const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeInfoScreen extends StatelessWidget {
  final String userName;

  const HomeInfoScreen({
    super.key,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'MD',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'MD Sneakers',
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        'Добро пожаловать, $userName',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF7C8798),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Магазин открыт',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Добро пожаловать в MD Sneakers — магазин стильных и удобных кроссовок от популярных брендов.',
                    style: TextStyle(
                      color: Colors.white,
                      height: 1.5,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Наши преимущества',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 18),
            const AdvantageCard(
              icon: Icons.local_shipping_outlined,
              title: 'Быстрая доставка',
              subtitle: 'Доставим заказ за 2-3 дня прямо до двери.',
            ),
            const SizedBox(height: 14),
            const AdvantageCard(
              icon: Icons.verified_outlined,
              title: 'Оригинальная продукция',
              subtitle: 'В магазине представлены только качественные модели.',
            ),
            const SizedBox(height: 14),
            const AdvantageCard(
              icon: Icons.discount_outlined,
              title: 'Выгодные предложения',
              subtitle: 'Скидки, акции и бонусы для наших покупателей.',
            ),
            const SizedBox(height: 14),
            const AdvantageCard(
              icon: Icons.support_agent_outlined,
              title: 'Поддержка клиентов',
              subtitle: 'Всегда поможем с выбором, размером и заказом.',
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Что можно сделать в приложении?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 14),
                  Text('• Смотреть каталог товаров'),
                  SizedBox(height: 8),
                  Text('• Добавлять товары в корзину'),
                  SizedBox(height: 8),
                  Text('• Сохранять любимые модели'),
                  SizedBox(height: 8),
                  Text('• Управлять профилем пользователя'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdvantageCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const AdvantageCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(
              color: Color(0x1622C55E),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: const Color(0xFF22C55E),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF7C8798),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CatalogLikeScreen extends StatelessWidget {
  final List<Product> products;
  final int totalCount;
  final String selectedCategory;
  final ValueChanged<String> onCategoryChanged;
  final bool Function(Product) isFavorite;
  final void Function(Product) onToggleFavorite;
  final void Function(Product) onAddToCart;

  const CatalogLikeScreen({
    super.key,
    required this.products,
    required this.totalCount,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.arrow_back, size: 24),
                Expanded(
                  child: Center(
                    child: Text(
                      'Каталог',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ),
                Icon(Icons.tune, size: 22),
              ],
            ),
            const SizedBox(height: 18),
            CategoryTabs(
              selected: selectedCategory,
              onChanged: onCategoryChanged,
            ),
            const SizedBox(height: 24),
            Text(
              'Найдено $totalCount товаров',
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF7C8798),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                itemCount: products.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 18,
                  mainAxisExtent: 275,
                ),
                itemBuilder: (context, index) {
                  final product = products[index];
                  return ProductGridCard(
                    product: product,
                    isFavorite: isFavorite(product),
                    onFavorite: () => onToggleFavorite(product),
                    onAddToCart: () => onAddToCart(product),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CartLikeScreen extends StatelessWidget {
  final List<CartItem> cart;
  final void Function(CartItem) onIncreaseQty;
  final void Function(CartItem) onDecreaseQty;
  final void Function(CartItem) onRemoveFromCart;

  const CartLikeScreen({
    super.key,
    required this.cart,
    required this.onIncreaseQty,
    required this.onDecreaseQty,
    required this.onRemoveFromCart,
  });

  @override
  Widget build(BuildContext context) {
    final subtotal = cart.fold<double>(
      0,
      (sum, item) => sum + item.product.price * item.quantity,
    );
    const delivery = 10.00;
    final total = subtotal + delivery;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 110),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.arrow_back, size: 24),
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'Корзина',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${cart.length} товаров',
                        style: const TextStyle(
                          color: Color(0xFF7C8798),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
              ],
            ),
            const SizedBox(height: 22),
            Expanded(
              child: cart.isEmpty
                  ? const Center(
                      child: Text(
                        'Корзина пуста',
                        style: TextStyle(
                          fontSize: 20,
                          color: Color(0xFF7C8798),
                        ),
                      ),
                    )
                  : ListView(
                      children: [
                        ...cart.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 18),
                            child: CartItemCard(
                              item: item,
                              onIncrease: () => onIncreaseQty(item),
                              onDecrease: () => onDecreaseQty(item),
                              onRemove: () => onRemoveFromCart(item),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'Итого',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 18),
                        SummaryRow(
                          title: 'Подытог',
                          value: '\$${subtotal.toStringAsFixed(2)}',
                        ),
                        const SizedBox(height: 12),
                        const SummaryRow(
                          title: 'Доставка',
                          value: '\$10.00',
                        ),
                        const SizedBox(height: 20),
                        SummaryRow(
                          title: 'Всего',
                          value: '\$${total.toStringAsFixed(2)}',
                          valueColor: const Color(0xFF22C55E),
                          big: true,
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF22C55E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Оформить заказ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileLikeScreen extends StatelessWidget {
  final String name;
  final String email;
  final int favoritesCount;
  final int ordersCount;

  const ProfileLikeScreen({
    super.key,
    required this.name,
    required this.email,
    required this.favoritesCount,
    required this.ordersCount,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 110),
        child: Column(
          children: [
            const Text(
              'Профиль',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 26),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF3FFF6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      color: Color(0xFF22C55E),
                      size: 38,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: const TextStyle(
                            color: Color(0xFFDDFBE7),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Редактировать профиль',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white,
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
            ProfileMenuTile(
              icon: Icons.inventory_2_outlined,
              title: 'Мои заказы',
              badge: '$ordersCount',
            ),
            ProfileMenuTile(
              icon: Icons.favorite_border,
              title: 'Избранное',
              badge: '$favoritesCount',
            ),
            const ProfileMenuTile(
              icon: Icons.location_on_outlined,
              title: 'Адреса',
            ),
            const ProfileMenuTile(
              icon: Icons.credit_card_outlined,
              title: 'Способы оплаты',
            ),
            const ProfileMenuTile(
              icon: Icons.settings_outlined,
              title: 'Настройки',
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryTabs extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const CategoryTabs({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const categories = ['Все', 'Nike', 'Adidas', 'Puma', 'New Balance'];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final category = categories[index];
          final active = category == selected;

          return GestureDetector(
            onTap: () => onChanged(category),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: active ? const Color(0xFF22C55E) : Colors.transparent,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Text(
                category,
                style: TextStyle(
                  color: active ? Colors.white : const Color(0xFF0F172A),
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ProductGridCard extends StatelessWidget {
  final Product product;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback onAddToCart;

  const ProductGridCard({
    super.key,
    required this.product,
    required this.isFavorite,
    required this.onFavorite,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F4F7),
                  borderRadius: BorderRadius.circular(18),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.network(
                  product.image,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: onFavorite,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : const Color(0xFF94A3B8),
                      size: 21,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            product.brand,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              GestureDetector(
                onTap: onAddToCart,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: Color(0xFF22C55E),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shopping_bag_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

class CartItem {
  final Product product;
  final int quantity;
  final String selectedSize;

  CartItem({
    required this.product,
    required this.quantity,
    required this.selectedSize,
  });

  CartItem copyWith({
    Product? product,
    int? quantity,
    String? selectedSize,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      selectedSize: selectedSize ?? this.selectedSize,
    );
  }
}

class CartItemCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  const CartItemCard({
    super.key,
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Image.network(
            item.product.image,
            width: 92,
            height: 92,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.product.brand,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                item.product.name,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Размер: ${item.selectedSize}',
                style: const TextStyle(
                  color: Color(0xFF7C8798),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    '\$${item.product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 16),
                  _qtyButton('-', onDecrease),
                  const SizedBox(width: 10),
                  Text(
                    '${item.quantity}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 10),
                  _qtyButton('+', onIncrease),
                ],
              ),
            ],
          ),
        ),
        Column(
          children: [
            IconButton(
              onPressed: onRemove,
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.pinkAccent,
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _qtyButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 26,
        height: 26,
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 24,
              height: 1,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
      ),
    );
  }
}

class SummaryRow extends StatelessWidget {
  final String title;
  final String value;
  final Color valueColor;
  final bool big;

  const SummaryRow({
    super.key,
    required this.title,
    required this.value,
    this.valueColor = const Color(0xFF0F172A),
    this.big = false,
  });

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(
      fontSize: big ? 19 : 16,
      fontWeight: big ? FontWeight.w800 : FontWeight.w500,
      color: const Color(0xFF0F172A),
    );

    final valueStyle = TextStyle(
      fontSize: big ? 20 : 16,
      fontWeight: big ? FontWeight.w800 : FontWeight.w600,
      color: valueColor,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: titleStyle),
        Text(value, style: valueStyle),
      ],
    );
  }
}

class ProfileMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? badge;

  const ProfileMenuTile({
    super.key,
    required this.icon,
    required this.title,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
        leading: Icon(icon, color: const Color(0xFF0F172A)),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (badge != null)
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Color(0xFF22C55E),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  badge!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            const SizedBox(width: 10),
            const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }
}