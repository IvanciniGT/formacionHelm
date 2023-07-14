Cuando ejecutamos un char de HELM, tenemos siempre a nuestra disposición lo que se denomina un CONTEXTO.

Qué es un contexto?
El contexto no es sino un conjunto de datos clave/valor a los que podemos acceder mediante 2 sintaxis:

    $.      < El contexto raiz en el que nos encontramos... Equivalente a, en un sistema dde archivos, escribir /path
                    Estando en la carpeta /etc
                    /etc/fstab              $.etc.fstab
    .       < El contexto en el que nos encontramos         Equivalente a, en un sistema de archivos, escribir ./path
                    Estando en la carpeta /etc
                    ./fstab                 .fstab
    
Los valores, a su vez, pueden contener más claves/valor... y en ese caso seguimos usando un PUNTO: . para bajar de nivel

    Sería el equivalente a usar / en medio de un path para descender entre carpetas.
                    Estando en la carpeta /home, quiero acceder a /home/ivan/datos
                    ./ivan/datos            .ivan.datos
                    /home/ivan/datos        $.home/ivan/datos

Para cambiar el contexto, usamos {{ with NUEVO_CONTEXTO }}

    Sería el equivalente a hacer un cd NUEVA_CARPETA
    
Lo que hace HELM cuando arranca un char es crear una estructura navegable de datos en memoria RAM

                                                $ < (1)
                                                |
        ------------------------------------------------------------------------
        |           |               |           |               |           |
        Values      Release (2)     Chart       Capabilities    Files       Template
                       |               |
                       |               -------------------
                -------------           |             |
                |           |           appVersion    version
                Name        Namespace

Esa estructura de datos se crea fusionando datos de distintas fuentes:
- El contenido del fichero Chart.yaml
- Los argumentos que se pasan desde linea de comandos a helm
- El contenido del fichero values.yaml que se suministre
- Las características del cluster de kubernetes con el que estamos trabajando
- ...

Al arrancar HELM, además de crear esa estructura de datos, nos posiciona en una ubicación de la misma... en el raiz: $

Inicialmente, ya que me coloca en $, para saber el nombre de la release  (1)
(que es un dato que se pasa a helm al hacer una instalación por linea de comandos),
podría usar:

    .Release.Name
    $.Release.Name
    
Yo puedo, en las plantillas cambiar la ubicación en la que me encuentro dentro del contexto... con "with"
Si cambio por ejemplo a $.Release

    {{ with $.Release }} o {{ with .Release }}

Si ahora quiero acceder al OMBRE DE LA RELEASE:

    .Name
    $.Release.Name

---

El follón viene con los templates que definimos en los archivos .tpl.
Esos templates tiene un CONTEXTO diferente al contexto global que crea HELM... el de arriba.
A un template cuando se le invoca, mediante {{ include TEMPLATE CONTEXTO}}, se le pasa un CONTEXTO.
Ese será el contexto al que puede acceder el template... y por defecto se nos ubica en la RAIZ de ese contexto.

    Es como cuando en linux usamos el comando chroot
    
Si por ejemplo, llamo a un template con la sintaxis:

    {{ include PLANTILLA $.Release }}

Desde dentro de la plantilla... si pongo ahora $, a qué me estaría refiriendo? $.Release
Es decir el contexto de la plantilla sería:

                        $ (que sería el $.Release del conetxto global) (1)
                        |
            --------------------------
            |                       |
            Name                    Namespace

De forma que para acceder al nombre de la release desde la plantilla, podría escribir?

    .Name
    $.Name
    
El contexto de las plantillas es DIFERENTE al global... No tiene si quiera porque ser un subconjunto de él.
De hecho, cuando a una plantilla le paso un subconjunto del global, lo que hace helm es una copia de esa rama del arbol de datos.

También puedo CREAR MI PROPIO CONTEXTO que pasar a la plantilla.
El contexto no es sino un conjunto de CLAVES / VALOR. Esos conjunto de claves/valor es lo que en :
- YAML llamamos un mapa de datos


        clave1: valor1
        clave2:
            subclave1: valor11
            subclave2: valor22

- En HELM le llamos diccionario


        dict "clave1" "valor1" "clave2" (dict "subclave1" "valor11" "subclave2" "valor22")

