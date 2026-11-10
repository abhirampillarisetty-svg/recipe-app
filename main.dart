import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(
      ChangeNotifierProvider(
        create: (_) => RecipeProvider(),
        child: const RecipeApp(),
      ),
    );

// ================= MODEL =================
class Ing {
  final String name;
  final double qty; // 0 = text only (no scaling)
  final String unit;
  const Ing(this.name, this.qty, [this.unit = '']);
}

class Recipe {
  final String id, name, emoji, category, difficulty;
  final int minutes, servings;
  final List<Ing> ings;
  final List<String> steps;
  const Recipe(this.id, this.name, this.emoji, this.category, this.minutes,
      this.difficulty, this.servings, this.ings, this.steps);
}

class ShopItem {
  final int id;
  final String text;
  bool done;
  ShopItem(this.id, this.text, [this.done = false]);
}

String fmtQty(double v) {
  final r = (v * 100).round() / 100;
  return r == r.roundToDouble() ? r.toInt().toString() : r.toString();
}

String ingText(Ing i, double factor) {
  if (i.qty == 0) return i.name;
  final q = fmtQty(i.qty * factor);
  return i.unit.isEmpty ? '$q ${i.name}' : '$q ${i.unit} ${i.name}';
}

// ================= RECIPE DATABASE =================
const List<Recipe> seedRecipes = [
  Recipe('r1', 'Masala Omelette', '🍳', 'Breakfast', 10, 'Easy', 2,
    [Ing('Eggs', 4), Ing('Onion, finely chopped', 1), Ing('Tomato, chopped', 1), Ing('Green chilli, chopped', 1), Ing('Coriander leaves, chopped', 2, 'tbsp'), Ing('Turmeric powder', 0.25, 'tsp'), Ing('Oil', 1, 'tbsp'), Ing('Salt to taste', 0)],
    [
      'Beat the eggs with salt and turmeric.',
      'Mix in the onion, tomato, chilli and coriander.',
      'Heat the oil in a non-stick pan.',
      'Pour in the mixture and spread it evenly.',
      'Cook on medium heat until the base sets, flip and cook for 1 more minute.',
      'Serve hot with toast.',
    ]),
  Recipe('r2', 'Fluffy Pancakes', '🥞', 'Breakfast', 20, 'Easy', 4,
    [Ing('All-purpose flour', 200, 'g'), Ing('Baking powder', 2, 'tsp'), Ing('Sugar', 2, 'tbsp'), Ing('Milk', 250, 'ml'), Ing('Egg', 1), Ing('Butter, melted', 3, 'tbsp'), Ing('Salt', 1, 'pinch')],
    [
      'Mix the flour, baking powder, sugar and salt in a bowl.',
      'Whisk the milk, egg and melted butter in another bowl.',
      'Pour the wet mixture into the dry and stir until just combined. Small lumps are fine.',
      'Heat a lightly greased pan on medium heat.',
      'Pour a ladle of batter and cook until bubbles appear, about 2 minutes.',
      'Flip and cook for another minute.',
      'Serve with honey or fresh fruit.',
    ]),
  Recipe('r3', 'Vegetable Poha', '🍚', 'Breakfast', 20, 'Easy', 2,
    [Ing('Thick poha (flattened rice)', 2, 'cups'), Ing('Onion, chopped', 1), Ing('Potato, cut into small cubes', 1), Ing('Peanuts', 2, 'tbsp'), Ing('Mustard seeds', 1, 'tsp'), Ing('Curry leaves', 8), Ing('Green chillies, slit', 2), Ing('Turmeric powder', 0.5, 'tsp'), Ing('Lemon juice', 1, 'tbsp'), Ing('Oil', 2, 'tbsp'), Ing('Salt to taste', 0)],
    [
      'Rinse the poha in a colander until soft, drain well and mix with salt and turmeric.',
      'Heat the oil and fry the peanuts. Set them aside.',
      'Add the mustard seeds, curry leaves and green chillies.',
      'Add the onion and potato and cook until the potato is tender.',
      'Add the poha and peanuts and mix gently for 2 minutes.',
      'Finish with lemon juice and serve hot.',
    ]),
  Recipe('r4', 'Veg Fried Rice', '🍛', 'Lunch', 25, 'Easy', 3,
    [Ing('Cooked basmati rice', 3, 'cups'), Ing('Carrot, diced', 1), Ing('French beans, chopped', 0.5, 'cup'), Ing('Capsicum, diced', 1), Ing('Spring onions, chopped', 3), Ing('Garlic cloves, minced', 3), Ing('Soy sauce', 2, 'tbsp'), Ing('Black pepper', 0.5, 'tsp'), Ing('Oil', 2, 'tbsp'), Ing('Salt to taste', 0)],
    [
      'Spread the cooked rice on a plate so it cools and dries out.',
      'Heat the oil on a high flame and fry the garlic for 20 seconds.',
      'Add the vegetables and stir-fry for 3 to 4 minutes.',
      'Add the rice, soy sauce, pepper and salt.',
      'Toss on high heat for 2 minutes.',
      'Garnish with spring onion greens.',
    ]),
  Recipe('r5', 'Dal Tadka', '🍲', 'Lunch', 35, 'Easy', 4,
    [Ing('Toor dal', 1, 'cup'), Ing('Water', 3, 'cups'), Ing('Turmeric powder', 0.5, 'tsp'), Ing('Onion, chopped', 1), Ing('Tomatoes, chopped', 2), Ing('Garlic cloves, chopped', 4), Ing('Cumin seeds', 1, 'tsp'), Ing('Dried red chillies', 2), Ing('Red chilli powder', 0.5, 'tsp'), Ing('Ghee', 2, 'tbsp'), Ing('Salt to taste', 0)],
    [
      'Pressure cook the dal with water, turmeric and salt for 4 to 5 whistles.',
      'Mash the cooked dal lightly.',
      'Heat the ghee and add the cumin seeds and red chillies.',
      'Add the garlic, onion and tomatoes and cook until soft.',
      'Stir in the chilli powder and the cooked dal and simmer for 5 minutes.',
      'Serve with rice or roti.',
    ]),
  Recipe('r6', 'Pasta Arrabbiata', '🍝', 'Dinner', 25, 'Easy', 2,
    [Ing('Penne pasta', 200, 'g'), Ing('Olive oil', 2, 'tbsp'), Ing('Garlic cloves, sliced', 4), Ing('Red chilli flakes', 1, 'tsp'), Ing('Ripe tomatoes, finely chopped', 4), Ing('Fresh basil leaves', 6), Ing('Grated cheese', 2, 'tbsp'), Ing('Salt to taste', 0)],
    [
      'Boil the pasta in salted water until al dente. Keep a cup of the pasta water and drain.',
      'Heat the oil and saute the garlic and chilli flakes for 30 seconds.',
      'Add the tomatoes and cook for about 10 minutes until saucy.',
      'Add the pasta with a splash of the pasta water.',
      'Toss with the basil and cheese and serve at once.',
    ]),
  Recipe('r7', 'Paneer Butter Masala', '🧈', 'Dinner', 40, 'Medium', 4,
    [Ing('Paneer, cubed', 250, 'g'), Ing('Butter', 3, 'tbsp'), Ing('Tomatoes, chopped', 4), Ing('Cashew nuts', 12), Ing('Ginger-garlic paste', 1, 'tbsp'), Ing('Kashmiri chilli powder', 1, 'tsp'), Ing('Garam masala', 0.5, 'tsp'), Ing('Kasuri methi', 1, 'tsp'), Ing('Fresh cream', 3, 'tbsp'), Ing('Salt to taste', 0)],
    [
      'Boil the tomatoes and cashews until soft, then blend into a smooth puree.',
      'Melt the butter and cook the ginger-garlic paste for a minute.',
      'Pour in the puree with the chilli powder and salt and simmer for 10 minutes.',
      'Add the paneer, garam masala and kasuri methi and simmer for 5 more minutes.',
      'Stir in the cream and switch off the heat.',
      'Serve with naan.',
    ]),
  Recipe('r8', 'Chicken Biryani', '🍗', 'Dinner', 75, 'Hard', 4,
    [Ing('Basmati rice', 2, 'cups'), Ing('Chicken pieces', 500, 'g'), Ing('Curd', 0.5, 'cup'), Ing('Onions, thinly sliced', 3), Ing('Ginger-garlic paste', 2, 'tbsp'), Ing('Biryani masala', 2, 'tbsp'), Ing('Mint leaves', 0.5, 'cup'), Ing('Ghee', 3, 'tbsp'), Ing('Whole spices (bay leaf, cloves, cardamom)', 0), Ing('Salt to taste', 0)],
    [
      'Marinate the chicken with curd, ginger-garlic paste, biryani masala and salt for at least 30 minutes.',
      'Fry the onions in ghee until golden brown and set half aside.',
      'Cook the marinated chicken with the remaining onions for 15 minutes.',
      'Par-boil the soaked rice with the whole spices until about 70 percent done.',
      'Layer the rice over the chicken and top with mint and the fried onions.',
      'Seal the pot and cook on low heat for 25 minutes (dum).',
      'Rest for 10 minutes before serving.',
    ]),
  Recipe('r9', 'Veg Sandwich', '🥪', 'Snacks', 10, 'Easy', 2,
    [Ing('Bread slices', 4), Ing('Butter', 2, 'tbsp'), Ing('Green chutney', 2, 'tbsp'), Ing('Cucumber, sliced', 0.5), Ing('Tomato, sliced', 1), Ing('Boiled potato, sliced', 1), Ing('Chaat masala', 0.5, 'tsp'), Ing('Salt to taste', 0)],
    [
      'Butter the bread slices and spread green chutney on two of them.',
      'Layer the cucumber, tomato and potato slices.',
      'Sprinkle with chaat masala and salt.',
      'Close with the other slices and press down.',
      'Toast on a pan or sandwich maker until golden.',
      'Cut diagonally and serve.',
    ]),
  Recipe('r10', 'Masala Corn', '🌽', 'Snacks', 15, 'Easy', 2,
    [Ing('Sweet corn kernels', 2, 'cups'), Ing('Butter', 1, 'tbsp'), Ing('Chaat masala', 1, 'tsp'), Ing('Red chilli powder', 0.5, 'tsp'), Ing('Lemon juice', 1, 'tbsp'), Ing('Onion, finely chopped', 2, 'tbsp'), Ing('Coriander leaves, chopped', 1, 'tbsp'), Ing('Salt to taste', 0)],
    [
      'Boil the corn for 5 minutes and drain well.',
      'Melt the butter in a pan and saute the corn on high heat for 3 minutes.',
      'Add the chilli powder, chaat masala and salt.',
      'Toss with the onion, coriander and lemon juice.',
      'Serve warm.',
    ]),
  Recipe('r11', 'Chocolate Brownies', '🍫', 'Desserts', 45, 'Medium', 8,
    [Ing('Dark chocolate', 200, 'g'), Ing('Butter', 120, 'g'), Ing('Sugar', 150, 'g'), Ing('Eggs', 3), Ing('All-purpose flour', 80, 'g'), Ing('Cocoa powder', 2, 'tbsp'), Ing('Walnuts, chopped', 50, 'g'), Ing('Vanilla extract', 1, 'tsp'), Ing('Salt', 1, 'pinch')],
    [
      'Preheat the oven to 180 C and line a square tin.',
      'Melt the chocolate and butter together and let it cool slightly.',
      'Whisk in the sugar, eggs and vanilla.',
      'Fold in the flour, cocoa and salt until just combined.',
      'Stir in the walnuts and pour the batter into the tin.',
      'Bake for 25 to 30 minutes. A few moist crumbs on a skewer is perfect.',
      'Cool completely before cutting into squares.',
    ]),
  Recipe('r12', 'Honey-Lime Fruit Salad', '🍓', 'Desserts', 10, 'Easy', 4,
    [Ing('Strawberries, halved', 200, 'g'), Ing('Bananas, sliced', 2), Ing('Apple, chopped', 1), Ing('Grapes', 100, 'g'), Ing('Orange, segmented', 1), Ing('Honey', 2, 'tbsp'), Ing('Lime juice', 1, 'tbsp'), Ing('Mint leaves', 1, 'tbsp')],
    [
      'Wash and chop all the fruit into bite-size pieces.',
      'Whisk the honey and lime juice together.',
      'Toss the fruit gently with the dressing.',
      'Chill for 15 minutes.',
      'Top with mint and serve cold.',
    ]),
  Recipe('r13', 'Mango Lassi', '🥭', 'Drinks', 5, 'Easy', 2,
    [Ing('Ripe mango pulp', 1, 'cup'), Ing('Thick curd', 1, 'cup'), Ing('Milk', 0.5, 'cup'), Ing('Sugar', 2, 'tbsp'), Ing('Cardamom powder', 0.25, 'tsp'), Ing('Ice cubes', 4)],
    [
      'Add all the ingredients to a blender.',
      'Blend until smooth and frothy.',
      'Taste and adjust the sweetness.',
      'Pour into glasses and serve chilled.',
    ]),
  Recipe('r14', 'Masala Chai', '☕', 'Drinks', 10, 'Easy', 2,
    [Ing('Water', 1, 'cup'), Ing('Milk', 1, 'cup'), Ing('Tea leaves', 2, 'tsp'), Ing('Ginger, crushed', 1, 'inch'), Ing('Cardamom pods, crushed', 2), Ing('Sugar', 2, 'tsp')],
    [
      'Boil the water with the ginger and cardamom for 2 minutes.',
      'Add the tea leaves and simmer for 1 minute.',
      'Pour in the milk and sugar and bring to a boil.',
      'Let it rise twice, then strain into cups.',
    ]),
];


