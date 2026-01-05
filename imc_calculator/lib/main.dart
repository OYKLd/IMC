import 'package:flutter/material.dart';
import 'dart:math' as math;

// Couleurs personnalisées
const Color kPrimaryColor = Color(0xFF667eea);
const Color kSecondaryColor = Color(0xFF764ba2);
const Color kAccentColor = Color(0xFFf093fb);
const Color kSuccessColor = Color(0xFF10B981);
const Color kWarningColor = Color(0xFFF59E0B);
const Color kDangerColor = Color(0xFFEF4444);
const Color kInfoColor = Color(0xFF3B82F6);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculateur IMC',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const IMCCalculator(),
    );
  }
}

class IMCCalculator extends StatefulWidget {
  const IMCCalculator({super.key});

  @override
  _IMCCalculatorState createState() => _IMCCalculatorState();
}

class _IMCCalculatorState extends State<IMCCalculator> with TickerProviderStateMixin {
  // Contrôleurs pour les champs de saisie
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  
  // État de l'application
  double _bmi = 0.0;
  String _result = '';
  Color _resultColor = Colors.grey;
  
  // Contrôleurs d'animation
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  // Clé pour le formulaire
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Initialisation des contrôleurs d'animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    )..addStatusListener((status) {
        // Suppression du reverse pour garder l'animation en place
        // Le résultat restera affiché sans disparaître
      });
  }

  void _calculateBMI() {
    // Vérifier si les champs sont vides
    if (_weightController.text.isEmpty || _heightController.text.isEmpty) {
      _showErrorDialog('Veuillez remplir tous les champs');
      return;
    }

    final double? weight = double.tryParse(_weightController.text);
    final double? height = double.tryParse(_heightController.text);

    // Vérifier si les valeurs sont valides
    if (weight == null || height == null || weight <= 0 || height <= 0) {
      _showErrorDialog('Veuillez entrer des valeurs valides');
      return;
    }

    // Calcul de l'IMC avec la taille en mètres
    final double heightInMeters = height / 100;
    
    setState(() {
      _bmi = weight / (heightInMeters * heightInMeters);
      _updateResult();
      // Déclencher l'animation
      _animationController.forward(from: 0.0);
    });
  }
  
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Erreur'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _updateResult() {
    if (_bmi < 18.5) {
      _result = 'Poids insuffisant';
      _resultColor = kInfoColor;
    } else if (_bmi < 25) {
      _result = 'Poids normal';
      _resultColor = kSuccessColor;
    } else if (_bmi < 30) {
      _result = 'Surpoids';
      _resultColor = kWarningColor;
    } else {
      _result = 'Obésité';
      _resultColor = kDangerColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              kPrimaryColor,
              kSecondaryColor,
              kAccentColor,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  
                  // En-tête avec icône
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.favorite,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Calculateur IMC',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Calculez votre indice de masse corporelle',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Carte principale
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 30,
                          spreadRadius: 5,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Champ de saisie pour le poids
                        _buildInputField(
                          controller: _weightController,
                          label: 'Poids',
                          hint: 'Entrez votre poids',
                          unit: 'kg',
                          icon: Icons.monitor_weight_outlined,
                          color: kPrimaryColor,
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Champ de saisie pour la taille
                        _buildInputField(
                          controller: _heightController,
                          label: 'Taille',
                          hint: 'Entrez votre taille',
                          unit: 'cm',
                          icon: Icons.height,
                          color: kSecondaryColor,
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Bouton de calcul
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [kPrimaryColor, kSecondaryColor],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: kPrimaryColor.withOpacity(0.5),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _calculateBMI,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.calculate, color: Colors.white),
                                SizedBox(width: 10),
                                Text(
                                  'CALCULER MON IMC',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Affichage du résultat
                  if (_bmi > 0) ...[
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: _resultColor.withOpacity(0.3),
                              blurRadius: 30,
                              spreadRadius: 5,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Votre IMC',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 15),
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        _resultColor.withOpacity(0.2),
                                        _resultColor.withOpacity(0.05),
                                      ],
                                    ),
                                  ),
                                ),
                                Column(
                                  children: [
                                    Text(
                                      _bmi.toStringAsFixed(1),
                                      style: TextStyle(
                                        fontSize: 56,
                                        fontWeight: FontWeight.bold,
                                        color: _resultColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: _resultColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _result,
                                style: TextStyle(
                                  fontSize: 20,
                                  color: _resultColor,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildBMIScale(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String unit,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2), width: 1.5),
          ),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(18),
              prefixIcon: Icon(icon, color: color, size: 26),
              suffixText: unit,
              suffixStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBMIScale() {
    return Column(
      children: [
        Container(
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              colors: [
                kInfoColor,
                kSuccessColor,
                kWarningColor,
                kDangerColor,
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildScaleLabel('< 18.5', 'Insuffisant'),
            _buildScaleLabel('18.5-25', 'Normal'),
            _buildScaleLabel('25-30', 'Surpoids'),
            _buildScaleLabel('> 30', 'Obésité'),
          ],
        ),
      ],
    );
  }

  Widget _buildScaleLabel(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    // Nettoyage des contrôleurs
    _weightController.dispose();
    _heightController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}