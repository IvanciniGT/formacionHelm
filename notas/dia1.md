
# HELM?

- Controlar el ciclo de vida de una aplicación en Kubernetes:
    - Despliegue de una app... y de sus actualizaciones
    - Desinstalación
- Herramienta para crear plantillas de despliegues de aplicaciones en Kubernetes  > Kustomize

 
## Por qué quiero crear plantillas de despliegues de aplicaciones en Kubernetes?

### Una app la desplegaré un montón de veces

- Distintos entornos (prod, pre, des...)
- Distintas versiones a lo largo del tiempo
- Distintos clientes

Una cosa es saber de contenedores (Docker, podman, containerd...) y otra cosa 
totalmente distinta es desplegar contenedores en un cluster de kubernetes.

Por qué? Cluster de Kubernetes va orientado a un entorno de producción.

## Entorno de producción:

- Alta disponibilidad
- Escalabilidad
- Seguridad

En los entornos de producción manejamos:
- Balanceadores de carga
- Proxies reversos
- Firewalls
- Entradas en servidores DNS

# Contenedor

Entorno aislado dentro de un SO con kernel Linux donde ejecuto procesos.

Los contenedores los creamos desde imágenes de contenedor.

Cuando trabajamos con contenedores hacemos uso de volumenes.

## Imagen de contenedor

Es un fichero comprimido (tar) que contiene:
- Una estructura de carpetas compatible con POSIX: bin/ opt/ var/ home/ ...
- Una aplicación YA INSTALADA DE ANTEMANO y PRECONFIGURADA por alguien.
- Adicionalmente vienen algunos programas adicionales:
    - dependencias / librerias requeridas por la app
    - otros programas que puedan serme de utilidad: bash, ls, mkdir, chmod
Ese fichero va acompañada de algunos metadatos adicionales:
- Cuál es el comando que debe ejecutarse cuando se inicie un contenedor creado desde esta imagen
- Que valores van a tomar por defecto las variables de entorno en ese contenedor.
- ...

## Volumen

Un punto de montaje en el sistema de archivos de un contenedor, que tendrá persistencia real
fuera del contenedor.

    mount RUTA_LOCAL_DE_MI_FS -> nfs, memoria RAM, cloud, cabina de almacenamiento

Cada contenedor tiene su propio sistema de archivos, independiente del sistema de archivos del host.
/ root del sistema de archivos

### Para qué usamos los volúmenes en un contenedor?

Cuando trabajamos con contenedores hacemos de forma muy habitual una operación que es BORRAR EL CONTENEDOR:
- Escalado: Más entornos paralelos en un cluster que presnten un servicio o menos.
- Si se pasa de recursos y los necesito.
- Cuando quiero cambiar la versión de un software que instalo en el contenedor (imagen)
- Cuando quiero hacer un cambio en la configuración de despliegue (MAS RECURSOS, otras variables de entorno...)
- Si no responde adecuadamente
- Si quiero llevarmelo a otro nodo.. que tengo menos cargado de trabajo.


Usos de los volumenes
- Para almacenar datos de forma externa al contenedor. Así cuando borre un contenedor, no los pierdo.
- Inyectar ficheros / Carpetas dentro del contenedor
- Compartir datos entre contenedores
- Mejorar el rendimiento de ciertas operaciones de lectura/escritura (Persistencia en RAM)
    Contenedor: nginx
            /var/log/nginx/access1.log      50Kbs
                    v      ^
            /var/log/nginx/access2.log      50Kbs
    Contenedor: fluentD, filebeat         >     KAFKA > LOGSTASH > LOGSTASH > ElasticSearch
            
            /var/log/nginx : Persistencia en RAM

# Kubernetes

Kubernetes es una herramienta que va a gestionar mi entorno de producción completo... usando contenedores.

Kubernetes es quién va a gestionar el entorno de producción.

Nosotros le indicamos a Kubernmetes cómo queremos que haga ese trabajo.
Más concretamente le describimos cómo queremos que sea nuestro entorno de producción, es decir, qué queremos en él.

Kubernetes toma decisiones y acciones para conseguir que mi entorno de producción en todo momento sea como yo quiero que sea.

