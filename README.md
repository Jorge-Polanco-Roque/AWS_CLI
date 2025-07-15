# AWS CLI Command Reference 📘

Este repositorio contiene una colección organizada de comandos útiles para interactuar con servicios de AWS mediante la CLI (`aws` y `aws s3api`). Es ideal como guía rápida para desarrolladores, DevOps, analistas de datos y administradores cloud.

---

## 📦 Contenido

- [Configuración Inicial](#configuración-inicial)
- [S3: Almacenamiento de Objetos](#s3-almacenamiento-de-objetos)
- [EC2: Servidores Virtuales](#ec2-servidores-virtuales)
- [IAM: Gestión de Identidades](#iam-gestión-de-identidades)
- [ECS y Lambda](#ecs-y-lambda)
- [Otros Comandos Útiles](#otros-comandos-útiles)

---

## 🔧 Configuración Inicial

```bash
# Configura credenciales y región
aws configure

# Habilita sugerencias automáticas
aws configure set cli_auto_prompt on

# Desactiva el paginador para ver todo directo
aws configure set cli_pager ""