- En las bash le llamos ARRAY ASOCIATIVO 


        $ declare -A arrayAsociativo
        $ arrayAsociativo[clave1]=Valor1
        $ arrayAsociativo[clave2]=otroArrayAsociativo

- En JAVA le llamamos un Map

- En Javascript (JSON = JavaScript Object Notation) le llamamos Object


    {
        "clave1": "valor1",
        "clave2": {
            "subclave1": "valor11",
            "subclave2": "valor22",
        }
    } 



Podría crear mi propio contexto para pasarlo a una plantilla:

    {{ include "PLANTILLA" (dict "clave1" "valor1" "clave2" (dict "subclave1" "valor11" "subclave2" "valor22")) }}
    
    Otra opción sería:

    {{ $miContexto := (dict "clave1" "valor1" "clave2" (dict "subclave1" "valor11" "subclave2" "valor22")) }}
    {{ include "PLANTILLA" $miContexto }}

Dentro de la plantilla, lo que tendría es:

            $ (1)
            |
    -----------------------------
    |                   |
    Clave1           Clave2 (2)
                        |
                -----------------    
                |               |
                subclave1       subclave2

Para acceder a subclave1, podría escribir:

        .clave2.subclave1
        $.clave2.subclave1

Incluso podría:

        {{ with .clave2 }} o {{ with $.clave2 }} (2)
    
        y luego

        .subclave2
        $.clave2.subclave1
---

Ayer, para la plantilla que valida un dato de bytes, definimos nuestro propio contexto

    field: "campo"              El campo que se procesa... para poder sacarlo cpor consola en caso de error
    value: "3Gi"                El valor a validar
    required: true

    dict "field" "campo" "value" "3Gi" "required" true

                    $
                    |
    ---------------------------------
    |               |               |
    field           value           required

En otros lenguajes de programación, cuando llamamos a una función (que sería el equivalente a lo que en HELM llamos una plantilla)
le pasamos argumentos (parámetros)... Cuántos? los que yo haya definido.. es mi función y defino los que me da la gana.

PUES EN HELM NO... y esa es la mierda del HELM!!!!

En HELM al definir una plantilla (el equivalente a una función), solo se le puede pasar 1 argumento = CONTEXTO

---

En nuestro caso, tenemos creada una plantilla llamada resources...
Cúantos argumentos se le pasan a esa plantilla ahora mismo? 
1, ahora y siemrpe... en HELM no hay otro opción, VAYA MIERDA DE HELM !!!
Ese uno es lo que llamamos el contexto.

Qué contexto estábamos pasando?

                    {{- include "resources" .Values.mariadb.resources }}

Es decir, un subconjunto del contexto global que genera HELM al arrancar...
El valor que tiene ahora mismo ese contexto es:

        requests:
                cpu:    1
                memory: 3Gi
        limits:
                cpu:    200m
                memory: 3Gi

Tengo ahí el dato que necesito del campito??? Dónde pone ahí que es mariadb o wp? PROBLEMON !!!

Qué me toca hacer? Definir otro contexto, que además de esos datos, incluya el nombre del campito de turno!

¿Qué estructura de contexto quiero generar? Esto lo repsondo YO... es mi decisión, mientras le haga llegar toda la info:

        OPCION 1
            resources:
                requests:
                        cpu:    1
                        memory: 3Gi
                limits:
                        cpu:    200m
                        memory: 3Gi
            field: "mariadb"

                    {{- include "resources" (dict "resources" .Values.mariadb.resources "field" "mariadb" ) }}

        OPCION 2
            requests:
                    cpu:    1
                    memory: 3Gi
            limits:
                    cpu:    200m
                    memory: 3Gi
            field: "mariadb"

                    MIERDA DE SOLUCION... modifico el contexto global original... y eso no quiero hacerlo:
                        {{ $_ := set .Values.mariadb.resources "field" "mariadb" }}
                        {{- include "resources" .Values.mariadb.resources) }}
                    
                    GUAY 
                        {{- include "resources" merge .Values.mariadb.resources (dict "field" "mariadb" )) }}



Ayer, en la delos bytes v1, sólo pasaba el valor...

        CONTEXTO:
            3Gb

En v2:

        CONTEXTO:
            value: 3Gb
            field: "mariadb"