Cluster de máquinas: Mi cluster de kubernetes
    ControlPlane            - Es donde tenemos desplegado propiamente kubernetes
        - Máquina 1
            crio | containerd
        - Máquina 2
            crio | containerd
        - Máquina 3
            crio | containerd
    Trabajadores            - Es donde desplegaremos nuestras apps
        - Máquina 1
            crio | containerd
        - Máquina 2
            crio | containerd
        - Máquina 3
        - ...
        - Máquina 100
            crio | containerd

# Configuración de kubernetes

Cualquier configuración que quiera en mi entorno de producción se la voy a comunicar
a kubernetes mediante la creación de recursos dentro de kubernetes.

Esos recursos que vamos a querer en nuestro entorno de producción (nuestro cluster de kubernetes) los definimos en ficheros YAML.

Kubernetes, out of the box, nos ofrece la posibilidad de configurar unos 25-30 tipos de objetos diferentes.

Luego podemos instalar más TIPOS de objetos adicionales en el cluster, que amplien su funcionalidad.
Esos tipos de objetos vienen definidos en librerías... que tendrán sus versiones.

## Tipos de objetos que podemos crear en un cluster de Kubernetes:

√ Namespace
√ Pod
√ StatefulSet
√ Deployments
√ DaemonSets
√ ConfigMap
√ Secret
√ PersistentVolume
√ PersistentVolumeClaim
√ StorageClass
HorizontalPodAutoscaler.    Autoescalar apps: Si la CPU de los pods del servidor web están por encima del 50%, escala
                                Contenedor1: 55%
                                Contenedor2: 60%
NetworkPolicy               Reglas de Firewall a nivel de red.
ResourceQuotas              Limitaciones a la cantidad de recursos (CPU, memoria...) que pueden usar mis contenedores
LimitRanges                 Limitaciones a la cantidad de recursos (CPU, memoria...) que pueden usar mis contenedores
√ Services (ClusterIP, NodePort, LoadBalancer)
√ Ingress

## Namespace 

Entorno aislado dentro del cluster. Lo usamos para:
- Desplegar distintas apps que no se vean afectadas entre si
    - Distintos clientes
    - Distintas apps
    - Distintos entornos (prod, pre, ...)
- Prácticamente cualquier otro recurso que demos de alta en kubernetes
  se ubicará dentro de un namespace.

## POD

Conjunto de contenedores... que:

- Comparten configuración de red
- Escalan juntos
- Se despliegan en el mismo host:
    - Pueden compartir volumenes locales

    POD 1
        Contenedor: nginx
                /var/log/nginx/access1.log      50Kbs
                        v      ^
                /var/log/nginx/access2.log      50Kbs
        Contenedor: fluentD, filebeat         >     KAFKA > LOGSTASH > LOGSTASH > ElasticSearch
            ^^ Contenedor sidecar
                
                /var/log/nginx : Persistencia en RAM
                
    Instalar Wordpress
    POD 1
        Contenedor1: Servidor web (nginx, apache httpd) + php
    POD 2
        Contenedor2: BBDD: mariaDB | MySQL

### Cúantos pods vamos a crear nosotros en Kubernetes?  CERO, NI UNO 

Quién crea los pods: KUBERNETES

Qué voy a crear yo en Kubernetes (para que Kubernetes cree pods)? PLANTILLAS DE PODS

## Plantillas de pods:

### Deployments

Plantilla de pod + número de réplicas

### StatefulSet

Plantilla de pod + número de réplicas + al menos 1 plantilla de PETICION DE VOLUMEN PERSISTENTE (PVC)

### DaemonSets

Plantilla de pod, de la que kubernetes monta un pod en cada nodo del cluster.
Estos no los usamos habitualmente. 

#### Diferencias entre Deployment y StatefulSet en cuanto al uso

Usaremos Deployments cuando... queramos crear pods desde una plantilla, pero cuando todos esos pods
queramos que sean iguales entre si. Cada pod es reemplable por uno nuevo sin problema.

