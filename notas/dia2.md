# Cliente de kubernetes (uno de ellos)

kubectl [verbo] [tipo de objeto] <args adicionales que pueden ser requeridos>
        get      namespace namespaces ns
        describe pod pods
        create   service services   svc
        delete   statefulsets
                 deployments
                 configmap
                 secrets
                 networkPolicies
                 persistentvolumeclaims pvc
                 persistentvolumes pv

kubectl create -f FICHERO_YAML      Crear recursos en el cluster
        apply  -f FICHERO_YAML      Crear o modificar recursos en el cluster
        delete -f FICHERO_YAML      Eliminar recursos en el cluster
        
## Creación de un namespace

### OPCION 1
kubectl create ns mi_namespace 
    ESTO ESTA TOTALMENTE PROHIBIDO. 
    Todo quiero que se haga desde ficheros yaml... que se guardarán en un sistema de control de version
    Que me permitirán reaplicar una determinada configuración en el futuro.

### OPCION 2
# crear un fichero que defina el ns: mi-ns.yaml
kubectl apply (o create) -f mi-ns.yaml

---

Versiones de software

latest      El problema es que en un momento dado puede ser la v1.2.3 y el día de mañana la 2.3.5
1           Pueden meterme un minor nuevo: 1.2.3 -> 1.8.9 
            Con nueva funcionalidad que no necesito con sus potenciales bugs... no lo quiero
1.2         *** Apto para entornos de producción
            Esta versión da la funcionalidad que necesito + los ultimos bugs arreglados.
1.2.3       El problema es que quizás tiene bugs que se han arreglado en nuevas versiones... 
            Y no tengo esos arreglos: 1.2.9
    
            Cuando se incrementan?
Major: 1    Breaking change
Minor: 2    Nueva funcionalidad
            Funcionalidad deprecated (marcada como obsoleta)
                + arreglos de bugs
Patch: 3    Arreglos de bugs

------------------------------------------------------------------------------------------------------------------------

        Cluster
        - Namespace ivan                            
                pod-ivan                                        web     10.100.221.115:81
                    contenedor1*       10.10.142.129:80 
        - Namespace ivan2
                pod-ivan                                        web     10.104.243.15:81
                    contenedor1        10.10.142.130:80
                    
------------------------------------------------------------------------------------------------------------------------

Wordpress
    Pod1
        Contanedor1
            Apache - php + wordpress
                            wp-config.php < Datos de la BBDD a la que conectar:
                                DB_URL= db-service:3306
    Pod2
        Contenedor2
            MariaDB - BBDD
        
Pod: Conjunto de contenedores que:
- Comparten configuración de red... y por ende IP
- Se despliegan en el mismo host
    -> Que pueden compartir volumenes locales
x Que escalan juntos

Servicio: 
- ClusterIP:    IP de balanceo de carga + entrada DNS


---


pod-ivan        -> ns ivan
web-servicio 

En la práctica yo no creo ningún pod en kubernetes... Kubernetes es quién crea los pods.
Y para ello, nosotros necesitamos configurar dentro de kubernetes UNA PLANTILLA DE POD.
Éstas las configuramos usando:
- Deployment
- StatefulSet
- DaemonSet

---
Bases de datos:

- Standalone -> 1 pod... en este caso me da igual deployment que un statefulset
- Replicacion   ->
- Cluster       -> Varios pods... Y cada pod, quiero que tenga sus propios ficheros de datos        
                   Su propio volumen de almacenamiento
