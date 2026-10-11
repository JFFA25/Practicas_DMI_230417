import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const PokedexApp());

// ---------------------------------------------------------------------------
// Utilidades: nombres en español y colores por tipo
// ---------------------------------------------------------------------------
const Map<String, String> _typesEs = {
  'fire': 'Fuego',
  'water': 'Agua',
  'grass': 'Planta',
  'electric': 'Eléctrico',
  'bug': 'Bicho',
  'normal': 'Normal',
  'poison': 'Veneno',
  'flying': 'Volador',
  'ground': 'Tierra',
  'psychic': 'Psíquico',
  'ghost': 'Fantasma',
  'dragon': 'Dragón',
};

const Map<String, Color> _typeColors = {
  'fire': Colors.deepOrange,
  'water': Colors.blue,
  'grass': Colors.green,
  'electric': Colors.amber,
  'bug': Colors.lightGreen,
  'normal': Colors.grey,
  'poison': Colors.purple,
  'flying': Colors.indigo,
  'ground': Colors.brown,
  'psychic': Colors.pink,
  'ghost': Colors.deepPurple,
  'dragon': Colors.indigoAccent,
  'fighting': Colors.red,
  'rock': Colors.brown,
  'ice': Colors.cyan,
  'steel': Colors.blueGrey,
  'dark': Colors.blueGrey,
  'fairy': Colors.pinkAccent,
};

Color _typeColor(String type) => _typeColors[type] ?? Colors.grey;

String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

String _imageUrl(int id) =>
    'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

// ---------------------------------------------------------------------------
// App (tema claro y oscuro automático según el sistema)
// ---------------------------------------------------------------------------
class PokedexApp extends StatelessWidget {
  const PokedexApp({super.key});

  ThemeData _theme(Brightness brightness) => ThemeData(
        colorSchemeSeed: Colors.red,
        brightness: brightness,
        useMaterial3: true,
      );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokédex Mini',
      debugShowCheckedModeBanner: false,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}

// ---------------------------------------------------------------------------
// Pantalla de bienvenida
// ---------------------------------------------------------------------------
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade700,
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.catching_pokemon, size: 110, color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Pokédex Mini',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Pantalla principal con navegación inferior
// ---------------------------------------------------------------------------
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_index == 0 ? 'Pokédex Mini' : 'Registro de entrenador'),
      ),
      body: IndexedStack(
        index: _index,
        children: const [PokemonListScreen(), RegisterScreen()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.catching_pokemon), label: 'Pokédex'),
          NavigationDestination(icon: Icon(Icons.person_add), label: 'Registro'),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Lista: buscador + filtro por tipo + grid adaptable
// ---------------------------------------------------------------------------
class PokemonListScreen extends StatefulWidget {
  const PokemonListScreen({super.key});

  @override
  State<PokemonListScreen> createState() => _PokemonListScreenState();
}