Usaremos StatefulSet cuando... queramos crear pods desde una plantilla, pero cuando todos esos pods
queramos que no sean iguales entre si. Cada pod no es reemplable por uno nuevo sin problema.
Cada pod tiene su propia personalidad.

    Wordpress
        POD A1: 
            Contenedor 1: servidor web - wordpress
        POD A2: 
            Contenedor 1: servidor web - wordpress
        POD A3: 
            Contenedor 1: servidor web - wordpress
        
        POD B1: 
            Contenedor 1: base de datos - mariadb
        POD B2: 
            Contenedor 1: base de datos - mariadb
        POD B3: 
            Contenedor 1: base de datos - mariadb


Pregunta:
    Si se cae el POD A2, puedo levantar otro pod tranquilamente para hacer el mismo trabajo que antes hacía el POD A2?
        La respuesta a esta pregunta requiere de conocimiento acerca de WORDPRESS 
        La respuesta es SI. => Se resuelve con un Deployment
    
    Si se cae el POD B2, puedo levantar otro pod tranquilamente para hacer el mismo trabajo que antes hacía el POD B2?
        La respuesta a esta pregunta requiere de conocimiento acerca de MARIADB
        La respuesta es un NO ROTUNDO => Se resuelve mediante un StatefulSet


    Wordpress
        Servidor linux 1: 
            servidor web - wordpress - página app1
                nginx / apache - php + wordpress
                    código de ese programa: wordpress
                    datos que maneja propiamente WP: ficheros css, ficheros js, imágenes de mi web, pdfs que he subido para descarga de usuarios
        Servidor linux 2: 
            servidor web - wordpress - página app1
                nginx / apache - php + wordpress
                    datos que maneja propiamente WP: ficheros css, ficheros js, imágenes de mi web, pdfs que he subido para descarga de usuarios
        Servidor linux 3: 
            servidor web - wordpress - página app1
                nginx / apache - php + wordpress
                    datos que maneja propiamente WP: ficheros css, ficheros js, imágenes de mi web, pdfs que he subido para descarga de usuarios
        
        Servidor BBDD 1: 
            base de datos - mariadb
                mariadb
                datos 1
        Servidor BBDD 2: 
            base de datos - mariadb
                mariadb
                datos 2
        Servidor BBDD 3: 
            base de datos - mariadb
                mariadb
                datos 3
    
    
    Webserver 1* - app1   <   Balanceador   <   Clientes
    Webserver 2* - app1   <
    Webserver 3* - app1   <
    
    * Volumen: Almacenamiento en red (cabina, nfs...), con los datos que maneja propiamente WP
    
    datos 1 = datos 2 = datos 3? son iguales entre si?
    Si tengo un cluster de BBDD, cada nodo guarda su propia información o todos guardan la misma información? 
        Cada uno guarda su propia información.... Distinta de los demás.

        Servidor BBDD 1*       : A B
            v ^
        Servidor BBDD 2**      : A C
            v ^
        Otro Servidor BBDD 3***: B C
        
        *, **, *** Son volumenes de almacenamiento diferentes en una cabina, nfs, cloud
        
        Cada nodo de la BBDD debe tener su propio volumen de almacenamiento. 
        Los nodos no son reemplazables entre si. Cada uno tiene su personalidad (Nodo 1, Nodo 2, Nodo 3)
    
    Y me piden que guarde el dato A, dónde se guarda, en todos? NO
    Para qué he montado un cluster de BBDD?
    - HA
    - Escalabilidad <<<< Esta es la única razón para montar un cluster
    
    Si solo necesito HA, no habría montado un cluster... habria montado la BBDD en modo REPLICACION
    
    Las BBDD permiten trabajar en modo:
    - Standalone
    - Replicación: MAESTRO + (n REPLICAS)
    - Cluster: Muchos nodos atendiendo simultaneamente
        Con ese cluster, teóricamente sería capaz de mejorar el rendimiento en un 50%, con respecto a tener una sóla máquina.

        Servidor de BBDD Standalone: A B 
    
    Qué otros sistemas funcionan así? 
    - Cualquier BBDD
    - ElasticSearch
    - Sistemas de mensajería: KAFKA, RABBIT
    
    Todo sistema que almacena datos en cluster funciona de esta forma.
    
    La diferencia grande está en que:
    - Los nginx/wordpress no escriben a la vez en el mismo archivo... lo leen, pero no lo escriben
    - Las bbdd/mariadb trabajan sobre los mismos archivo: TABLA.bbdd 
    
