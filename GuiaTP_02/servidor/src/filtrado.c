/**
 * @file filtrado.c
 * @author Nicolas Rios Taurasi (nicoriostaurasi@frba.utn.edu.ar)
 * @brief Archivo que contiene la funcion de filtrado
 * @version 0.1
 * @date 03-11-2021
 * 
 * @copyright Copyright (c) 2021
 * 
 */

/**
 * @brief Realiza el filtrado de media movil
 * 
 * @param buffer 
 * @param largo 
 * @param muestra 
 * @return int 
 */
int filtro(int *buffer, int largo, int muestra)
{
  int aux = 0;
  int i;

  for (i = 0; i < (largo - 1); i++)
  {
    buffer[largo - (i + 1)] = buffer[largo - (i + 1) - 1];
  }

  buffer[0] = muestra;

  for (i = 0; i < largo; i++)
  {
    aux = aux + buffer[i];
  }
  aux = (int)(aux / largo);
  return aux;
}