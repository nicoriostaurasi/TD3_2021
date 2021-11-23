/**
 * @file file_handler.c
 * @author Nicolas Rios Taurasi (nicoriostaurasi@frba.utn.edu.ar)
 * @brief Este archivo contiene el codigo para leer el archivo de configuracion
 * @version 0.1
 * @date 02-11-2021
 * 
 * @copyright Copyright (c) 2021
 * 
 */
#include "../inc/main.h"

/**
 * @brief Funcion para recargar los parametros de configuracion
 * 
 * @param clientes 
 * @param backlog 
 * @param dver_pipe 
 * @return int 
 */
int Lector_CFG(int *clientes, int *backlog, int *dver_pipe)
{
  int clientes_aux;
  int backlog_aux;
  int ventana_aux;
  FILE *fp_cfg;

  fp_cfg = fopen("cfg.txt", "r");

  if (fp_cfg == NULL)
  {
    printf("[SERVER]: No se puede abrir el archivo de configuración\n");
    fclose(fp_cfg);
    return -1;
  }

  fscanf(fp_cfg, "clientes %d\n", &clientes_aux);

  if (clientes_aux <= 0)
  {
    printf("[SERVER]: Error en el archivo de configuracion campo: Clientes\n");
    clientes_aux = CLIENTE_DEF;
    printf("[SERVER]: Se toma valor por defecto %d\n", clientes_aux);
  }

  fscanf(fp_cfg, "conexiones %d\n", &backlog_aux);

  if (backlog_aux <= 0)
  {
    printf("[SERVER]: Error en el archivo de configuracion campo: Backlog\n");
    backlog_aux = CONEC_DEF;
    printf("[SERVER]: Se toma valor por defecto %d\n", backlog_aux);
  }

  fscanf(fp_cfg, "ventana %d\n", &ventana_aux);

  if (ventana_aux <= 0)
  {
    printf("[SERVER]: Error en el archivo de configuracion campo: Ventana\n");
    ventana_aux = VENTANA_DEF;
    printf("[SERVER]: Se toma valor por defecto %d\n", ventana_aux);
  }

  if (ventana_aux >= 250)
  {
    printf("[SERVER]: Error en el archivo de configuracion campo: Ventana\n");
    ventana_aux = 249;
    printf("[SERVER]: Se toma valor por defecto %d\n", ventana_aux);
  }

  *(clientes) = clientes_aux;
  *(backlog) = backlog_aux;

  if (write(dver_pipe[1], &ventana_aux, sizeof(int)) == -1)
  {
    printf("[SERVER]: Error escribiendo el Pipe\n");
  }

  fclose(fp_cfg);
  return 0;
}
