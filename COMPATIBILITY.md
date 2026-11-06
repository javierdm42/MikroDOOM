# Compatibilidad de la versión 1.1

## Consola en primera persona y acompañamiento E1M1

Probada en el hEX RB750Gr3 con RouterOS 6.44.1 stable mediante la consola interactiva por SSH (PTY). También se probó directamente WinBox 4.5 → New Terminal en Windows contra ese mismo hEX. Se observaron los colores de primer plano y fondo, el guardia en perspectiva y la barra de vida. Dos disparos redujeron el cargador de 6 a 4, eliminaron al guardia y otorgaron 100 puntos. Q devolvió el prompt. En puertos o clientes que muestren caracteres de escape, C cambia a texto plano.

- **Movimiento y combate.** La suite del motor incluye avanzar hacia la mira, retroceder sin perder el rumbo, girar y desplazarse de lado. Se probaron en partida el disparo, la eliminación del primer guardia, la recogida de munición, la pausa y las tres vistas. El visor usa 21 rayos. La profundidad máxima es de 14 casillas en color y 12 en texto sencillo. Hay cuatro orientaciones. El arma se balancea al caminar y presenta destello al disparar.
- **Tiempo.** Se comprobó que el turno avanza al soltar el teclado en primera persona y se congela en pausa. El modo táctico conserva el avance por acciones. El bucle espera teclas con timeout hasta el siguiente evento. La música se calcula dentro del mismo trabajo de consola y cada tono tiene duración finita.
- **Partitura.** Se comprobó el blob Git `6a78b4d9b53360ff88e707eb314aba5f5d4a19c1` del archivo indicado. En el PC se expandieron sus bucles, se validó cada línea y se compararon los 710 eventos originales con la decodificación de la tabla entregada. Hay 30 combinaciones distintas de frecuencia, longitud e intervalo. Las frecuencias van de 160 a 1567 Hz. Una vuelta tiene 83,08 s de intervalos nominales. En el hEX, la opción 5 de pruebas recorre la introducción y comprueba las 16 notas emitidas. El timbre y el volumen siguen pendientes de escucha presencial. [Fuente de E1M1 para MikroTik](https://github.com/bdallen/NetworkScripts/blob/master/Mikrotik%20Scripts/Random/Doom%20E1M1.txt)
- **Acceso de consola.** Los scripts de la versión instalada llevan la marca `doom-native/1.1/6.44.1`. Q cierra la sesión. P pausa también el acompañamiento. B conmuta la pista y M controla todo el audio. Los límites son 900 entradas reales y 30 minutos de sesión, comprobados entre iteraciones, con cierre a los 90 segundos sin pulsaciones. Los timeouts musicales no cuentan como entradas del usuario.

## Resultado de la partida y coste observado en 1.1

La campaña terminó con **1.650 puntos en Marine**. Se enviaron las acciones de combate y movimiento desde el visor en primera persona y se consultó el mapa entre acciones. En una sesión independiente con el audio activado, la consola mostró al guardia y la munición en el mismo pasillo, recibió dos disparos, siguió emitiendo notas durante la espera, silenció la música en pausa y la reanudó al volver. La salida dejó cero trabajos del proyecto. Las huellas comparadas de configuración operativa coincidieron con la referencia.

| Ventana del hEX, una lectura por segundo | Muestras | CPU mediana | CPU mín.–máx. | Mínimo de RAM libre |
|---|---:|---:|---:|---:|
| Sin partida | 8 | 0 % | 0–7 % | 222.81 MiB |
| Visor con E1M1 y actualizaciones de la partida | 12 | 6 % | 1–12 % | 221.98 MiB |

CPU y RAM corresponden al equipo completo. La ventana de música cubre parte de una partida y sus cambios de estado. El ritmo y el volumen percibidos requieren comprobación junto al equipo.

## Medición del visor en color

En una sesión SSH adicional del mismo hEX se verificaron la escena de color, la conmutación C a texto, V al mapa y Q para salir. Quedaron cero trabajos del juego. Con una lectura cada segundo durante ocho segundos por condición, la CPU del equipo en reposo tuvo una mediana de 0 % y un máximo de 7 %. Con el visor de color, E1M1 y enemigos activos, la mediana fue del 10 % y el máximo del 15 %. La memoria libre mínima durante el juego fue de 222,08 MiB. Son mediciones de todo el router. El modo de color cuesta más CPU que la vista táctica.

## Registro histórico de la versión 1.0

Las mediciones y detalles que siguen corresponden a la primera versión, con el visor de 17 rayos y audio solo de efectos.


**Equipo ensayado el 5 de noviembre de 2026 desde el PC de control.** MikroTik hEX, identificado por RouterOS como `RouterBOARD 750G r3`, arquitectura MMIPS, RouterOS `6.44.1 (stable)`, build del 13 de marzo de 2019. El equipo reportó cuatro hilos a 880 MHz, 256 MiB de RAM y 16,3 MiB de almacenamiento. Las pruebas de partida usaron SSH con pseudoterminal desde Windows. El reloj del PC dio la fecha de ensayo.

## Evidencia de compatibilidad

El primer prototipo se cargó como script temporal en el hEX. Aceptó dos espacios y dos pulsaciones de D, movió al jugador de la casilla 66 a la 68, eliminó a un guardia y concedió munición. Se retiraron el script y su archivo antes de instalar la campaña.

| Función | Observación en el equipo |
|---|---|
| Teclado | `/terminal inkey timeout=2s` devolvió 119 al pulsar w. Un segundo sin tecla devolvió 65535. La partida usa el timeout para cerrar la sesión inactiva. |
| Texto y ANSI | El cliente SSH recibió los bytes ESC [ 2 J y ESC [ H emitidos por `:put "\1B[2J\1B[H"`. Se capturaron mapas completos, recortados y el visor. El borrado visual depende del emulador de terminal. C permite alternarlo y la salida predeterminada usa texto normal. |
| Beeper | Ejecutados en el hEX los diez patrones de 110 a 1600 Hz y pulsos de 12 a 36 ms. El script llegó al prompt al finalizar. Se ejecutó también un disparo con sonido activado en partida. **Audición y volumen pendientes de comprobación presencial.** |
| Funciones y memoria | Los módulos se registran al importar. El juego lee `source` de su repositorio de scripts y compila las funciones una vez por sesión. Se comprobó que los literales de arrays de v6 pueden conservar mutaciones entre llamadas. El cargador copia las listas de enemigos y el visor crea filas nuevas para cada imagen. |
| Terminación | Q devuelve el prompt. El comando de emergencia retiró solo el trabajo del juego y la primera terminal mostró `interrupted`. Al dejar abierta la pantalla inicial, la sesión cerró tras 90,0 s de inactividad y el recuento de trabajos del juego volvió a cero. |
| Hardware y versión | El fabricante especifica beeper para el RB750Gr3 y publicó 6.44.1 como versión estable. El manual de scripting sirve de referencia general. La compatibilidad de las funciones anteriores se comprobó sobre esta instalación. [Ficha del hEX](https://mikrotik.com/product/RB750Gr3) · [Publicación de 6.44.1](https://forum.mikrotik.com/t/v6-44-1-stable-is-released/128588) · [Manual de scripting](https://help.mikrotik.com/docs/spaces/ROS/pages/47579229/Scripting) |

## Pruebas estáticas y simuladas en el PC

- **Análisis estático.** Se comprobó la codificación ASCII de los seis RSC, el perímetro cerrado de cada mapa y las dimensiones de las doce filas. Se revisaron los comandos de configuración, el alcance local del estado y los límites de los bucles.
- **Simulación de conectividad.** Una búsqueda en anchura sobre las filas entregadas confirmó en los tres mapas que la llave es alcanzable desde el inicio, que la puerta cerrada separa la salida y que al abrirla se puede llegar a X y a todos los puntos de aparición. Casillas alcanzables con puerta cerrada/abierta: 143/277, 156/259 y 120/266.
- **Partida dirigida desde el PC.** El controlador leyó el mapa impreso y envió teclas por SSH a velocidad de juego. El movimiento, las colisiones, la IA, el combate y las transiciones los ejecutó el hEX. Las pruebas de estado de la tabla siguiente usaron estados preparados en RAM para aislar casos concretos.

## Pruebas funcionales en el hEX

| Caso | Cómo se verificó | Resultado |
|---|---|---|
| 1. Ejecución en 6.44.1 | Importación, lanzamiento desde `/system script run` y suite 1 | Siete scripts instalados. `PASS motor`. |
| 2. Audio | Suite 4 y disparo con M activado | Diez efectos completados. Escucha presencial pendiente. |
| 3. Teclado | Tecla individual, espera sin tecla y campaña | Códigos decimales y timeout reconocidos sin Enter. |
| 4–5. ASCII y borrado | Captura de salida de los tres modos y bytes ANSI | Mapa, HUD, símbolos y secuencias presentes. La interpretación gráfica se puede repetir con la suite 3. |
| 6–7. Movimiento y colisiones | Suite 1 y recorrido completo | Desplazamiento de una casilla, bloqueo por paredes y puertas, apertura con K y E. |
| 8. Disparos | Suite 1 y campaña | Descuento de cartuchos, impacto, baja, tiro fuera de alcance y tiro detenido por puerta. |
| 9. Enemigos | Suite 1 y mapa por turnos | Aproximación de un guardia, ataque adyacente, corredores, tanques y jefe en campaña. |
| 10. Salud y munición | Suite 1 y partida con daño | Armadura antes que vida, botiquín de 60 a 95, recogida de A y recarga desde reserva. |
| 11. Transiciones | Campaña íntegra en dificultad Marine | Dos transiciones, nueve enemigos eliminados y **VICTORIA con 1.650 puntos**. En otra partida se alcanzó **GAME OVER** con vida 0 en el turno 31. |
| 12. Sesión y salida | Pausa, Q, segunda sesión, retirada de job | Pausa y reanudación correctas. La segunda sesión fue rechazada y quedó un solo juego. La retirada desde otra terminal dejó cero trabajos del juego. |
| 13. Configuración operativa | Huellas de exportaciones compactas con datos sensibles ocultos, antes y después, sin cabeceras volátiles | Coincidencia final de las doce comparaciones: interfaces, firewall, NAT, rutas IPv4, servidor y cliente DHCP, DNS, servicios IP, direcciones, pools, usuarios y scheduler. Una lectura intermedia de DHCP dio una huella distinta y la relectura coincidió con la inicial. |
| 14. Retirada y residuos | Desinstalación, recuento y reinstalación | Cero scripts marcados y cero jobs del juego tras desinstalar. Después se reinstalaron los siete scripts para el usuario. Cero variables globales del proyecto. |

La importación repetida con nombres ocupados se rechazó antes de instalar. El desinstalador rechazó la retirada mientras había una partida abierta. Usa el instalador como único punto de entrada para registrar los módulos.

## Presupuesto y medición

Presupuesto operativo propuesto para este equipo: **hasta 5 puntos porcentuales adicionales de CPU mediana** en juego 2D por turnos y **hasta 2 MiB menos de memoria libre** respecto de la mediana en reposo. Son objetivos para una sesión. RouterOS mide la carga del equipo completo y comparte los recursos con el tráfico y la propia conexión SSH.

| Ventana | Muestras, una por segundo | CPU mediana | CPU mín.–máx. | RAM libre mediana | RAM libre mínima |
|---|---:|---:|---:|---:|---:|
| Sin partida | 8 | 0 % | 0–8 % | 224,57 MiB | 224,57 MiB |
| Juego 2D, dificultad Marine, sin audio | 16 | 1 % | 1–19 % | 223,84 MiB | 223,81 MiB |

La diferencia entre medianas fue de **1 punto de CPU**. La peor diferencia de RAM libre respecto a la mediana inicial fue de **0,77 MiB**. El pico de CPU del 19 % incluye actividad de todo el router. La muestra es breve y corresponde al inicio del recorrido. El visor pseudo-3D, el tráfico máximo, la latencia de reenvío y el uso por proceso quedaron fuera de la medición.

Para repetir una lectura pequeña desde otra terminal, ejecuta el bloque una vez en reposo y otra durante una partida ordinaria:

```routeros
:for i from=1 to=8 do={ :put ([/system resource get cpu-load] . "," . [/system resource get free-memory]); :delay 1s }
```

## Límites de ejecución y reproducción

- Una sola partida en primer plano, hasta 900 entradas y 30 minutos comprobados al inicio de cada iteración. Una espera de teclado ya iniciada puede extender el límite hasta 90 s. Cada espera es bloqueante. Hay una pausa de 150 ms entre entradas. Los enemigos y el render solo se actualizan cuando corresponde.
- El visor usa 17 rayos de ocho pasos como máximo. La IA usa distancia Manhattan y pasos cardinales con colisión. Puede detectar al jugador detrás de una pared y quedarse al otro lado. Las paredes y puertas cerradas bloquean el movimiento y el disparo. La salida exige que caigan todos los enemigos.
- Las pruebas se hicieron en SSH interactivo. En un cliente que muestre los códigos de borrado, usa el modo de texto. En una terminal sin entrada interactiva, abre una sesión SSH con PTY.
- El estado vive en variables locales y se pierde al salir. La instalación y desinstalación escriben el repositorio de scripts. Durante la partida el código solo consulta la hora de actividad, el trabajo y las fuentes necesarias, lee teclas, imprime y usa el beeper si está activo.
- Para repetir las pruebas 12–14, usa las órdenes del README. Para comparar configuración, toma `/interface export compact hide-sensitive`, `/ip firewall export compact hide-sensitive` y las exportaciones equivalentes de las ramas de la tabla antes y después. Compara en el PC omitiendo las cabeceras con fecha. Las consultas de jobs y scripts pueden filtrarse por nombre y comentario.
