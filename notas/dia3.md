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
        