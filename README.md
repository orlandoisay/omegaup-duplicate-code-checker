# Instrucciones de uso

## Requisitos
Para poder correr los scripts de este repo se necesita contar un token de API de OmegaUp. Los pasos para generar un nuevo token son:
 1. En OmegaUp, navegar a la página de perfil.
 2. Hacer click en el botón "Adminstrar claves de la API".
 3. Ingresar un nombre para el token.
 4. Hacer click en "Agregar token".

> **_Nota:_** El token solo aperece una vez. Además, hay que considerar que cada token tiene un límite de 1000 peticiones por hora. Esto es relevante si el concurso tiene demasiados envíos, puesto que para descargar cada envío se necesita hacer una petición distinta.

## Scripts
Todos los scripts estan escritos en Windows PowerShell.

### Generate-Folders.ps1
- Este script se encarga de obtener la lista de los diferentes problemas presentes en el concurso, y generar carpetas para almacenarlos.
- Para que el script funcione se necesitan editar las primeras líneas, donde se declaran el token de la API, y el alias del concurso.
- El script además hace un paso de "normalización", donde todos los envíos a cualquier variante de C++ y Python son agrupadas respectivamente.

La estructura de las carpetas debe quedar de la siguiente forma:

```
> RunsData
> -| alias-problema-1
> ---| cpp
> ---| cs
> ---| java
> ---| py
> -| alias-problema-2
> ...
```

#### Ejemplo de uso
```
> .\Generate-Folders.ps1
```

### Generate-Submissions.ps1
- Este script genera un archivo CSV (Submissions.csv) con la lista de todos los envíos realizados en el concurso.
- De igual forma, se necesitan editar las primeras líneas para definir el token de la API, y el alias del concurso.
- Dado que la API de OmegaUp solo regresa una lista de 100 envíos por petición, este script realiza múltiples peticiones hasta no encontrar más registros.

#### Ejemplo de uso
```
> .\Generate-Submissions.ps1
```

El formato de Submissions.csv es el siguiente:

```
guid,username
21c58380926a194432a6dbd4d56ebe4d,c23:u-49
31a84bfa5aaeb1eb7fcab236bfa4f115,c23:u-10
...
```
El guid corresponde al id que OmegaUp utiliza para identicar cada envío, y se puede encontrar en la lista de envíos, a la derecha de la columna "Fecha y hora".

### Fetch-Single-Source.ps1
- Este script toma como parámetro un número que representa el índice del envío en "Submissions.csv"
- También necesita el token de OmegaUp para poder descargar el código fuente.
- De igual forma que el script anterior, el lenguaje de programación se "normaliza" agrupando todos los envíos de C++ en una sola categoría.
- Una vez descargado el código, se revisan el veredicto y puntaje, y éstos son utilizados para decidir en que ruta almacenarlo.
- El nombre del archivo sigue el formato: `${guid}_${userid}`.

#### Ejemplo de uso
```
# Descargar el 25-esimo envio en Submissions.csv
> .\Fetch-Single-Source.ps1 25 
```

Debajo se muestra un ejemplo de como se vería dos envíos uno del usuario `c23u-59` en `C++` con un `AC`, y otro del usuario `c23u-471` en `C#` con un `TLE` de `75` puntos:

La estructura de las carpetas debe quedar de la siguiente forma:

```
> RunsData
> -| alias-problema-1
> ---| cpp
> -----| AC100
> -------| abdf733f7d1d5cdfb3a938bee8195a79_c23u-59
> ---| cs
> -----| TLE75
> -------| a06d5fd89acbfbaf58e7732f4419d1a2_c23u-471
> ---| java
> ---| py
> -| alias-problema-2
> ...
```

> **_Nota:_** No es necesario correr este script directamente. El siguiente se encarga de correrlo en bloque.

### Fetch-Batch-Source.ps1
- Para evitar correr el script anterior manualmente, se puede utilizar este script.
- Toma dos parámetros, los índices inferior y superior de un rango de envíos a descargar.

#### Ejemplo de uso
```
# Descarga los primeros 100 envíos
> .\Fetch-Batch-Source.ps1 1 100 
```

> **_Nota:_** Debido al límite de OmegaUp de 1000 peticiones por hora, no es recomendable descargar rangos muy grandes de envíos. Es buena idea revisar en https://omegaup.com/profile/#manage-api-tokens la cantidad restante de peticiones antes de correr este script.

### Compare-Files.ps1
- Este es el script principal. Su función es comparar pares de archivos (sin considerar espacios vacíos) para detectar si son idénticos.
- El script genera un hash único para cada código fuente. De modo que si dos envíos distintos generan el mismo hash, entonces hay una muy alta probabilidad de plagio.
- Al haber agrupado los envíos por problema/lenguaje/veredicto, se minimizan las comparaciones requeridas.
- La salida de este script es un archivo csv llamado "MatchesData.csv" con las siguientes columnas
  - Alias del problema
  - Lenguaje
  - Veredicto
  - Hash del código
  - Nombre del archivo (en el formato `${guid}_${userid}`)
 
El siguiente es un ejemplo de como se ve el contenido de "MatchesData.csv". Se puede observar que:
- Los usuarios 309 y 325 tienen códigos idénticos entre sí para el problema A.
- Los usuarios 292 y 309 tienen códigos idénticos entre sí para el problema A.
- Los usuarios 548, 545 y 292 tienen códigos idénticos entre sí para el problema B.

```
problema-a,cpp,WA0,64762E293F506108009CA4ADECB7A9C74F0B6DB84764E8B9E3B31BB0B570BFBC,ab6c53b78888e1ca5416a6a533014fcf_usuario-309
problema-a,cpp,WA0,64762E293F506108009CA4ADECB7A9C74F0B6DB84764E8B9E3B31BB0B570BFBC,af4f5a4655ce2e388cffe462960b3864_usuario-325
problema-a,cpp,WA0,E43A3A11D993F2D001D787FFCA4FDCFD48D651D1A318718F96FC6E0727AC23C0,354693f9b8010a0b45fcfe4275df0d16_usuario-292
problema-a,cpp,WA0,E43A3A11D993F2D001D787FFCA4FDCFD48D651D1A318718F96FC6E0727AC23C0,6ec81c3517e5803aa76102d0dd99405c_usuario-309
problema-b,cpp,AC100,3483C00B15D6589D03AC8D72F595B02F970492CE7B513E144531C29FCC4D9E3F,985dca0ed7e50c701e48c77a80e51a10_usuario-548
problema-b,cpp,AC100,3483C00B15D6589D03AC8D72F595B02F970492CE7B513E144531C29FCC4D9E3F,bec35f7d8bc8d31102c251be0d5efd17_usuario-545
problema-b,cpp,AC100,3483C00B15D6589D03AC8D72F595B02F970492CE7B513E144531C29FCC4D9E3F,d077e93047baf1a61f3fefe68ccc085b_usuario-292

```

#### Ejemplo de uso
```
> .\Compare-Files.ps1
```

> **_Nota:_** Con el archivo csv generado, es mejor usar Excel o Google Spreadsheets para analizar los datos.
  
