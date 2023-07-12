# Afinidades de pods.

## Quién decide en quñe nodo se despliega un pod?

El Scheduler de kubernetes

## En qué se basa para tomar esa decisión?

En los request de recursos de CPU y MEMORIA

Las afinidades son reglas que podemos dar al scheduler para influir en su decisión.

Tenemos 3 tipos de reglas de afinidad:
- Afinidad a nodos          [ Preferiblemente u Obligatoriamente ] pon este pod en ciertos nodos (que cumplan unas características)
                            Cluster: Ciertos nodos que son Raspberry PIs
                            Tengo unas máquinas con GPUs
                            Prefiero ciertos procesos (prods) que corran en máquinas con disco dura más rápido o CPUs más rápidas
- Afinidad a pods           [ Preferiblemente u Obligatoriamente ] pon este pod en ciertos nodos que también tengan tal otro pod
* Antiafinidad a pods       [ Preferiblemente u Obligatoriamente ] pon este pod en ciertos nodos que no tengan tal otro pod
        Siempre queremos de forma preferida, que un pod genere antiafinidad consigo mismo

Para las afinidades tenemos 3 etiquetas:
- nodeName          Como si no existiera
- nodeSelector      Me da afinidades con nodos... de forma básica (pocas opciones)
- affinity          Me permite de todo !!! EL BUENO !

# HELM 

Un chart de HELM es una plantilla de despliegue personalizable de una aplicación.


$ helm pull --untar oci://registry-1.docker.io/bitnamicharts/mariadb

# Placeholders en HELM

Se escriben entre dobles llaves: {{ VALOR QUE SACO DE ALGUN SITIO }}

## De donde puedo sacar valores?

Vamos a usar una sintaxis... como si fueran carpetas de un filesystem. Solo que en lugar de usar el slash /, usamos un PUNTO: .

.Release    Esta información la obtiene helm al solicitar la INSTALACION de un chart
                $ helm install [NOMBRE DE RELEASE] CHART <args>
                       upgrade                         -f custom.values.yaml
                                                       -n en que namespace quiero hacer el despliegue
                                                       --create-namespace   Si el namespace no existe, crealo por mi
        .Name = NOMBRE DE RELEASE
        .Namespace = Lo que se haya pasado en el "-n"
        .IsInstall  = Si lo que están ejecutando es un comando Install
        .IsUpgrade  = Si lo que están ejecutando es un comando Install
        .Revision   = Comenzando en 1, cuantas veces se ha aplicado este chart (Install será 1
                        A partir de ahí, cada upgrade, incrementa ese valor
 Values     Acceso al fichero values.yaml que se haya suministrado
            SI QUIERO EN NUESTRO CASO LA MEMORIA LIIMITE DE WP:
                .Values.wordpress.resources.limits.memory
 Chart      Acceso a los datos del fichero Chart.yaml
 Files
 Capabilities
 Template
 
El punto inicial representa el origen de datos de nuestro chart de helm (LA RAIZ)
Y es como si dentro tuviera esas carpetas... 

ESTO NO CUELA: condicion1 and condicion2

and condicion1 condicion2

or