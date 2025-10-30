import 'package:flutter/material.dart';

// === Modelos ===
class RequiredDocument {
  final int number;
  final String? message;
  final List<DocumentOption> options;

  RequiredDocument({
    required this.number,
    this.message,
    required this.options,
  });

  factory RequiredDocument.fromJson(Map<String, dynamic> json) {
    final List<DocumentOption> options = (json['options'] as List)
        .map((opt) => DocumentOption.fromJson(opt))
        .toList();

    return RequiredDocument(
      number: json['number'],
      message: json['message'] as String?,
      options: options,
    );
  }
}

class DocumentOption {
  final String id;
  final String name;

  DocumentOption({required this.id, required this.name});

  factory DocumentOption.fromJson(Map<String, dynamic> json) {
    return DocumentOption(
      id: json['id'].toString(),
      name: json['name'].toString().trim(),
    );
  }
}

// === Modelo para documentos agrupados ===
class GroupedDocument {
  final int number;
  final List<RequiredDocument> documents;
  final bool hasMultipleOptions;

  GroupedDocument({
    required this.number,
    required this.documents,
    required this.hasMultipleOptions,
  });
}

// === Pantalla Principal ===
class DocumentsScreen extends StatelessWidget {
  final VoidCallback? onExit;
  final List<RequiredDocument> documents;

  const DocumentsScreen({
    Key? key,
    this.onExit,
    required this.documents,
  }) : super(key: key);

  List<GroupedDocument> _groupDocumentsByNumber() {
    final Map<int, List<RequiredDocument>> grouped = {};
    
    for (final doc in documents.where((d) => d.number != 0)) {
      grouped.putIfAbsent(doc.number, () => []).add(doc);
    }
    
    return grouped.entries
        .map((entry) => GroupedDocument(
              number: entry.key,
              documents: entry.value,
              hasMultipleOptions: entry.value.length > 1,
            ))
        .toList()
      ..sort((a, b) => a.number.compareTo(b.number));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Documentos Requeridos',
          style: theme.appBarTheme.titleTextStyle?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF132c29), Color(0xFF1a3a36)],
                )
              : const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFB8E6C1), Color(0xFFA8D5B2)],
                ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // === Encabezado ===
                  Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4A7C59),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.description, color: Colors.white, size: 40),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Documentos Requeridos",
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF333333),
                          fontFamily: 'Roboto',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Para trámite en plataforma",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark ? Colors.white70 : const Color(0xFF666666),
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // === Tarjeta de Información ===
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF90CAF9)),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info, color: Color(0xFF1976D2), size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Información Importante",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1976D2),
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Todos los documentos son obligatorios y deben ser presentados al realizar su préstamo formal en oficinas.",
                                style: TextStyle(
                                  color: Color(0xFF1976D2),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // === Lista de Documentos Agrupados ===
                  Column(
                    children: _groupDocumentsByNumber().map((groupedDoc) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: isDark ? Colors.black.withOpacity(0.25) : Colors.black12,
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Círculo con el número
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  groupedDoc.number.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Si hay múltiples opciones, mostrar que es "uno de estos"
                                  if (groupedDoc.hasMultipleOptions) ...[
                                    // Badge de "Elegir uno"
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.orange[100],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.orange[300]!),
                                      ),
                                      child: Text(
                                        "ELEGIR UNO DE ESTOS",
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange[700],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    
                                    // Lista de opciones disponibles
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF1a3a36) : Colors.orange[50],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.orange[200]!,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Opciones disponibles (presentar solo una):",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.orange[700],
                                              fontSize: 13,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          ...groupedDoc.documents.map((doc) => Padding(
                                                padding: const EdgeInsets.only(bottom: 12),
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      width: 6,
                                                      height: 6,
                                                      margin: const EdgeInsets.only(top: 6),
                                                      decoration: BoxDecoration(
                                                        color: Colors.orange[600],
                                                        shape: BoxShape.circle,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: Text(
                                                        doc.message ?? "Documento ${doc.number}",
                                                        style: TextStyle(
                                                          color: isDark ? Colors.white : const Color(0xFF333333),
                                                          fontSize: 15,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )),
                                        ],
                                      ),
                                    ),
                                  ] else ...[
                                    // Documento único - resaltar el nombre
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.green[100],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.green[300]!),
                                      ),
                                      child: Text(
                                        "OBLIGATORIO",
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green[700],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    
                                    // Nombre del documento resaltado
                                    Text(
                                      groupedDoc.documents.first.message ?? "Documento ${groupedDoc.number}",
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.white : const Color(0xFF333333),
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    
                                    // Descripción adicional si existe
                                    if (groupedDoc.documents.first.options.isNotEmpty)
                                      Container(
                                        margin: const EdgeInsets.only(top: 8),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: isDark ? const Color(0xFF1a3a36) : Colors.green[50],
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: Colors.green[200]!,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Detalles:",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.green[700],
                                                fontSize: 13,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            ...groupedDoc.documents.first.options.map((option) => Padding(
                                                  padding: const EdgeInsets.only(bottom: 4),
                                                  child: Text(
                                                    "• ${option.name}",
                                                    style: TextStyle(
                                                      color: isDark ? Colors.white70 : Colors.green[700],
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                )),
                                          ],
                                        ),
                                      ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                  // === Resumen ===
                  Container(
                    margin: const EdgeInsets.only(top: 24),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: isDark
                          ? const LinearGradient(colors: [Color(0xFF23272F), Color(0xFF4A7C59)])
                          : const LinearGradient(colors: [Color(0xFF4A7C59), Color(0xFF2E5233)]),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withOpacity(0.25)
                              : Colors.green[100]!.withOpacity(0.18),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Resumen de Documentos",
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text(
                                  _groupDocumentsByNumber().length.toString(),
                                  style: theme.textTheme.displaySmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                  ),
                                ),
                                Text(
                                  "Documentos\nRequeridos",
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70, fontSize: 13),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  _groupDocumentsByNumber().where((g) => g.hasMultipleOptions).length.toString(),
                                  style: theme.textTheme.displaySmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                  ),
                                ),
                                Text(
                                  "Con\nOpciones",
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70, fontSize: 13),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  _groupDocumentsByNumber().where((g) => !g.hasMultipleOptions).length.toString(),
                                  style: theme.textTheme.displaySmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                  ),
                                ),
                                Text(
                                  "Únicos\nObligatorios",
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70, fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // === Botón Final ===
                  Padding(
                    padding: const EdgeInsets.only(top: 32.0, bottom: 24.0),
                    child: ElevatedButton(
                      onPressed: () {
                        if (onExit != null) {
                          onExit!();
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A7C59),
                        minimumSize: const Size(double.infinity, 64),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 8,
                        foregroundColor: Colors.white,
                        textStyle: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: const Text("ENTENDIDO"),
                    ),
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