class _PokemonListScreenState extends State<PokemonListScreen> {
  String? _type; // null = todos
  String _query = '';
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetch(null);
  }

  Future<List<Map<String, dynamic>>> _fetch(String? type) async {
    final uri = type == null
        ? Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=60')
        : Uri.parse('https://pokeapi.co/api/v2/type/$type');
    final res = await http.get(uri).timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) {
      throw Exception('Error ${res.statusCode} al consultar la API');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final List raw = type == null
        ? data['results'] as List
        : (data['pokemon'] as List).map((e) => e['pokemon']).toList();

    final list = <Map<String, dynamic>>[];
    for (final p in raw) {
      final url = p['url'] as String;
      final id = int.parse(url.split('/').where((s) => s.isNotEmpty).last);
      if (id > 1025) continue; // se omiten formas especiales
      list.add({'id': id, 'name': p['name'] as String});
    }
    return list.take(60).toList();
  }

  void _selectType(String? type) {
    setState(() {
      _type = type;
      _future = _fetch(type);
    });
  }

  void _retry() => _selectType(_type);

  Widget _chip(String? type, String label) {
    final selected = _type == type;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        selectedColor:
            type == null ? null : _typeColor(type).withValues(alpha: 0.55),
        onSelected: (_) => _selectType(type),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Buscar Pokémon por nombre',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
          ),
        ),
        SizedBox(
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: [
              _chip(null, 'Todos'),
              ..._typesEs.entries.map((e) => _chip(e.key, e.value)),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.wifi_off, size: 48),
                        const SizedBox(height: 12),
                        const Text('No se pudo cargar la información.',
                            textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        FilledButton(
                            onPressed: _retry, child: const Text('Reintentar')),
                      ],
                    ),
                  ),
                );
              }
              final items = snap.data!
                  .where((p) => (p['name'] as String).contains(_query))
                  .toList();
              if (items.isEmpty) {
                return const Center(child: Text('Sin resultados'));
              }
              return GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: items.length,
                itemBuilder: (context, i) {
                  final p = items[i];
                  return _PokemonCard(
                      id: p['id'] as int, name: p['name'] as String);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PokemonCard extends StatelessWidget {
  final int id;
  final String name;
  const _PokemonCard({required this.id, required this.name});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailScreen(id: id, name: name)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Expanded(
                child: Hero(
                  tag: 'poke-$id',
                  child: Image.network(
                    _imageUrl(id),
                    fit: BoxFit.contain,
                    loadingBuilder: (c, child, prog) => prog == null
                        ? child
                        : const Center(
                            child: CircularProgressIndicator(strokeWidth: 2)),
                    errorBuilder: (c, e, s) =>
                        const Icon(Icons.broken_image, size: 40),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text('#$id', style: Theme.of(context).textTheme.labelSmall),
              Text(
                _cap(name),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Detalle (color según el tipo principal)
// ---------------------------------------------------------------------------
class DetailScreen extends StatelessWidget {
  final int id;
  final String name;
  const DetailScreen({super.key, required this.id, required this.name});

  Future<Map<String, dynamic>> _fetchDetail() async {
    final res = await http
        .get(Uri.parse('https://pokeapi.co/api/v2/pokemon/$id'))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) {
      throw Exception('Error ${res.statusCode}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_cap(name))),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchDetail(),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return const Center(child: Text('No se pudo cargar el detalle.'));
          }
          final d = snap.data!;
          final typeKeys = (d['types'] as List)
              .map((t) => t['type']['name'] as String)
              .toList();
          final mainColor =
              typeKeys.isEmpty ? Colors.grey : _typeColor(typeKeys.first);
          final abilities = (d['abilities'] as List)
              .map((a) => _cap(a['ability']['name'] as String))
              .toList();
          final stats = (d['stats'] as List).map((s) {
            return MapEntry(
              _cap(s['stat']['name'] as String),
              s['base_stat'] as int,
            );
          }).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                height: 240,
                decoration: BoxDecoration(
                  color: mainColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.all(12),
                child: Hero(
                  tag: 'poke-$id',
                  child: Image.network(
                    _imageUrl(id),
                    fit: BoxFit.contain,
                    errorBuilder: (c, e, s) =>
                        const Icon(Icons.broken_image, size: 60),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: typeKeys
                    .map((t) => Chip(
                          label: Text(_typesEs[t] ?? _cap(t)),
                          backgroundColor:
                              _typeColor(t).withValues(alpha: 0.35),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.height),
                      title: const Text('Altura'),
                      trailing: Text('${(d['height'] as int) / 10} m'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.monitor_weight_outlined),
                      title: const Text('Peso'),
                      trailing: Text('${(d['weight'] as int) / 10} kg'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.bolt),
                      title: const Text('Habilidades'),
                      subtitle: Text(abilities.join(', ')),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text('Estadísticas base',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...stats.map(
                (s) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 120,
                        child: Text(s.key, overflow: TextOverflow.ellipsis),
                      ),
                      SizedBox(width: 32, child: Text('${s.value}')),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: (s.value / 150).clamp(0.0, 1.0),
                          minHeight: 8,
                          color: mainColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Formulario con validación
// ---------------------------------------------------------------------------
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  String _favorite = 'Fuego';
  bool _accepted = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final valid = _formKey.currentState!.validate();
    if (!valid) return;
    if (!_accepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Debes aceptar los términos para continuar')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¡Registro exitoso!'),
        content: Text(
          'Entrenador: ${_nameCtrl.text}\n'
          'Correo: ${_emailCtrl.text}\n'
          'Edad: ${_ageCtrl.text}\n'
          'Tipo favorito: $_favorite',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  void _clear() {
    _formKey.currentState!.reset();
    _nameCtrl.clear();
    _emailCtrl.clear();
    _ageCtrl.clear();
    setState(() {
      _favorite = 'Fuego';
      _accepted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del entrenador',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'El nombre es obligatorio';
                    }
                    if (v.trim().length < 3) return 'Mínimo 3 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'El correo es obligatorio';
                    }
                    final ok =
                        RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$').hasMatch(v.trim());
                    if (!ok) return 'Ingresa un correo válido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ageCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Edad',
                    prefixIcon: Icon(Icons.cake),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'La edad es obligatoria';
                    }
                    final n = int.tryParse(v.trim());
                    if (n == null) return 'Solo números';
                    if (n < 10 || n > 100) return 'Debe estar entre 10 y 100';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _favorite,
                  decoration: const InputDecoration(
                    labelText: 'Tipo favorito',
                    prefixIcon: Icon(Icons.local_fire_department),
                    border: OutlineInputBorder(),
                  ),
                  items: const ['Fuego', 'Agua', 'Planta', 'Eléctrico']
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => setState(() => _favorite = v ?? 'Fuego'),
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  value: _accepted,
                  onChanged: (v) => setState(() => _accepted = v ?? false),
                  title: const Text('Acepto los términos y condiciones'),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _clear,
                        child: const Text('Limpiar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _submit,
                        child: const Text('Registrar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}