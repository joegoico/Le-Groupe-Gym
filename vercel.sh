#!/bin/bash

# 1. Descargar el SDK de Flutter si no existe en el contenedor
if [ ! -d "flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b stable
fi

# 2. Agregar Flutter al PATH de forma temporal
export PATH="$PATH:`pwd`/flutter/bin"

# 3. Habilitar soporte web
flutter config --enable-web

# 4. Compilar para producción
flutter build web --release