---

Cada imagen de contenedor lleva un software instalado de antemano y preconfigurado.
Esa preconfiguración va a encajar con mis necesidades? RARO 

Al crear un contenedor, partimos de una imagen... y por ende de las preconfiguraciones que ahí vengan...
Pero querré reemplazar todas o al menos parte de esas preconfigruaciones, para adecuarlas a mi entorno.

De qué formas podemos hacer eso al trabajar con contendores:
- Variables de entorno          Los contenedores pueden tener sus propias env
- Archivos de configuración     A los contenedores les puedo inyectar ficheros mediante volumenes

Donde defino en Kubernetes, configuraciones que aplicaré sobre mis contenedores:
- Bien inyectándolas como archivos
- Bien como variables de entorno

Kubernetes tiene 2 Objetos para definir estas configuraciones particulares (datos) que posteriormente poder usar
como valores de variables de entorno o para inyectar ficheros:

## ConfigMap
## Secret

Ambos son iguales entre si... un conjunto de claves/valor
La diferencia entre uno y otro es que los secrets se guardan internamente dentro de kubernetes ENCRIPTADOS.

---

Además de programas que instalamos y configuramos, en cualquier entorno de producción manejamos otro tipo de elementos:
- Balanceadores de carga
- Proxies reversos
- Firewalls
- Entradas en servidores DNS
- ...

Cómo configuramos esas cosas en Kubernetes?

# Service

## ClusterIP

Una IP de balanceo de carga + Entrada en el DNS interno de Kubernetes
OJO: HE dicho una IP DE BALANCEO... no un balanceador de carga

Para qué sirve esto? 
- Para poder acceder de forma sencilla desde un pod a otro pod: Entrada en el DNS: podré usar fqdn
    Si no tuviera esto tendría que usar para las comunicaciones direcciones IPs... que cómodas no son...
    Entre otras cosas, porque a priori no sé que IP va a tener un POD... es más... esa IP puede cambiar con el tiempo
- HA
- Escalabilidad

A todo programa (POD) que no necesite ser accedido desde fuera del cluster, le asociaré un Servicio de tipo ClusterIP.
... en la práctica, cuantos serán éstos? así groso modo... Porcentaje sobre el total de programas que voy a tener en el cluster?
- TODOS... menos 1.

En cualquier cluster de Kubernetes del mundo mundial... y si hay kubernetes en otros planetas o galaxias, igual,
SOLO TENDRE UN SERVICIO QUE SEA ACCESIBLE FUERA DEL CLUSTER (2 si me apurais en casos raros...)

## NodePort

Es un servicio ClusterIP + NAT(redirección de puertos) en la IP pública de todos los nodos del cluster

## LoadBalancer

# Proxy reverso

Dentro de kubernetes recibe el nombre de INGRESS CONTROLLER.
Y es una herramienta que yo tengo que instalar en mi cluster... no viene por defecto.


# Ingress

Un ingress es una REGLA DE CONFIGURACION PARA EL PROXY REVERSO (ingress controller)

---

Servidores en Back end en mi empresa
Servidor 1  \   
Servidor 2  /   Balanceo1        <    Proxy reverso         |     <     Proxy    <          ClienteA
Servidor 3  \                             nginx                         192.168.1.100            192.168.0.133
Servidor 4  /   Balanceo                  reglas de configuración:                               app1.otraempresa.com
Servidor 17 -                               app1.otraempresa.com -> Balanceo1
                                            app2.otraempresa.com -> Balanceo2
                                            app3.otraempresa.com -> Servidor 17

---

Proxy:

Componente de software cuya misión es PROTEGER LA IDENTIDAD DE UN CLIENTE, 
haciendo las peticiones en su nombre.
Ya que hace esto... en las empresas se les suele meter otro tipo de cosas:
- No te voy a ir a las páginas porno que estás currando.

Proxy reverso:

