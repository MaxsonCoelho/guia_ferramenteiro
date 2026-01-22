import 'package:flutter/material.dart';
import '../../../core/widgets/widgets.dart';
import 'tool_detail_page.dart';
import 'measurement_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MetalScaffold(
      title: 'Guia Ferramenteiro',
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ToolCard(
            name: 'Paquímetro',
            description: 'Instrumento de precisão utilizado para medir dimensões lineares internas, externas e de profundidade de uma peça.',
            summary: 'Use as orelhas para medidas internas, bicos para externas e a haste para profundidade. A leitura combina a escala fixa com o nônio.',
            imagePath: 'assets/images/paquimetro.png',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ToolDetailPage(
                    toolName: 'Paquímetro',
                    description: 'Instrumento de precisão utilizado para medir dimensões lineares internas, externas e de profundidade de uma peça.\n\nO paquímetro é composto por uma escala fixa e uma escala móvel (nônio ou vernier). A leitura é feita combinando a medida da escala fixa antes do zero do nônio com o traço do nônio que melhor coincide com um traço da escala fixa.',
                    imagePath: 'assets/images/paquimetro.png',
                    onMeasurementTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MeasurementPage(),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
