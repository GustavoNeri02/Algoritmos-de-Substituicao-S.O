import 'dart:math';

import 'pagina_de_memoria.dart';

Random random = Random();

void main() {
  //matriz SWAP com os valores especificados
  List<PaginaDeMemoria> matrizSWAP = List.generate(100, (index) {
    return PaginaDeMemoria(
      n: index,
      i: index + 1,
      d: 1 + random.nextInt(50),
      r: 0,
      m: 0,
      t: 100 + random.nextInt(9900),
    );
  });
  // matriz RAM com valores da matriz SWAP
  List<PaginaDeMemoria> matrizRAM = List.generate(10, (index) {
    final randomIndex = random.nextInt(100);
    return matrizSWAP[randomIndex];
  });

  printMatrizes(matrizSWAP: matrizSWAP, matrizRAM: matrizRAM);

  int pointer =
      0; // apontador para a RAM utilizada por FIFO, FIFO_SC, Relógio e WS_CLOCK

  for (int i = 0; i < 1000; i++) {
    int instructionNumber = random.nextInt(100) + 1;
    bool isFoundedInRAM = false;

    for (var page in matrizRAM) {
      if (page.i == instructionNumber) {
        // operacoes especificadas quando a página ta na RAM
        page.r = 1;
        if (random.nextDouble() <= 0.3) {
          page.d += 1;
          page.m = 1;
        }
        isFoundedInRAM = true;
        break;
      }
    }

    if (!isFoundedInRAM) {
      // realizar SUBSTITUIÇÃO - ESCOLHA UM ALGORITMO

      runFIFO(
        matrizSWAP: matrizSWAP,
        matrizRAM: matrizRAM,
        pointer: pointer,
        instructionNumber: instructionNumber,
      );

      // runFIFOSC(
      //   matrizSWAP: matrizSWAP,
      //   matrizRAM: matrizRAM,
      //   pointer: pointer,
      //   instructionNumber: instructionNumber,
      // );

      // runNRU(
      //   matrizSWAP: matrizSWAP,
      //   matrizRAM: matrizRAM,
      //   instructionNumber: instructionNumber,
      // );

      // runCLOCK(
      //   matrizSWAP: matrizSWAP,
      //   matrizRAM: matrizRAM,
      //   pointer: pointer,
      //   instructionNumber: instructionNumber,
      // );

      // runWSCLOCK(
      //   matrizSWAP: matrizSWAP,
      //   matrizRAM: matrizRAM,
      //   pointer: pointer,
      //   instructionNumber: instructionNumber,
      // );
    }

    if (i % 9 == 0) {
      // a cada 10 instruções, reseta o bit R para todas as páginas na matrizRAM
      for (var page in matrizRAM) {
        page.r = 0;
      }
    }
  }

  printMatrizes(matrizSWAP: matrizSWAP, matrizRAM: matrizRAM);
}

// --------------------- FUNÇÔES AUXILIARES ------------------------
void printMatrizValues(List<PaginaDeMemoria> matriz) {
  for (var pagina in matriz) {
    print(
      "N: ${pagina.n}, I: ${pagina.i}, D: ${pagina.d}, R: ${pagina.r}, "
      "M: ${pagina.m}, T: ${pagina.t}",
    );
  }
}

void printMatrizes({
  required List<PaginaDeMemoria> matrizSWAP,
  required List<PaginaDeMemoria> matrizRAM,
}) {
  print("\n------------------------------------------------\n");
  print("MATRIZ SWAP:");
  printMatrizValues(matrizSWAP);
  print("\n                     ------                     \n");
  print("MATRIZ RAM:");
  printMatrizValues(matrizRAM);
  print("\n------------------------------------------------\n");
}

// --------------------- ALGORITMOS DE SUBSTITUIÇÂO ------------------------
void runFIFO({
  required List<PaginaDeMemoria> matrizSWAP,
  required List<PaginaDeMemoria> matrizRAM,
  required int pointer,
  required int instructionNumber,
}) {
  matrizRAM[pointer] =
      matrizSWAP.singleWhere((page) => page.i == instructionNumber);
  pointer = (pointer + 1) % 10;
}

