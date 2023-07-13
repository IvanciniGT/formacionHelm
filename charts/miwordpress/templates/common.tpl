{{- define "secret.name" -}}
{{  default "configuracion-mariadb-secret" $.Values.mariadb.config.existingSecretName }}
{{- end -}}

{{- define "configmap.name" -}}
configuracion-mariadb
{{- end -}}

{{- define "db.label.app" -}}
app: mariadb
{{- end -}}

{{- define "db.volume.name" -}}
volumen-bbdd
{{- end -}}

{{- define "db.pvc.name" -}}
{{  default "peticion-volumen-mariadb" $.Values.mariadb.persistence.existingPvcName }}
{{- end -}}

{{- define "image" -}}
{{- $pullPolicyRellena := default "Always" .pullPolicy -}}
{{- if not (regexMatch "^((IfNotPresent)|(Always)|(Never))$" $pullPolicyRellena ) -}}
    {{- fail (printf "El valor suministrador para la propiedad mariadb.image.pullpolicy: '%s' no es válido. Debe debe tener como valor: Always, IfnotPresent o Never." .pullPolicy) -}}
{{- end -}}
image:  {{ required "Debe suministrar el repo de la imagen de mariadb: mariadb.image.repo" .repo -}}
        :{{ required "Debe suministrar el tag de la imagen de mariadb: mariadb.image.tag" .tag }}
imagePullPolicy: {{ $pullPolicyRellena }}
{{ end -}}







{{/*
Esta plantilla espera recibir en el contexto algo del tipo:

field: mariadb.persistence.capacity
value: 3Gi
required: true
*/}}


{{- define "check.bytes" -}}
{{- if and (.required) (not .value) -}}
{{- fail (printf "Error en la propiedad '%s'. Es obligatorio suministrar un valor" .field) -}}
{{- end -}}
{{- if not (regexMatch "^[1-9][0-9]*[GMTK]i$" .value) -}}
{{- fail (printf "Error en la propiedad '%s'. El valor suministrado '%s' no es válido. Ejemplos de valores válidos: 1Gi, 16Ti, 9Mi" .field .value) -}}
{{- end -}}
{{- end -}}









{{- define "check.cores" -}}
{{- if not (regexMatch "^[1-9][0-9]*m?$" ( . | toString )) -}}
{{- fail (printf "El valor suministrador para la cpu: '%s' no es válido. Ejemplos de valores válidos: 1, 5, 200m, 1750m" .) -}}
{{- end -}}
{{- end -}}

{{- define "resources" -}}
{{- include "check.bytes" ( dict "required" true "field" "????.resources.requests.memory" "value" .requests.memory ) -}}
{{- include "check.bytes" ( dict "required" true "field" "????.resources.limits.memory" "value" .limits.memory ) -}}

{{- include "check.cores" ( required "Debe especificar un valor para la cpu del requests" .requests.cpu ) -}}
{{- include "check.cores" ( required "Debe especificar un valor para la cpu del limits" .limits.cpu ) -}}
resources: {{ toYaml . | nindent 4}}
{{- end -}}