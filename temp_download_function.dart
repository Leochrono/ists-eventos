  Future<void> _descargarQR() async {
    setState(() => _isGeneratingQR = true);

    try {
      // En web, simular descarga
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('En web: Haz clic derecho en el QR > "Guardar imagen como..."'),
            backgroundColor: Color(0xFF2E7D32),
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Función disponible en app móvil: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } finally {
      setState(() => _isGeneratingQR = false);
    }
  }