void runFIFOSC({
  required List<PaginaDeMemoria> matrizSWAP,
  required List<PaginaDeMemoria> matrizRAM,
  required int pointer,
  required int instructionNumber,
}) {
  while (true) {
    // Verifica o bit de acesso (R) da página apontada pelo ponteiro
    var pageToReplace = matrizRAM[pointer];
    if (pageToReplace.r == 0) {
      // Se o bit de acesso for 0, substitua a página e ajuste o bit de acesso
      matrizRAM[pointer] = matrizSWAP[instructionNumber - 1];
      matrizRAM[pointer].r = 1;
      pointer = (pointer + 1) % matrizRAM.length; // Avance o ponteiro
      break;
    } else {
      // Se o bit de acesso for 1, ajuste o bit de acesso e continue procurando
      pageToReplace.r = 0;
      pointer = (pointer + 1) % matrizRAM.length; // Avance o ponteiro
    }
  }
}

void runNRU({
  required List<PaginaDeMemoria> matrizSWAP,
  required List<PaginaDeMemoria> matrizRAM,
  required int instructionNumber,
}) {
  // Divida as páginas da matriz RAM em 4 classes com base nos bits R e M
  List<List<PaginaDeMemoria>> classes = [
    [], // Classe 0: R=0, M=0
    [], // Classe 1: R=0, M=1
    [], // Classe 2: R=1, M=0
    [], // Classe 3: R=1, M=1
  ];

  for (var page in matrizRAM) {
    if (page.r == 0 && page.m == 0) {
      classes[0].add(page);
    } else if (page.r == 0 && page.m == 1) {
      classes[1].add(page);
    } else if (page.r == 1 && page.m == 0) {
      classes[2].add(page);
    } else if (page.r == 1 && page.m == 1) {
      classes[3].add(page);
    }
  }

  // Escolha aleatoriamente uma página da classe não vazia de menor prioridade (classe 0, 1, 2, 3, nessa ordem)
  for (int i = 0; i < classes.length; i++) {
    if (classes[i].isNotEmpty) {
      int randomIndex = random.nextInt(classes[i].length);
      int indexInRam = matrizRAM.indexOf(classes[i][randomIndex]);
      matrizRAM[indexInRam] = matrizSWAP[instructionNumber - 1];
      break;
    }
  }
}

void runCLOCK({
  required List<PaginaDeMemoria> matrizSWAP,
  required List<PaginaDeMemoria> matrizRAM,
  required int pointer,
  required int instructionNumber,
}) {
  while (true) {
    var currentPage =
        matrizRAM[pointer]; // Página apontada pelo "ponteiro do relógio"
    if (currentPage.r == 0) {
      // Se o bit de acesso (R) for 0, substitua a página e ajuste o bit de acesso
      matrizRAM[pointer] = matrizSWAP[instructionNumber - 1];
      matrizRAM[pointer].r = 1;
      pointer =
          (pointer + 1) % matrizRAM.length; // Avance o "ponteiro do relógio"
      break;
    } else {
      // Se o bit de acesso (R) for 1, ajuste o bit de acesso e continue procurando
      currentPage.r = 0;
      pointer =
          (pointer + 1) % matrizRAM.length; // Avance o "ponteiro do relógio"
    }
  }
}

void runWSCLOCK({
  required List<PaginaDeMemoria> matrizSWAP,
  required List<PaginaDeMemoria> matrizRAM,
  required int pointer,
  required int instructionNumber,
}) {
  // Substituição de página usando WS-CLOCK (Relógio)
  while (true) {
    // Verifique o bit de acesso (R) da página apontada pelo ponteiro
    var currentPage = matrizRAM[pointer];
    if (currentPage.r == 0) {
      // Se o bit de acesso for 0, substitua a página e ajuste o bit de acesso e o tempo de envelhecimento (T)
      matrizRAM[pointer] = matrizSWAP[instructionNumber - 1];
      matrizRAM[pointer].r = 1;
      matrizRAM[pointer].t =
          random.nextInt(9900) + 100; // Atualize o tempo de envelhecimento (T)
      pointer = (pointer + 1) % matrizRAM.length; // Avance o ponteiro
      break;
    } else {
      // Se o bit de acesso for 1, ajuste o bit de acesso e continue procurando
      currentPage.r = 0;
      pointer = (pointer + 1) % matrizRAM.length; // Avance o ponteiro
    }
  }
}