Componente de software cuya misión es PROTEGER LA IDENTIDAD DE UN SERVIDOR BACKEND. Ejemplos:
- Apache httpd
- nginx
- haproxy
- envoy
- traefic

---
    
     192.168.0.50:80  
        http://192.168.0.201:30080
        http://192.168.0.202:30080      app1.miempresa.com=192.168.0.50
        http://192.168.0.203:30080               |                            http://app1.miempresa.com
    Balanceador 192.168.0.50                DNS Externo                 Cliente que quiere acceder a la app1
        |                                        |                            |
--------------------------------------------------------------------------------- red de mi empresa (192.168.0.0/16)
    |
    |= 192.168.0.101 - Nodo1 PlanoControl de Kubernetes
    ||                   |- Scheduler 
    ||
    |= 192.168.0.102 - Nodo2 PlanoControl de Kubernetes
    ||                   |- Kubernetes DNS (interno al cluster) 
    ||                          |- mariadb-service = 10.10.1.1
    ||                          |- app2-service    = 10.10.1.2
    ||                          |- ingress-service = 10.10.1.3
    ||
    |= 192.168.0.103 - Nodo3 PlanoControl de Kubernetes
    ||
    |= 192.168.0.201 - Trabajador 1 del Cluster de Kubernetes
    ||                   |- 10.10.0.2 - POD1 WORDPRESS
    ||                   |                  |- Contenedor1 - app1
    ||                   |                       |- Apache httpd: 80
    ||                   |- 10.10.0.4 - POD INGRESS CONTROLLER (proxy reverso)
    ||                                      |- Contenedor1
    ||                                           |- Nginx: 80
    ||                                                  |- app2.miempresa.com > app2-service:8080  <<< INGRESS
    ||                                                  |- app1.miempresa.com > app1-service:8080  <<< INGRESS
    ||                                                  |- app3.miempresa.com > app3-service:8080  <<< INGRESS
    ||                 Es una máquina Linux... que tendrá en su kernel netFilter:
    ||                      |- 10.10.1.1:3333 > 10.10.0.1:3306                              no tiene gestión de colas
    ||                      |- 10.10.1.2:8080 > 10.10.0.2:80 | 10.10.0.3:80     * Netfilter no es un balanceador completo (nginx).. solo hace redirecciones
    ||                      |- 10.10.1.3:81   > 10.10.0.4:80
    ||                      |- 192.168.0.201:30080 > ingress-service:81
    ||
    |= 192.168.0.202 - Trabajador 2 del Cluster de Kubernetes
    ||                   |- 10.10.0.1 - POD BBDD
    ||                                      |- Contenedor1
    ||                                           |- MariaDB: 3306
    ||                 Es una máquina Linux... que tendrá en su kernel netFilter:
    ||                      |- 10.10.1.1:3333 > 10.10.0.1:3306
    ||                      |- 10.10.1.2:8080 > 10.10.0.2:80 | 10.10.0.3:80  
    ||                      |- 10.10.1.3:81   > 10.10.0.4:80
    ||                      |- 192.168.0.202:30080 > ingress-service:81
    ||
    |= 192.168.0.203 - Trabajador 3 del Cluster de Kubernetes
    ||                   |- 10.10.0.3 - POD2 WORDPRESS
    ||                                      |- Contenedor1 - app1
    ||                                           |- Apache httpd: 80
    ||                                           |- apache.conf | wp.conf > DB_URL: mariadb-service:3333 (1)
    ||                 Es una máquina Linux... que tendrá en su kernel netFilter:
    ||                      |- 10.10.1.1:3333 > 10.10.0.1:3306
    ||                      |- 10.10.1.2:8080 > 10.10.0.2:80 | 10.10.0.3:80  
    ||                      |- 10.10.1.3:81   > 10.10.0.4:80
    ||                      |- 192.168.0.203:30080 > ingress-service:81
    
    
        || < Red virtual compartida entre las máquinas de kubernetes: 10.10.0.0/16
        
Para resolver (1) es donde entran los servicios de tipo ClusterIP: mariadb-service < 10.10.1.1... + puerto de servicio
    Esa IP la asigna kubernetes en automático.
    Qué es esa IP? Quién hay detrás ? Una IP Virtual.. no existe programa detrás de esa IP...
                    Realmente esa IP tan solo existe como regla en netFilter
                    
                    
