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
{{- fail (printf "Error en la propiedad '%s'. Es obligatorio suministrar un valor" $.field) -}}
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

{{- $nombreCampoRequestsMemory := printf "%s.resources.requests.memory" .field -}}
{{- $nombreCampoLimitsMemory := printf "%s.resources.limits.memory" .field -}}
{{- $mensajeErrorCampoRequestsCPU := printf "Debe especificar un valor para la propiedad  %s.resources.requests.cpu" .field -}}
{{- $mensajeErrorCampoLimitsCPU := printf "Debe especificar un valor para la propiedad %s.resources.limits.cpu" .field -}}

{{- include "check.bytes" ( dict "required" true "field" $nombreCampoRequestsMemory "value" .requests.memory ) -}}
{{- include "check.bytes" ( dict "required" true "field" $nombreCampoLimitsMemory "value" .limits.memory ) -}}

{{- include "check.cores" ( required $mensajeErrorCampoRequestsCPU .requests.cpu ) -}}
{{- include "check.cores" ( required $mensajeErrorCampoLimitsCPU .limits.cpu ) -}}

resources: 
    requests: {{ toYaml .requests | nindent 8}}
    limits: {{ toYaml .limits | nindent 8}}
{{- end -}}


{{- define "extra.env.vars" -}}
{{- $forbiddenVars := .forbiddenVars -}}
{{- range $clave, $valor := .vars -}}
{{- if hasKey $forbiddenVars $clave -}}
 {{- fail (printf "No puede definir la variable %s como extraEnvVars. En su lugar utilice: %s" $clave (get $forbiddenVars $clave ) ) -}}
{{- end -}}
-   name: {{ $clave }}
    value: {{ $valor | quote}}
{{ end -}}                        
{{- end -}}
