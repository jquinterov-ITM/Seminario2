# Comparación de Proyectos Terraform — Proyecto A vs Proyecto B

## Resumen rápido
- Plan A: crea 24 recursos.
- Plan B: crea 43 recursos.
- Diferencia principal: Proyecto B incluye más recursos (WAF, más etiquetas, instancias con IP privadas fijas y recursos auxiliares) y políticas/etiquetas organizacionales.

## Mapeo sugerido (alto nivel)
| Categoría | Proyecto A | Proyecto B | Observaciones |
|---|---:|---:|---|
| Compute (master) | `module.compute.aws_instance.master` | `module.compute.aws_instance.master_primary` / `master_secondary[...]` | B tiene réplica/primario/secundarios; A usa IP pública en `user_data`.
| Compute (worker) | `module.compute.aws_instance.worker` | `module.compute.aws_instance.worker[...]` | Nombres y número de réplicas difieren.
| Networking | `module.network.*` (subnets, igw, nat, rtb) | `module.network.*` (más instancias, mismas categorías) | Verificar CIDR y evitar solapamiento.
| Load Balancer | `module.load_balancer.aws_lb.main` + listener | `module.load_balancer.aws_lb.main` + `aws_lb_listener.http_forward[...]` | Ambos crean ALB/TG; B añade tags más completos.
| Security / Edge | (no WAF) | `module.edge.aws_wafv2_web_acl` + association | WAF en B implica coste y configuración extra.
| Datos/Aux | (no data) | `module.data.*` (EC2 data, SG data) | B contiene fuentes de datos y etiquetas `Project`.

## Diferencias clave y su impacto
- `associate_public_ip_address`:
  - A: `true` en instancias (usa IP pública dentro de `user_data`).
  - B: `false` y usa `private_ip` + arranque apuntando a IP privada.
  - Impacto: políticas de acceso y modo de arranque de k3s distintos; riesgo de colisiones o fallos de unión si se mezclan.

- `key_name`:
  - A: `lab-key` vs B: `vockey`.
  - Impacto: acceso SSH inconsistente; unificar clave o crear ambas en la cuenta.

- `user_data`:
  - A: usa la IP pública para configurar TLS SAN y arrancar k3s.
  - B: usa `--cluster-init` y `K3S_URL` con IP privada.
  - Impacto: estrategias de cluster diferentes; no son incompatibles si se normaliza la configuración.

- `tags_all` y metadatos:
  - B aplica `Environment`, `ManagedBy`, `Project` — recomendable para gobernanza.

- Recursos costeables (WAF, NAT, ALB extra):
  - B introduce más costes y componentes que deben justificarse si se aplican juntos.

## Recomendaciones prácticas (pasos concretos)
1. Backup: conservar ambos `plan*.tfplan` y `*.json` antes de aplicar cambios.
2. Decidir «fuente de verdad» por dominio (ej. B controla networking y WAF; A controla algunos módulos compute), para evitar duplicados.
3. Unificar `key_name` en ambos proyectos (crear la clave en AWS o usar la misma nombre/ARN).
4. Normalizar `associate_public_ip_address` y `user_data`:
   - Si quieres cluster privado: `associate_public_ip_address = false` y `user_data` con `K3S_URL` apuntando a la IP privada del master.
   - Si necesitas IP pública para TLS SAN: estandarizar en ambos y asegurar seguridad (SG, NACL).
5. Etiquetado: aplicar `tags_all` consistente (Environment, Project, ManagedBy) en A y B.
6. Si ambos deben coexistir sin compartir recursos: usar `name_prefix` o sufijos (ej. `-a`, `-b`) para evitar colisiones en nombres.
7. Para coordinar recursos entre proyectos: usar `terraform_remote_state` (backend S3 o Terraform Cloud) o convertir uno en módulo reutilizable.
8. Para que un proyecto "conozca" recursos creados por el otro: usar `terraform import` cuidadosamente y documentar el cambio.

## Pasos sugeridos inmediatos (ordenados)
1. Elegir key_name única y actualizar variables en A y B.
2. Elegir estrategia de red (IPs públicas vs privadas) y actualizar `associate_public_ip_address` + `user_data` en ambos proyectos.
3. Ejecutar `terraform plan` en entorno de staging (otra VPC o cuenta) para validar sin afectar producción.
4. Si se requiere integración: crear `data "terraform_remote_state"` en el proyecto consumidor y exponer outputs (VPC id, subnets, TG ids).

## Notas finales
- Riesgos más críticos: claves SSH distintas y configuraciones `user_data` incompatibles; CIDR solapadas si aplicas ambos en la misma cuenta/VPC.
- Si quieres, generaré parches concretos para unificar `key_name` y `associate_public_ip_address`, o un ejemplo de `terraform_remote_state`.

---
Generado automáticamente por el análisis de `planA.json` y `planB.json`. Mantén copias de seguridad antes de aplicar cambios.