---

netFilter: módulo del kernel de Linux por el que pasan TODOS los paquetes de RED en un host linux
    ^
iptables tan solo configura reglas en netFilter

## NodePort = ClusterIP + NAT (Redirección de puertos en la ip publica de cada host)
                        En la IP publica del host se abrirá un puerto por encima del 30000

## LoadBalancer = NodePort + Gestión automatizada de un balanceador externo compatible con Kubernetes

        OJO: Si contrato un cluster de kubernetes en un cloud, el cloud me proveerá (previo paso por caja) un balanceador externo compatible con kubernetes
             Si monto un cluster on premisses, me tocará instalar a mi un balanceado compatible con kubernetes: MetalLb

No hay nada en un kubernetes out of the box para automatizar DNS externos.

No obstante, por ejemplo, Openshift, me da un tipo de objeto adicional: ROUTE, que no existe en kubernetes
    Un ROUTE es un servicio de tipo LOAD BALANCER + Gestión automatizada de un DNS Externo.
    OPENSHIFT Es la distro de kubernetes de Redhat, que aporta caso 200 tipos de objetos adicionales a los 25 por defecto que trae kubernetes

---

# Gestión de volúmenes en Kubernetes

Hemos dicho que los volúmenes en los contenedores sirven para:
- Inyectar ficheros
- Compartir datos entre pods
- (1) Guardar información de forma que cuando un pod / contenedor sea borrado, no pierda los datos <<<<<  PersistentVolume / PersistentVolumeClaim

## PersistentVolume

Es un objeto que representa un volumen de almacenamiento que existe (ya existe.,.. no que voy a crear... que ya fué creado por alguien)
en un sistema de almacenamiento externo al cluster: nfs, iscsi, cloud, cabina (fibra)

Oye Kubernetes, que hay por ahí un Volumen en mi cuenta de Amazon con este ID: vol-08836614756acc29b.
    Te lo cuento: tiene 100Gbs de espacio, es rapidito y cifrado

## Petición de volumen persistente

Un pod, cuando necesita espacio de almacenamiento para (1) Guardar información de forma que cuando el pod sea borrado, no pierda los datos
entonces usa una solicitus de volumen persistente

Una peticion de volumen persistente (pvc) es como su nombre indica una petición de un volumen... persistente.
Cuando pido un volumen, doy las características que necesito: 
 - De tal tamaño
 - Cifrao o no
 - Rapidito
 - Lentito

                                                                    Kubernetes actua de celestino (meetec) 
                Pod08b              <>               PVC01                   <>                     PV01
                                                     5Gbs, Rapido y redundante                      10Gbs, Rapidito y cifrado

Quién lo crea?
                    Dueño de una app que quiere desplegar                                           Administrador del cluster

En kubernetes hay entre un kilo y dos de tipos de volumenes a usar

    storage:    100 Gi
                100 Gibibytes
                
    1 Gb    = 1000 Mb                               Giga es 10 a la 9
                 1 Mb = 1000 Kb                     Mega es 10 a la 6: 1000000
                           1 Kb = 1000 b            Kilo es 10 a la 3: 1000
    1 Gi    = 1024 Mi 
                 1 Mi = 1024 Ki
                           1 Ki = 1024 b

En un cluster real de kubernetes, los administradores instalan programas llamados Proveedores de Volumenes.
Esos programas crean volumenes según son solicitados

                                        Tipo                                Proveedores de Volumenes
                                                                                    
                                        rapidito y redundante               >    Cabina Emc2
                                        lentito                             >    IBMCLOUD 
                                            
                                            ^
                                        StorageClass


---


PLANTILLA DE HELM (Chart)
    
    Fichero 1: fichero de valores para un caso concreto     > Plantilla > Fichero de despliegue1
    Fichero 2                                               > Plantilla > Fichero de despliegue2
    Fichero 3                                               > Plantilla > Fichero de despliegue3
    Fichero 4                                               > Plantilla > Fichero de despliegue4
    Fichero 400                                             > Plantilla > Fichero de despliegue5