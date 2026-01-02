GitHub Actions – Terraform CI/CD

    Este directorio contiene los workflows de GitHub Actions encargados de ejecutar
    Terraform automáticamente cada vez que se suben cambios al repositorio.

El objetivo es:

    Validar los cambios de infraestructura

    Mostrar qué se va a crear/modificar (plan)

    Desplegar automáticamente solo cuando los cambios llegan a main

¿Cómo funciona a alto nivel?

    Un desarrollador hace cambios en Terraform

    Hace git push o abre un Pull Request

    GitHub Actions se ejecuta automáticamente

    Terraform corre en servidores de GitHub (no en el PC del desarrollador)

    AWS recibe los cambios y despliega la infraestructura

Jobs definidos en el workflow
Job: terraform-plan

Este job se encarga de validar y mostrar los cambios, pero NO despliega nada.

Se ejecuta cuando:

    Se abre un Pull Request

    Se hace push al repositorio

Pasos que realiza:

Descarga el código del repositorio

    Instala Terraform

    Ejecuta terraform init

    Ejecuta terraform validate

    Ejecuta terraform plan

El resultado es una vista clara de:

    Qué recursos se van a crear

    Qué recursos se van a modificar

    Qué recursos se van a eliminar

    Este job es completamente seguro porque no cambia nada en AWS.

Job: terraform-apply

    Este job se encarga del despliegue real de la infraestructura.

Se ejecuta SOLO cuando:

    El código llega a la rama main

    El job terraform-plan terminó correctamente

Pasos que realiza:

    Descarga el código

    Instala Terraform

    Ejecuta terraform init

    Ejecuta terraform apply -auto-approve

Este job:

    Crea recursos en AWS

    Modifica infraestructura existente

    Aplica exactamente lo que mostró el plan

Por seguridad:

    No corre en Pull Requests

    Solo corre en main

    Depende de que el plan haya sido exitoso

    Credenciales AWS

Las credenciales de AWS NO están en el código.

Se configuran como GitHub Secrets:

    AWS_ACCESS_KEY_ID

    AWS_SECRET_ACCESS_KEY

    AWS_REGION

GitHub las inyecta como variables de entorno durante la ejecución del workflow.
Terraform las detecta automáticamente.

Puntos importantes de seguridad

    No se versionan secretos

    No se sube el archivo terraform.tfvars

    El estado de Terraform no vive en el repositorio

    El deploy solo ocurre desde main