const List<String> cats = [
  'Breakfast',
  'Lunch',
  'Dinner',
  'Snacks',
  'Desserts',
  'Drinks',
];
const Map<String, List<Color>> catColors = {
  'Breakfast': [Color(0xFFFDC830), Color(0xFFF37335)],
  'Lunch': [Color(0xFF11998E), Color(0xFF38EF7D)],
  'Dinner': [Color(0xFFFF512F), Color(0xFFDD2476)],
  'Snacks': [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
  'Desserts': [Color(0xFFEC008C), Color(0xFFFC6767)],
  'Drinks': [Color(0xFF00C6FF), Color(0xFF0072FF)],
};
const Map<String, String> catEmoji = {
  'Breakfast': '🍳',
  'Lunch': '🍛',
  'Dinner': '🍲',
  'Snacks': '🥪',
  'Desserts': '🍰',
  'Drinks': '🥤',
};
const List<Color> brandColors = [
  Color(0xFFFF8A00),
  Color(0xFFFF4D6D),
  Color(0xFFD81B60),
];

// ================= STATE (PROVIDER) =================
class RecipeProvider extends ChangeNotifier {
  bool isDark = false;
  String query = '';
  String cat = 'All';
  final List<Recipe> recipes = List.of(seedRecipes);
  final Set<String> favs = {};
  final List<ShopItem> shop = [];
  int _nextId = 0;

  void toggleTheme() {
    isDark = !isDark;
    notifyListeners();
  }

  void setQuery(String q) {
    query = q;
    notifyListeners();
  }

  void setCat(String c) {
    cat = c;
    notifyListeners();
  }

  List<Recipe> get filtered {
    final q = query.trim().toLowerCase();
    return recipes.where((r) {
      final okCat = cat == 'All' || r.category == cat;
      final okQ = q.isEmpty ||
          r.name.toLowerCase().contains(q) ||
          r.ings.any((i) => i.name.toLowerCase().contains(q));
      return okCat && okQ;
    }).toList();
  }

  Recipe byId(String id) => recipes.firstWhere((r) => r.id == id);
  bool isFav(String id) => favs.contains(id);
  List<Recipe> get favRecipes => recipes.where((r) => favs.contains(r.id)).toList();

  void toggleFav(String id) {
    if (!favs.remove(id)) favs.add(id);
    notifyListeners();
  }

  void addRecipe(Recipe r) {
    recipes.insert(0, r);
    notifyListeners();
  }

  int addShopItems(List<String> items) {
    final before = shop.length;
    for (final t in items) {
      final x = t.trim();
      if (x.isEmpty || shop.any((s) => s.text.toLowerCase() == x.toLowerCase())) {
        continue;
      }
      shop.add(ShopItem(_nextId++, x));
    }
    notifyListeners();
    return shop.length - before;
  }

  void toggleShop(ShopItem s) {
    s.done = !s.done;
    notifyListeners();
  }

  void removeShop(ShopItem s) {
    shop.remove(s);
    notifyListeners();
  }

  void clearDone() {
    shop.removeWhere((s) => s.done);
    notifyListeners();
  }
}

// ================= APP + THEME + ROUTES =================
ThemeData buildTheme(Brightness b) => ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFFF6B35),
        brightness: b,
      ),
    );

