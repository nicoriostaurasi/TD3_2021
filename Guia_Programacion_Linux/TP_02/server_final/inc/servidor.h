#include "main.h"

int AtiendeCliente(int socket, struct sockaddr_in addr,char* shm_addr, int sem_set_id);
int DemasiadosClientes(int socket, struct sockaddr_in addr);