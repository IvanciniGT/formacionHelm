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