class RecipeApp extends StatelessWidget {
  const RecipeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<RecipeProvider>();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cookbook - Recipe App',
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: p.isDark ? ThemeMode.dark : ThemeMode.light,
      initialRoute: '/',
      onGenerateRoute: (s) {
        Widget page;
        switch (s.name) {
          case '/detail':
            page = DetailScreen(id: s.arguments as String);
            break;
          case '/favorites':
            page = const FavoritesScreen();
            break;
          case '/shopping':
            page = const ShoppingScreen();
            break;
          case '/add':
            page = const AddRecipeScreen();
            break;
          default:
            page = const HomeScreen();
        }
        return PageRouteBuilder(
          settings: s,
          transitionDuration: const Duration(milliseconds: 450),
          pageBuilder: (c, a, b) => page,
          transitionsBuilder: (c, a, b, child) => FadeTransition(
            opacity: a,
            child: SlideTransition(
              position: Tween<Offset>(
                      begin: const Offset(0, 0.04), end: Offset.zero)
                  .animate(a),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

// ================= CUSTOM REUSABLE WIDGETS =================
class GradientBg extends StatelessWidget {
  final Widget child;
  const GradientBg({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? const [Color(0xFF1E120A), Color(0xFF2A1410), Color(0xFF241A0C)]
              : const [Color(0xFFFFF4E8), Color(0xFFFFEFEF), Color(0xFFFFF9E5)],
        ),
      ),
      child: child,
    );
  }
}

PreferredSizeWidget gBar(String title,
    {List<Widget>? actions, bool back = true}) {
  return AppBar(
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
    centerTitle: true,
    automaticallyImplyLeading: back,
    actions: actions,
    foregroundColor: Colors.white,
    backgroundColor: Colors.transparent,
    elevation: 0,
    flexibleSpace: Container(
      decoration:
          const BoxDecoration(gradient: LinearGradient(colors: brandColors)),
    ),
  );
}

class Frame extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  const Frame({super.key, required this.child, this.maxWidth = 800});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    );
  }
}

class AppButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final List<Color> colors;
  const AppButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.colors = brandColors,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onPressed == null ? 0.45 : 1,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: colors.last.withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20, color: Colors.white),
                    const SizedBox(width: 8),
                  ],
                  Text(label,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ThemeButton extends StatelessWidget {
  const ThemeButton({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<RecipeProvider>();
    return IconButton(
      tooltip: 'Toggle theme',
      icon: Icon(p.isDark ? Icons.light_mode : Icons.dark_mode),
      onPressed: () => context.read<RecipeProvider>().toggleTheme(),
    );
  }
}

class Tag extends StatelessWidget {
  final String text;
  const Tag(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }
}

class RecipeCard extends StatelessWidget {
  final Recipe r;
  final bool fav;
  final VoidCallback onTap;
  const RecipeCard(
      {super.key, required this.r, required this.fav, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cols = catColors[r.category] ?? brandColors;
    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: cols,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Hero(
                      tag: 'emoji-${r.id}',
                      child: Material(
                        color: Colors.transparent,
                        child: Text(r.emoji,
                            style: const TextStyle(fontSize: 58)),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Icon(fav ? Icons.favorite : Icons.favorite_border,
                        color: Colors.white),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text('⏱ ${r.minutes} min • ${r.difficulty}',
                      style: const TextStyle(fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= SCREEN 1: HOME (GRIDVIEW + SEARCH + FILTER) =================
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<RecipeProvider>();
    final list = p.filtered;
    final w = MediaQuery.of(context).size.width;
    final cols = w >= 1000 ? 4 : (w >= 700 ? 3 : 2); // breakpoints
    final chips = ['All', ...cats];
    return Scaffold(
      appBar: gBar(
        'Cookbook 🍳',
        back: false,
        actions: [
          IconButton(
            tooltip: 'Favorites',
            icon: Badge(
              isLabelVisible: p.favs.isNotEmpty,
              label: Text('${p.favs.length}'),
              child: const Icon(Icons.favorite),
            ),
            onPressed: () => Navigator.pushNamed(context, '/favorites'),
          ),
          IconButton(
            tooltip: 'Shopping list',
            icon: Badge(
              isLabelVisible: p.shop.isNotEmpty,
              label: Text('${p.shop.length}'),
              child: const Icon(Icons.shopping_cart),
            ),
            onPressed: () => Navigator.pushNamed(context, '/shopping'),
          ),
          const ThemeButton(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add Recipe'),
      ),
      body: GradientBg(
        child: Frame(
          maxWidth: 1200,
          child: Column(
            children: [
              TextField(
                onChanged: (v) => context.read<RecipeProvider>().setQuery(v),
                decoration: InputDecoration(
                  hintText: 'Search recipes or ingredients',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: chips.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final c = chips[i];
                    return ChoiceChip(
                      label: Text(c == 'All' ? '✨ All' : '${catEmoji[c]} $c'),
                      selected: p.cat == c,
                      onSelected: (_) =>
                          context.read<RecipeProvider>().setCat(c),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: list.isEmpty
                    ? const Center(child: Text('No recipes found 🔍'))
                    : GridView.builder(
                        padding: const EdgeInsets.only(bottom: 90),
                        itemCount: list.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: cols,
                          mainAxisExtent: 220,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                        ),
                        itemBuilder: (context, i) {
                          final r = list[i];
                          return TweenAnimationBuilder<double>(
                            key: ValueKey(r.id),
                            tween: Tween(begin: 0, end: 1),
                            duration:
                                Duration(milliseconds: 300 + (i % 6) * 80),
                            builder: (context, v, child) => Opacity(
                              opacity: v,
                              child: Transform.translate(
                                  offset: Offset(0, 24 * (1 - v)),
                                  child: child),
                            ),
                            child: RecipeCard(
                              r: r,
                              fav: p.isFav(r.id),
                              onTap: () => Navigator.pushNamed(
                                  context, '/detail',
                                  arguments: r.id),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= SCREEN 2: DETAIL (STATEFUL: SERVINGS + STEPS) =================
class DetailScreen extends StatefulWidget {
  final String id;
  const DetailScreen({super.key, required this.id});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late int _serv;
  final Set<int> _done = {};

  @override
  void initState() {
    super.initState();
    _serv = context.read<RecipeProvider>().byId(widget.id).servings;
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<RecipeProvider>();
    final r = p.byId(widget.id);
    final cols = catColors[r.category] ?? brandColors;
    final factor = _serv / r.servings;
    final fav = p.isFav(r.id);
    return Scaffold(
      appBar: gBar(r.name, actions: [
        IconButton(
          tooltip: 'Favorite',
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
            child: Icon(fav ? Icons.favorite : Icons.favorite_border,
                key: ValueKey(fav)),
          ),
          onPressed: () => context.read<RecipeProvider>().toggleFav(r.id),
        ),
      ]),
      body: GradientBg(
        child: SingleChildScrollView(
          child: Frame(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: cols,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      Hero(
                        tag: 'emoji-${r.id}',
                        child: Material(
                          color: Colors.transparent,
                          child: Text(r.emoji,
                              style: const TextStyle(fontSize: 90)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(r.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w900)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          Tag('⏱ ${r.minutes} min'),
                          Tag('📊 ${r.difficulty}'),
                          Tag('${catEmoji[r.category] ?? '🍽'} ${r.category}'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        const Text('🍽  Servings',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: _serv > 1
                              ? () => setState(() => _serv--)
                              : null,
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          transitionBuilder: (c, a) =>
                              ScaleTransition(scale: a, child: c),
                          child: Text('$_serv',
                              key: ValueKey(_serv),
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.w900)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: _serv < 20
                              ? () => setState(() => _serv++)
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('🧂  Ingredients',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        for (final i in r.ings)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.circle, size: 10, color: cols.last),
                                const SizedBox(width: 10),
                                Expanded(
                                    child: Text(ingText(i, factor),
                                        style: const TextStyle(fontSize: 16))),
                              ],
                            ),
                          ),
                        const SizedBox(height: 12),
                        Center(
                          child: AppButton(
                            label: 'Add to shopping list',
                            icon: Icons.shopping_cart,
                            colors: cols,
                            onPressed: () {
                              final n = context
                                  .read<RecipeProvider>()
                                  .addShopItems([
                                for (final i in r.ings) ingText(i, factor)
                              ]);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(n == 0
                                        ? 'Already in your shopping list'
                                        : 'Added $n items to shopping list 🛒')),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('👩‍🍳  Method (tap a step when done)',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        for (int i = 0; i < r.steps.length; i++)
                          InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => setState(() {
                              if (!_done.remove(i)) _done.add(i);
                            }),
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 300),
                              opacity: _done.contains(i) ? 0.45 : 1,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 15,
                                      backgroundColor: cols.last,
                                      child: _done.contains(i)
                                          ? const Icon(Icons.check,
                                              size: 16, color: Colors.white)
                                          : Text('${i + 1}',
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold)),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        r.steps[i],
                                        style: TextStyle(
                                          fontSize: 16,
                                          decoration: _done.contains(i)
                                              ? TextDecoration.lineThrough
                                              : null,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ================= SCREEN 3: FAVORITES (LISTVIEW) =================
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<RecipeProvider>();
    final list = p.favRecipes;
    return Scaffold(
      appBar: gBar('Favorites ❤️', actions: const [ThemeButton()]),
      body: GradientBg(
        child: Frame(
          child: list.isEmpty
              ? const Center(
                  child: Text('No favorites yet. Tap the ❤️ on a recipe!'))
              : ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, i) {
                    final r = list[i];
                    return Card(
                      child: ListTile(
                        leading:
                            Text(r.emoji, style: const TextStyle(fontSize: 34)),
                        title: Text(r.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle:
                            Text('${r.category} • ⏱ ${r.minutes} min'),
                        trailing: IconButton(
                          icon: const Icon(Icons.favorite, color: Colors.red),
                          onPressed: () =>
                              context.read<RecipeProvider>().toggleFav(r.id),
                        ),
                        onTap: () => Navigator.pushNamed(context, '/detail',
                            arguments: r.id),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}

// ================= SCREEN 4: SHOPPING LIST (STATEFUL + DISMISSIBLE) =================
class ShoppingScreen extends StatefulWidget {
  const ShoppingScreen({super.key});

  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> {
  final _c = TextEditingController();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _add() {
    context.read<RecipeProvider>().addShopItems([_c.text]);
    _c.clear();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<RecipeProvider>();
    return Scaffold(
      appBar: gBar('Shopping List 🛒', actions: [
        IconButton(
          tooltip: 'Clear checked items',
          icon: const Icon(Icons.cleaning_services),
          onPressed: () => context.read<RecipeProvider>().clearDone(),
        ),
        const ThemeButton(),
      ]),
      body: GradientBg(
        child: Frame(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _c,
                      onSubmitted: (_) => _add(),
                      decoration: InputDecoration(
                        hintText: 'Add an item (e.g. 1 kg onions)',
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                      onPressed: _add, icon: const Icon(Icons.add)),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: p.shop.isEmpty
                    ? const Center(
                        child: Text('Your list is empty. Add ingredients from a recipe!'))
                    : ListView.builder(
                        itemCount: p.shop.length,
                        itemBuilder: (context, i) {
                          final s = p.shop[i];
                          return Dismissible(
                            key: ValueKey(s.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child:
                                  const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (_) =>
                                context.read<RecipeProvider>().removeShop(s),
                            child: Card(
                              child: CheckboxListTile(
                                value: s.done,
                                onChanged: (_) => context
                                    .read<RecipeProvider>()
                                    .toggleShop(s),
                                title: Text(
                                  s.text,
                                  style: TextStyle(
                                    decoration: s.done
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= SCREEN 5: ADD RECIPE (FORM + VALIDATION) =================
class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _key = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _mins = TextEditingController();
  final _serv = TextEditingController();
  final _ings = TextEditingController();
  final _steps = TextEditingController();
  String _cat = 'Dinner';
  String _diff = 'Easy';

  @override
  void dispose() {
    _name.dispose();
    _mins.dispose();
    _serv.dispose();
    _ings.dispose();
    _steps.dispose();
    super.dispose();
  }

  List<String> _lines(String s) =>
      s.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

  String? _needTwoLines(String? v, String what) =>
      _lines(v ?? '').length < 2 ? 'Add at least 2 $what (one per line)' : null;

  void _save() {
    if (!_key.currentState!.validate()) return;
    final r = Recipe(
      'u${DateTime.now().millisecondsSinceEpoch}',
      _name.text.trim(),
      catEmoji[_cat]!,
      _cat,
      int.parse(_mins.text.trim()),
      _diff,
      int.parse(_serv.text.trim()),
      [for (final l in _lines(_ings.text)) Ing(l, 0)],
      _lines(_steps.text),
    );
    context.read<RecipeProvider>().addRecipe(r);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recipe added! 🎉')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: gBar('Add Recipe ✍️', actions: const [ThemeButton()]),
      body: GradientBg(
        child: SingleChildScrollView(
          child: Frame(
            maxWidth: 600,
            child: Form(
              key: _key,
              child: Column(
                children: [
                  TextFormField(
                    controller: _name,
                    decoration: const InputDecoration(
                      labelText: 'Recipe name',
                      prefixIcon: Icon(Icons.restaurant_menu),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Enter a recipe name';
                      }
                      if (v.trim().length < 3) return 'At least 3 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _cat,
                          decoration: const InputDecoration(
                              labelText: 'Category',
                              border: OutlineInputBorder()),
                          items: [
                            for (final c in cats)
                              DropdownMenuItem(value: c, child: Text(c))
                          ],
                          onChanged: (v) => setState(() => _cat = v!),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _diff,
                          decoration: const InputDecoration(
                              labelText: 'Difficulty',
                              border: OutlineInputBorder()),
                          items: [
                            for (final d in ['Easy', 'Medium', 'Hard'])
                              DropdownMenuItem(value: d, child: Text(d))
                          ],
                          onChanged: (v) => setState(() => _diff = v!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _mins,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: 'Time (minutes)',
                              prefixIcon: Icon(Icons.timer),
                              border: OutlineInputBorder()),
                          validator: (v) {
                            final n = int.tryParse((v ?? '').trim());
                            if (n == null) return 'Enter a number';
                            if (n < 1 || n > 600) return '1 to 600';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _serv,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: 'Servings',
                              prefixIcon: Icon(Icons.people),
                              border: OutlineInputBorder()),
                          validator: (v) {
                            final n = int.tryParse((v ?? '').trim());
                            if (n == null) return 'Enter a number';
                            if (n < 1 || n > 20) return '1 to 20';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _ings,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Ingredients (one per line)',
                      alignLabelWithHint: true,
                      hintText: '2 eggs\n1 cup milk',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => _needTwoLines(v, 'ingredients'),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _steps,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Steps (one per line)',
                      alignLabelWithHint: true,
                      hintText: 'Mix everything\nCook for 10 minutes',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => _needTwoLines(v, 'steps'),
                  ),
                  const SizedBox(height: 22),
                  AppButton(
                    label: 'Save Recipe',
                    icon: Icons.check,
                    onPressed: _save,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
